//
//  XccConfigHelper.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import Yaml

class XccConfigParser: Parser {
    let natrium: Natrium

    var isRequired: Bool {
        return false
    }
    
    var yamlKey: String {
        return "xcconfig"
    }

    required init(natrium: Natrium) {
        self.natrium = natrium
    }

    func parse(_ yaml: [NatriumKey: Yaml]) {
        Logger.insets = 1
        Logger.debug("[xcconfig]")
        Logger.insets = 2
        var xcconfigs: [String: [String]] = [:]
        xcconfigs["*"] = [ "ENVIRONMENT = \(self.natrium.environment.uppercased())" ]

        // We need empty arrays, else the .xcconfig files will not be generated
        for configuration in natrium.configurations {
            xcconfigs[configuration] = [ ]
        }
        for object in yaml {
            var dictionary = object.value.dictionary
            if dictionary == nil {
                dictionary = [ Yaml(stringLiteral: "*"): Yaml(stringLiteral: object.value.stringValue) ]
            }

            for xcObject in dictionary ?? [:] {
                let configNames = xcObject.key.stringValue
                for configName in configNames.components(separatedBy: ",") {
                    if xcconfigs[configName] == nil {
                        xcconfigs[configName] = []
                    }
                    xcconfigs[configName]!.append("\(object.key.string) = \(xcObject.value.stringValue)")
                    Logger.log("\(object.key.string):\(configName) = \(xcObject.value.stringValue)")
                }
            }
        }

        let currentDirectory = FileManager.default.currentDirectoryPath

        for config in xcconfigs {
            let fileAppend = config.key == "*" ? "" : ".\(config.key.lowercased())"
            let filePath = "\(currentDirectory)/ProjectEnvironment\(fileAppend).xcconfig"
            var headers: [String] = [ "// Natrium", "" ]
            if config.key != "*" {
                let directory = FileManager.default.currentDirectoryPath
                headers.append("#include \"\(directory)/ProjectEnvironment.xcconfig\"")
                headers.append("")
                _writeToOriginalXccConfigFile(configuration: config.key)
            }
            let contents = [ headers, config.value ].flatMap { $0 }.joined(separator: "\n")

            FileHelper.write(filePath: filePath, contents: contents)
        }
    }

    fileprivate func _writeToOriginalXccConfigFile(configuration: String) {
        let cdc = configuration.lowercased()
        let path = "\(natrium.projectDir)/Pods/Target Support Files/Pods-\(natrium.target)/Pods-\(natrium.target).\(cdc).xcconfig" // swiftlint:disable:this line_length
        let file = File(path: path)
        guard var contents = file.contents, file.isExisting else {
            return
        }
        var deprecatedLine = "#include \"../../Natrium/Natrium/ProjectEnvironment.\(cdc).xcconfig\"\n\n"
        contents = contents.replacingOccurrences(of: deprecatedLine, with: "")

        deprecatedLine = "#include \"../../Natrium/bin/ProjectEnvironment.\(cdc).xcconfig\"\n\n"
        contents = contents.replacingOccurrences(of: deprecatedLine, with: "")

        let line = "#include \"\(natrium.projectDir)/Pods/Natrium/bin/ProjectEnvironment.\(cdc).xcconfig\""
        if contents.contains(line) {
            return
        }
        contents = "\(line)\n\n\(contents)"
        file.chmod("7777")
        file.write(contents)
        file.touch()
        file.chmod("+x")
    }
}
