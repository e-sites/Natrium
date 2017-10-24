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

    lazy private var md5Checksum: String = {
        return "\(natrium.projectDir) \(natrium.configuration) \(natrium.environment) \(natrium.target) \(natrium.appVersion)".md5
    }()

    func create() {
        file.write(md5Checksum)
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
        return contents != md5Checksum
    }
}
