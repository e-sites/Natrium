//
//  FileHelper.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation

class FileHelper {
    static func write(filePath: String, contents: String) {
        let file = File.open(filePath)
        if file.isExisting {
            file.chmod("7777")
        }
        file.write(contents)
        file.touch()
        file.chmod("+x")
    }
}

// MARK: - File: Class
// --------------------------------------------------------

class File {
    let path: String

    init(path: String) {
        self.path = path
    }

    static func file(_ path: String) -> Bool {
        return exists(at: path)
    }

    static func exists(at path: String) -> Bool {
        return File(path: path).isExisting
    }

    static func read(path: String) -> String? {
        return File(path: path).contents
    }

    static func dirName(of path: String) -> String {
        return File(path: path).dirName
    }
    
    static func open(_ path: String) -> File {
        return File(path: path)
    }

    static func chmod(_ path: String, mode: String) {
        File(path: path).chmod(mode)
    }

    static func remove(_ path: String) {
        File(path: path).remove()
    }

    static func copy(_ path: String, `to` toPath: String) {
        File(path: path).copy(to: toPath)
    }

    static func copy(_ path: String, `to` toFile: File) {
        File(path: path).copy(to: toFile)
    }
}

// MARK: - File: Instance
// --------------------------------------------------------

extension File {
    func write(_ string: String) {
        write(string.data(using: .utf8) ?? Data())
    }

    func write(_ data: Data) {
        let url = URL(fileURLWithPath: path)
        try? data.write(to: url)
    }

    func touch() {
        shell("/usr/bin/touch", arguments: [ path ])
    }

    func chmod(_ mode: String) {
        shell("/bin/chmod", arguments: [ mode, path ])
    }

    func remove() {
        try? FileManager.default.removeItem(atPath: path)
    }

    var dirName: String {
        var url = URL(fileURLWithPath: path)
        if url.lastPathComponent.contains(".") {
            url.deleteLastPathComponent()
        }
        return url.path
    }

    var contents: String? {
        guard let data = self.data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    var data: Data? {
        return FileManager.default.contents(atPath: path)
    }

    var isExisting: Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    func copy(`to` path: String) {
        copy(to: File(path: path))
    }

    func copy(`to` file: File) {
        do {
            try FileManager.default.copyItem(atPath: path, toPath: file.path)
        } catch let error {
            Logger.fatalError("Error copying \(path) to \(file.path): \(error)")
        }
    }
}

// MARK: - Dir: Class
// --------------------------------------------------------

class Dir {
    @discardableResult
    static func glob(_ pattern: String, handler: ((String) -> Void)? = nil) -> [String] {
        let pattern = pattern.replacingOccurrences(of: "*", with: "(.+?)")
        let directory = File.dirName(of: pattern)
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: directory)
                .map { "\(directory)/\($0)" }
            var returnArray: [String] = []
            for file in files where file =~ pattern {
                returnArray.append(file)
                handler?(file)
            }

            return returnArray
        } catch let error {
            Logger.fatalError("\(error)")
            return []
        }
    }

    static func clearContents(of path: String) {
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(atPath: path)
                .map { "\(path)/\($0)" }
            for file in files {
                try fileManager.removeItem(atPath: file)
            }
        } catch let error {
            Logger.fatalError("\(error)")
        }
    }

    static func dirName(path: String) -> String {
        var path = path
        if path.last == "/" {
            _ = path.removeLast()
        }
        return path
    }
}
