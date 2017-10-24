//
//  NatriumYamlHelper.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import Yaml

class NatriumYamlHelper {
    let natrium: Natrium
    fileprivate var yaml: Yaml!

    var natriumVariables: [NatriumKey: Yaml] = [:]
    var targetSpecific: [String: [NatriumKey: Yaml]] = [:]
    var appIcon: [NatriumKey: Yaml] = [:]
    var misc: [String: [NatriumKey: Yaml]] = [:]

    init(natrium: Natrium) {
        self.natrium = natrium
    }

    func parse() {
        do {
            Logger.info("Parsing .natrium.yml")
            guard let contents = File.read(path: natrium.yamlFile) else {
                Logger.fatalError("Error reading \(natrium.yamlFile)")
                return
            }
            self.yaml = try Yaml.load(contents)

            _parseEnvironments()
            _parseTargetSpecific()
            _parseNatriumVariables()
            _parseAll(yaml)

        } catch let error {
            Logger.fatalError("Error parsing \(natrium.yamlFile): \(error)")
        }
    }

    private func _parseAll(_ yaml: Yaml) {
        guard let dictionary = yaml.dictionary else {
            return
        }

        for object in dictionary {
            var key = object.key.stringValue
            var yamlValue = object.value
            if key == "environments" || key == "natrium_variables"  || key == "target_specific" {
                continue
            }

            if key == "misc" {
                Logger.warning("   ⚠️  '\(key)' key is deprecated, use 'launch_screen_versioning' instead")
                key = "launch_screen_versioning"
                yamlValue = yamlValue[Yaml(stringLiteral: key)]

            } else if key == "infoplist" {
                Logger.warning("   ⚠️  '\(key)' key is deprecated, use 'plists' instead")
                key = "plists"
                yamlValue = Yaml(dictionaryLiteral: (Yaml(stringLiteral: natrium.infoPlistPath), yamlValue))
            }

            guard let parser = (natrium.parsers.filter { $0.yamlKey == key }).first else {
                Logger.warning("   ⚠️  No parsers found for '\(key)'")
                continue
            }

            let xcconfig = (key == "xcconfig")
            if !xcconfig {
                Logger.debug("   [\(key)]")
            }

            var yamlFiles: [(yaml: Yaml, filePath: String?)] = [ (yaml: yamlValue, filePath: nil) ]
            if parser is PlistParser {
                yamlFiles.removeAll()
                for plistFile in (yamlValue.dictionary ?? [:]) {
                    yamlFiles.append((yaml: plistFile.value, filePath: plistFile.key.string))
                }
            }
            for yamlFileValue in yamlFiles {
                let tmpParser: Parser? = parser
                if let filePath = yamlFileValue.filePath, let plistParser = tmpParser as? PlistParser {
                    plistParser.filePath = "\(natrium.projectDir)/\(filePath)"
                    Logger.log("     " + Logger.colorWrap(text: filePath, in: "1"))
                }

                var variablesDictionary = _parse(yamlFileValue.yaml, xcconfig: xcconfig)
                _replaceInnerVariables(key: key, &variablesDictionary)
                if !xcconfig {
                    _logDictionary(variablesDictionary)
                }
                parser.parse(variablesDictionary)
            }
        }
    }
}

extension NatriumYamlHelper {
    fileprivate func _parseEnvironments() {
        let environments = yaml["environments"].array?.flatMap { $0.string } ?? []
        if (environments.filter { $0 == self.natrium.environment }).isEmpty {
            Logger.fatalError("Environment '\(self.natrium.environment)' not available.")
            return
        }
        natrium.environments = environments
    }

    fileprivate func _parseNatriumVariables() {
        Logger.debug("   [natrium_variables]")
        natriumVariables = _parse(self.yaml["natrium_variables"])
        _logDictionary(natriumVariables)
    }

    fileprivate func _parseTargetSpecific() {
        Logger.debug("   [target_specific:\(natrium.target)]")
        
        if let targetSpecificDic = self.yaml["target_specific"].dictionary,
            let dic = targetSpecificDic[Yaml(stringLiteral: self.natrium.target)]?.dictionary {
            for object in dic {
                if object.key.stringValue == "natrium_variables" {
                    Logger.fatalError("'target_specific' cannot contain 'natrium_variables'")
                    break
                } else if object.key.stringValue == "target_specific" {
                    Logger.fatalError("'target_specific' cannot contain 'target_specific'")
                    break
                }

                var dictionary = _parse(object.value)
                _replaceInnerVariables(key: object.key.stringValue, &dictionary, replaceTargetSpecificVariables: false)
                targetSpecific[object.key.stringValue] = dictionary
                Logger.log("     " + Logger.colorWrap(text: object.key.stringValue, in: "1"))
                _logDictionary(dictionary)
            }

        } else {
            Logger.verbose("      -empty-")
        }
    }

    fileprivate func _parse(_ yaml: Yaml, xcconfig: Bool = false) -> [NatriumKey: Yaml] {
        var returnDictionary: [NatriumKey: Yaml] = [:]
        guard let dictionary = yaml.dictionary else {
            return returnDictionary
        }

        for object in dictionary {
            guard let keyStringValue = object.key.string else {
                continue
            }

            guard let environmentDictionary = object.value.dictionary else {
                returnDictionary[.global(keyStringValue)] = object.value
                continue
            }
            for environmentObject in environmentDictionary {
                guard let environmentKeyStringValue = environmentObject.key.string else {
                    continue
                }
                if environmentKeyStringValue != "*" &&
                    !environmentKeyStringValue.components(separatedBy: ",").contains(natrium.environment) {
                    continue
                }

                guard let configurationDictionary = environmentObject.value.dictionary, !xcconfig else {
                    returnDictionary[.environment(environmentKeyStringValue, keyStringValue)] = environmentObject.value
                    continue
                }

                for configurationObject in configurationDictionary {
                    guard let confKeyStringValue = configurationObject.key.string else {
                        continue
                    }
                    if confKeyStringValue.components(separatedBy: ",").contains(natrium.configuration) {
                        returnDictionary[.configuration(confKeyStringValue, keyStringValue)] = configurationObject.value
                    }
                }
            }
        }
        return returnDictionary
    }

    fileprivate func _replaceInnerVariables(key: String,
                                            _ dictionary: inout [NatriumKey: Yaml],
                                            replaceTargetSpecificVariables: Bool = true) {
        let targetSpecificDictionary: [NatriumKey: Yaml] = targetSpecific[key] ?? [:]
        for object in dictionary {
            guard var stringValue = object.value.string else {
                continue
            }

            for natriumObject in natriumVariables {
                guard let natriumStringValue = natriumObject.value.string else {
                    continue
                }
                stringValue = stringValue.replacingOccurrences(of: "#{\(natriumObject.key.string)}",
                    with: natriumStringValue)
            }

            if replaceTargetSpecificVariables {
                for tObject in targetSpecificDictionary {
                    if tObject.key.string == object.key.string, let value = targetSpecificDictionary[tObject.key] {
                        stringValue = value.stringValue
                    }
                }
            }
            dictionary[object.key] = Yaml(stringLiteral: stringValue)
        }
    }

    fileprivate func _logDictionary(_ dic: [NatriumKey: Yaml]) {
        if dic.keys.isEmpty {
            Logger.verbose("      -empty-")
        }
        for o in dic {
            Logger.log("      \(o.key.string) = \(o.value.stringValue)")
        }
    }
}
