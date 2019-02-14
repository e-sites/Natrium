//
//  NatriumParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation
import Yaml
import Francium

class NatriumParser {
    let natrium: Natrium
    let configurations: [String]
    let infoPlistPath: String

    lazy var environmentVariables = EnvironmentVariables.get(from: natrium.projectDirPath)

    let parsers: [Parseable] = [
        XcconfigParser(),
        SwiftVariablesParser(),
        FilesParser(),
        AppIconParser(),
        PlistParser(),
        LaunchScreenParser()
    ]

    init(natrium: Natrium, infoPlistPath: String, configurations: [String]) {
        self.configurations = configurations
        self.natrium = natrium
        self.infoPlistPath = infoPlistPath
    }

    /// This is the 'main' function that tries to parse the .natrium.yml file.
    /// Within several steps.
    func run() throws {

        /// -- Read the .natrium.yml file and create a `YAML` instance of it
        guard let contents = File(path: natrium.yamlFile).contents else {
            throw NatriumError.generic("Error reading \(natrium.yamlFile)")
        }
        var yaml = try Yaml.load(contents)

        /// -- Check if `environments is filled in in .natrium.yml
        guard let environments = (yaml["environments"].array?.compactMap { $0.string }) else {
            throw NatriumError.generic("Missing environments in .natrium.yml")
        }

        try checkEnvironment(in: environments)
        Logger.debug("[environments]")
        for environment in environments {
            Logger.log("  - \(environment)")
        }

        /// -- Auto fill keys (empty values) in the yaml
        autoGenerateKeys(for: &yaml)

        /// -- Parse the natrium variables and extend them with target_specific natrium_variables
        var natriumVariables = try parse(yaml, key: "natrium_variables")

        Logger.log(key: "natrium_variables", natriumVariables)
        var targetSpecific: [String: [String: Yaml]] = [:]
        if let targetSpecificDictionary = yaml["target_specific"][Yaml.string(natrium.targetName)].dictionary {
            Logger.debug("[target_specific]")
            Logger.insets += 1
            Logger.log(Logger.colorWrap(text: natrium.targetName, in: "4;1"))
            Logger.insets += 1
            for targetSpecificObj in targetSpecificDictionary {
                guard let targetSpecificKey = targetSpecificObj.key.string else {
                    continue
                }

                targetSpecific[targetSpecificKey] = try parse(Yaml.dictionary(targetSpecificDictionary), key: targetSpecificKey)
                Logger.log(key: targetSpecificKey, targetSpecific[targetSpecificKey]!)
            }
            Logger.insets -= 1
            if let natriumVariablesTargetSpecific = targetSpecific["natrium_variables"] {
                natriumVariables.merge(natriumVariablesTargetSpecific) { _, new in new }
            }
        }

        /// -- Parse each individual entry for the YAML obejct
        for parser in parsers {
            parser.projectDir = natrium.projectDirPath
            parser.configurations = configurations
            parser.environments = environments
            parser.infoPlistPath = infoPlistPath
            parser.target = natrium.targetName
            parser.configuration = natrium.configuration
            parser.environment = natrium.environment
            
            let convertedValue = try _convert(yaml: yaml, key: parser.yamlKey, natriumVariables: natriumVariables, targetSpecific: targetSpecific)
            try parser.parse(convertedValue)
        }
    }

    /// Transform a dictionary or string by using the `natrium_variables` and `target_specific` entries
    ///
    /// - parameters:
    ///   - yaml: `YAML` The main yaml object (.natrium.yml)
    ///   - key: `String` The key of the yaml to parse (e.g. "xcconfig")
    ///   - natriumVariables: `[String: Yaml]` A dictionary containing all the available `natrium_variables`
    ///   - targetSpecific: `[String: [String: Yaml]]` Target specific values
    ///
    /// - throws:
    ///   - Parse errors -> @see parse(_, key:)
    ///
    /// - returns:
    ///   - `[String: Yaml]`
    private func _convert(yaml: Yaml,
                          key: String,
                          natriumVariables: [String: Yaml],
                          targetSpecific: [String: [String: Yaml]]) throws -> [String: Yaml] {
        var items = try parse(yaml, key: key).merging(targetSpecific[key] ?? [:]) { _, new in new }

        for item in items {
            if var stringValue = item.value.string {
                stringValue = _replaceEnvironmentVariables(in: _replaceNatriumVariables(in: stringValue, natriumVariables))
                try _errorCheck(for: stringValue, key: "\(key).\(item.key)")
                items[item.key] = Yaml.string(stringValue)

            } else if var dic = item.value.dictionary {
                for dicValue in dic {
                    guard var dicStringValue = dicValue.value.string else {
                        continue
                    }
                    dicStringValue = _replaceEnvironmentVariables(in: _replaceNatriumVariables(in: dicStringValue, natriumVariables))
                    try _errorCheck(for: dicStringValue, key: "\(key).\(dicValue.key.stringValue)")
                    dic[dicValue.key] = Yaml.string(dicStringValue)
                }
                items[item.key] = Yaml.dictionary(dic)
            } else {
                try _errorCheck(for: item.value.stringValue, key: "\(key).\(item.key)")
                items[item.key] = item.value
            }
        }
        Logger.log(key: key, items)
        return items
    }

