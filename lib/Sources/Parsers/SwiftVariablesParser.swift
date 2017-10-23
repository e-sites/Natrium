//
//  NatriumConfigSwiftHelper.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import Yaml

class SwiftVariablesParser: Parser {

    let natrium: Natrium

    var yamlKey: String {
        return "variables"
    }

    required init(natrium: Natrium) {
        self.natrium = natrium
    }

    private let preservedVariableNames = [ "environment", "configuration" ]

    func parse(_ yaml: [NatriumKey: Yaml]) {
        var lines: [String] = []
        lines.append("import Foundation")
        lines.append("")
        lines.append("public class Config {")
        lines.append("    public enum EnvironmentType: String {")
        for environment in natrium.environments {
            lines.append("        case \(environment.lowercased()) = \"\(environment)\"")
        }
        lines.append("    }")
        lines.append("")
        lines.append("    public enum ConfigurationType: String {")

        for config in natrium.configurations {
            lines.append("        case \(config.lowercased()) = \"\(config)\"")
        }
        lines.append("    }")
        lines.append("")
        lines.append("    public static let environment: EnvironmentType = .\(natrium.environment.lowercased())")
        lines.append("    public static let configuration: ConfigurationType = .\(natrium.configuration.lowercased())")
        lines.append("")
        for object in yaml {
            if preservedVariableNames.contains(object.value.stringValue) {
                Logger.fatalError("\(object.value.stringValue) is a reserved variable name")
            }
            let type: String
            var value = object.value.stringValue
            switch object.value {
            case .int:
                type = "Int"
            case .double:
                type = "Double"
            case .bool:
                type = "Bool"
            default:
                type = "String"
                value = "\"\(object.value.stringValue)\""
            }
            lines.append("    public static let \(object.key.string): \(type) = \(value)")
        }
        lines.append("}")
        let contents = lines.joined(separator: "\n")

        let currentDirectory = FileManager.default.currentDirectoryPath
        let filePath = "\(currentDirectory)/Config.swift"
        FileHelper.write(filePath: filePath, contents: contents)
    }
}
