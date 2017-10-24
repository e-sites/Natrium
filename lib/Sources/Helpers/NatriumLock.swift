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
        return [
            natrium.projectDir,
            natrium.target,
            natrium.configuration,
            natrium.environment,
            natrium.appVersion,
            "---",
            contents.md5
            ].joined(separator: "\n")
    }()

    func create() {
        let file = NatriumLock.file
        file.write(checksum)
    }

    static var file: File {
        let currentDirectory = FileManager.default.currentDirectoryPath
        return File(path: "\(currentDirectory)/Natrium.lock")
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

    static func getNatrium() -> Natrium? {
        if !file.isExisting {
            return nil
        }
        guard let contents = file.contents else {
            return nil
        }
        let lines = contents.components(separatedBy: "\n")
        if lines.count < 4 {
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