    private func _errorCheck(for string: String, key: String) throws {
        if string == "#error" {
            throw NatriumError.generic("#error in \(key)")
        }
    }

    private func _replaceNatriumVariables(in string: String, _ natriumVariables: [String: Yaml]) -> String {
        var string = string
        for natriumVariable in natriumVariables {
            string = string.replacingOccurrences(of: "#{\(natriumVariable.key)}", with: natriumVariable.value.stringValue)
        }

        return string
    }

    private func _replaceEnvironmentVariables(in string: String) -> String {
        let matches = string.capturedGroups(withRegex: "#env\\((.+?)\\)")
        if matches.isEmpty {
            return string
        }

        var string = string
        matches.forEach { _, matchString in
            guard let value = self.environmentVariables[matchString] else {
                Logger.fatalError("Cannot find environment variable: '\(matchString)'")
                return
            }
            string = string.replacingOccurrences(of: "#env(\(matchString))", with: value)
        }

        return string
    }

    func checkEnvironment(in environments: [String]) throws {
        let environment = natrium.environment
        if (environments.filter { $0 == environment }).isEmpty {
            throw NatriumError.generic("Environment '\(environment)' not available. Available environments: \(environments)")
        }
    }

    func autoGenerateKeys(for yaml: inout Yaml) {
        for parser in parsers where parser.isRequired {
            let yamlKey = Yaml.string(parser.yamlKey)
            if yaml[yamlKey] == nil {
                yaml[yamlKey] = Yaml.dictionary([:])
            }
        }
    }

    /// Convert a yaml entry (for a specific key) into a dictionary
    ///
    /// - parameters:
    ///   - yaml: `YAML`
    ///   - key: `String`
    ///
    /// - throws:
    ///   - Array values are not allowed directly after a main key (e.g. natrium_variables)
    ///
    /// - returns: `[String: Yaml]`
    func parse(_ yaml: Yaml, key yamlKey: String) throws -> [String: Yaml] {
        if yaml == .null {
            return [:]
        }
        guard let dictionary = yaml[Yaml.string(yamlKey)].dictionary else {
            return [:]
        }

        var returnDictionary: [String: Yaml] = [:]
        if yamlKey == "plists" {
            for plistDic in dictionary {
                let plistValue = try parse(Yaml.dictionary(dictionary), key: plistDic.key.stringValue)
                returnDictionary[plistDic.key.stringValue] = plistValue.toYaml()
            }
            return returnDictionary
        }
        for globalObj in dictionary {
            guard let key = globalObj.key.string else {
                continue
            }

            if globalObj.value.array != nil && yamlKey != "appicon" {
                throw NatriumError.generic("YAML arrays are not allowed at a global level")
            }

            guard let globalObjDictionary = globalObj.value.dictionary else {
                returnDictionary[key] = globalObj.value
                continue
            }

            for environmentObj in globalObjDictionary {
                let environmentKey = environmentObj.key.string ?? ""
                guard environmentKey.components(separatedBy: ",").contains(natrium.environment) || environmentKey == "*" else {
                    continue
                }
                
                guard let environmentObjDictionary = environmentObj.value.dictionary else {
                    returnDictionary[key] = environmentObj.value
                    continue
                }

                for configurationObj in environmentObjDictionary {
                    let configurationKey = configurationObj.key.string ?? ""
                    guard configurationKey.components(separatedBy: ",").contains(natrium.configuration) else {
                        continue
                    }
                    if yamlKey == "xcconfig" {
                        returnDictionary[key] = environmentObj.value
                        break
                    }
                    returnDictionary[key] = configurationObj.value
                }
            }
        }

        return returnDictionary
    }
}
