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
        let directory: String = FileManager.default.currentDirectoryPath
        return File(path: "\(directory)/natrium.lock")
    }

    var needsUpdate: Bool {
        let file = NatriumLock.file
        if !file.isExisting {
            return true
        }
        guard let contents = file.contents else {
            return true
        }
        if isCocoaPods {
            let dir = FileManager.default.currentDirectoryPath
            if Dir.glob("\(dir)/*.xcconfig").isEmpty {
                return true
            }
            
            for file in Dir.glob("\(natrium.projectDir)/Pods/Target Support Files/Pods-\(natrium.target)/Pods-\(natrium.target).*.xcconfig") { // swiftlint:disable:this line_length
                let includeLine = "#include \"../../Natrium/bin/ProjectEnvironment"
                if file.contents?.contains(includeLine) == false {
                    return true
                }
            }
        }
        return contents != checksum
    }

    private var checksum: String {
        let contents = File.read(path: natrium.yamlFile) ?? ""
        let array = [
            isCocoaPods ? natrium.projectDir : "../",
            natrium.target,
            natrium.configuration,
            natrium.environment,
            natrium.appVersion
        ]

        return [ array, [
            "---",
            Natrium.version,
            NatriumLock.argumentsChecksum(array),
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
                Logger.fatalError("natrium.lock file is malformed, please rebuild")
            }
            return nil
        }

        let checksum = argumentsChecksum(Array(lines[0...4]))

        if checksum != lines[7] {
            if !quiet {
                Logger.fatalError("natrium.lock file is corrupt, please rebuild")
            }
            return nil
        }
        let projectDir = isCocoaPods ? lines[0] : "../"

        return Natrium(projectDir: projectDir,
                       target: lines[1],
                       configuration: lines[2],
                       environment: lines[3],
                       force: true)
    }

    func remove() {
        NatriumLock.file.remove()
    }
}
