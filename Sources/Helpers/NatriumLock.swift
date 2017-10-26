//
//  NatriumLock.swift
//  NatriumPackageDescription
//
//  Created by Bas van Kuijck on 24/10/2017.
//

import Foundation

class NatriumLock {
    let natrium: Natrium

    static var file: File {
        let directory = FileManager.default.currentDirectoryPath
        return File(path: "\(directory)/Natrium.lock")
    }

    var needsUpdate: Bool {
        let file = NatriumLock.file
        if !file.isExisting {
            return true
        }
        guard let contents = file.contents else {
            return true
        }
        return contents != checksum
    }

    private var checksum: String {
        let contents = File.read(path: natrium.yamlFile) ?? ""
        let ar = [
            natrium.projectDir,
            natrium.target,
            natrium.configuration,
            natrium.environment,
            natrium.appVersion
        ]

        return [ ar, [
            "---",
            Natrium.version,
            NatriumLock.argumentsChecksum(ar),
            contents.md5
            ]]
            .flatMap { $0 }
            .joined(separator: "\n")
    }

    init(natrium: Natrium) {
        self.natrium = natrium
    }

    static func argumentsChecksum(_ array: [String]) -> String {
        return array.joined(separator: "~~±NATRIUM±~~").md5
    }

    func create() {
        let file = NatriumLock.file
        file.write(checksum)
    }

    static func getNatrium(quiet: Bool) -> Natrium? {
        if !file.isExisting {
            return nil
        }
        guard let contents = file.contents else {
            return nil
        }
        let lines = contents.components(separatedBy: "\n")
        if lines.count < 9 {
            if !quiet {
                Logger.fatalError("Natrium.lock file is malformed, please rebuild")
            }
            return nil
        }

        let checksum = argumentsChecksum(Array(lines[0...4]))

        if checksum != lines[7] {
            if !quiet {
                Logger.fatalError("Natrium.lock file is corrupt, please rebuild")
            }
            return nil
        }
        
        return Natrium(projectDir: lines[0],
                       target: lines[1],
                       configuration: lines[2],
                       environment: lines[3],
                       force: true)
    }

    func remove() {
        NatriumLock.file.remove()
    }
}
