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
    let infoPlistPath: String

    let parsers: [Parseable] = [
        XcconfigParser()
    ]

    init(natrium: Natrium, infoPlistPath: String) {
        self.natrium = natrium
        self.infoPlistPath = infoPlistPath
    }

    func run() throws {
        guard let contents = File(path: natrium.yamlFile).contents else {
            Logger.fatalError("Error reading \(natrium.yamlFile)")
            return
        }
        var yaml = try Yaml.load(contents)

        guard let environments = yaml["environments"].array else {
            throw NatriumError.generic("Missing environments in .natrium.yml")
        }

        try checkEnvironment(in: environments)
        Logger.log(" - Found environments: \(environments.compactMap { $0.string })")
        autoGenerateKeys(for: &yaml)

        var natriumVariables = try parse(yaml, key: "natrium_variables")

        _log(key: "natrium_variables", natriumVariables)
        var targetSpecific: [String: [String: NatriumValue]] = [:]
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
                _log(key: targetSpecificKey, targetSpecific[targetSpecificKey]!)
            }
            Logger.insets -= 1
            print("\(targetSpecific)")

            let variables = try _convert(yaml: yaml, key: "variables", natriumVariables: natriumVariables, targetSpecific: targetSpecific)
        }
    }

    private func _convert(yaml: Yaml, key: String, natriumVariables: [String: NatriumValue], targetSpecific: [String: [String: NatriumValue]]) throws -> [String: NatriumValue] {
        var items = try parse(yaml, key: key).merging(from: targetSpecific[key])
        for item in items {
            guard var stringValue = item.value.value.string else {
                continue
            }
            for natriumVariable in natriumVariables {
                var value = natriumVariable.value
                let stringValue = stringValue.replacingOccurrences(of: "#{\(natriumVariable.key)}", with: natriumVariable.value.stringValue)
                value.value = Yaml.string(stringValue)
            }
        }
        _log(key: key, items)
        return items
    }

    private func _log(key: String, _ obj: [String: NatriumValue]) {
        if obj.isEmpty {
            return
        }

        Logger.debug("[\(key)]")
        Logger.insets += 1
        for item in obj {
            Logger.verbose("\(item.key) = \(item.value.stringValue)")
        }
        Logger.insets -= 1
    }

    func checkEnvironment(in environments: [Yaml]) throws {
        let environments = environments.compactMap { $0.string }
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

    func parse(_ yaml: Yaml, key yamlKey: String) throws -> [String: NatriumValue] {
        if yaml == .null {
            return [:]
        }
        guard let dictionary = yaml[Yaml.string(yamlKey)].dictionary else {
            return [:]
        }
        
        var returnDictionary: [String: NatriumValue] = [:]
        for globalObj in dictionary {
            guard let key = globalObj.key.string else {
                continue
            }

            if globalObj.value.array != nil {
                throw NatriumError.generic("YAML arrays are not allowed here")
            }

            guard let globalObjDictionary = globalObj.value.dictionary else {
                returnDictionary[key] = NatriumValue(value: globalObj.value, level: .global)
                continue
            }

            for environmentObj in globalObjDictionary {
                let environmentKey = environmentObj.key.string ?? ""
                guard environmentKey.components(separatedBy: ",").contains(natrium.environment) || environmentKey == "*" else {
                    continue
                }
                
                guard let environmentObjDictionary = environmentObj.value.dictionary else {
                    returnDictionary[key] = NatriumValue(value: environmentObj.value, level: .environment)
                    continue
                }

                for configurationObj in environmentObjDictionary {
                    let configurationKey = configurationObj.key.string ?? ""
                    guard configurationKey.components(separatedBy: ",").contains(natrium.configuration) else {
                        continue
                    }
                    if yamlKey == "xcconfig" {
                        returnDictionary[key] = NatriumValue(value: environmentObj.value, level: .environment)
                        break
                    }
                    returnDictionary[key] = NatriumValue(value: configurationObj.value, level: .configuration)
                }
            }
        }

        return returnDictionary
    }
}
