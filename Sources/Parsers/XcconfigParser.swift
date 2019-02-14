//
//  XcconfigParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation
import Yaml
import Francium

class XcconfigParser: Parseable {
    
    var yamlKey: String {
        return "xcconfig"
    }

    var isRequired: Bool {
        return true
    }

    func parse(_ dictionary: [String: Yaml]) throws {
        var files: [String: [String]] = [:]
        for configuration in configurations {
            files[configuration] = [ "ENVIRONMENT = \(environment)" ]
        }

        // Convert the dictionary to writeable lines per xcconfig file
        for keyValue in dictionary {
            let key = keyValue.key
            if let dic = keyValue.value.dictionary {
                for dicKeyValue in dic {
                    files[dicKeyValue.key.stringValue]?.append("\(key) = \(dicKeyValue.value.stringValue)")
                }

            } else if let string = keyValue.value.string {
                for configuration in configurations {
                    files[configuration]?.append("\(key) = \(string)")
                }
            }
        }

        // Actually write the lines to the specific xcconfig file
        for dic in files {
            let configuration = dic.key
            let lines = dic.value
            let fileName = "\(FileManager.default.currentDirectoryPath)/ProjectEnvironment.\(configuration.lowercased()).xcconfig"
            let file = File(path: fileName)
            try file.write(string: lines.joined(separator: "\n"))
        }

        if isCocoaPods {
            try _writeCocoaPodsXcConfigFiles()
        }
    }

    /// Automatically prepend an #include in the CocoaPods generated xcconfig files
    private func _writeCocoaPodsXcConfigFiles() throws {
        for configuration in configurations {
            let cdc = configuration.lowercased()
            let dir = Dir(path: "\(projectDir)/Pods/Target Support Files/")
            let globFiles = dir.glob("Pods*-\(target)/Pods*-\(target).\(cdc).xcconfig")
            guard let file = globFiles.first, file.isExisting, let contents = file.contents else {
                continue
            }

            let line = "#include \"../../Natrium/bin/ProjectEnvironment.\(cdc).xcconfig\""
            if contents.contains(line) {
                continue
            }

            file.chmod(0o7777)
            try file.write(string: "\(line)\n\n\(contents)")
        }
    }
}
