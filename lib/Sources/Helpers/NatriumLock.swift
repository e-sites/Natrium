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
            natrium.configuration,
            natrium.environment,
            natrium.target,
            natrium.appVersion,
            "---",
            contents.md5
            ].joined(separator: "\n")
    }()

    func create() {
        file.write(checksum)
    }

    private var file: File {
        let currentDirectory = FileManager.default.currentDirectoryPath
        return File(path: "\(currentDirectory)/Natrium.lock")
    }

    var needsUpdate: Bool {
        if !file.isExisting {
            return true
        }
        guard let contents = file.contents else {
            return true
        }
        return contents != checksum
    }
}
