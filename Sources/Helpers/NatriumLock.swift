//
//  NatriumLock.swift
//  NatriumPackageDescription
//
//  Created by Bas van Kuijck on 24/10/2017.
//

import Foundation
import Francium

class NatriumLock {
    let natrium: Natrium

    static var file: File {
        let directory: String = FileManager.default.currentDirectoryPath
        return File(path: "\(directory)/natrium.lock")
    }

    var appIconPath: String?

    var forceUpdate: Bool = false

    var needsUpdate: Bool {
        if forceUpdate {
            return true
        }
        let file = NatriumLock.file
        if !file.isExisting {
            return true
        }
        guard let contents = file.contents else {
            return true
        }
        if isCocoaPods {
            let dir = FileManager.default.currentDirectoryPath
            if Dir(path: dir).glob("*.xcconfig").isEmpty {
                return true
            }
            
            for file in Dir(path: natrium.projectDir).glob("Pods/Target Support Files/Pods-\(natrium.target)/Pods-\(natrium.target).*.xcconfig") { // swiftlint:disable:this line_length
                let includeLine = "#include \"../../Natrium/bin/ProjectEnvironment"
                if file.contents?.contains(includeLine) == false {
                    return true
                }
            }
        }
        return contents != checksum
    }

    private var checksum: String {
        let contents = File(path: natrium.yamlFile).contents ?? ""
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
        do {
            let file = NatriumLock.file
            if file.isExisting {
                file.chmod(0o7777)
            }
            try file.write(string: checksum)
        } catch { }
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
        try? NatriumLock.file.delete()
    }
}
