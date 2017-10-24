//
//  NatriumLock.swift
//  NatriumPackageDescription
//
//  Created by Bas van Kuijck on 24/10/2017.
//

import Foundation

class NatriumLock {
    let natrium: Natrium

    init(natrium: Natrium) {
        self.natrium = natrium
    }

    lazy private var checksum: String = {
        let contents = File.read(path: natrium.yamlFile) ?? ""
        var ar = [
            natrium.projectDir,
            natrium.target,
            natrium.configuration,
            natrium.environment,
            natrium.appVersion
        ]
        let arChecksum = NatriumLock.argumentsChecksum(ar)
        ar.append("---")
        ar.append(Natrium.version)
        ar.append(arChecksum)
        ar.append(contents.md5)
        return ar.joined(separator: "\n")
    }()

    static func argumentsChecksum(_ array: [String]) -> String {
        return array.joined(separator: "~~±NATRIUM±~~").md5
    }

    func create() {
        let file = NatriumLock.file
        file.write(checksum)
    }

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

        let checksum = argumentsChecksum([
            lines[0],
            lines[1],
            lines[2],
            lines[3],
            lines[4]
        ])

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
