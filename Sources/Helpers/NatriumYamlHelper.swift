//
//  NatriumYamlHelper.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import Yaml
import Francium

class NatriumYamlHelper {
    let natrium: Natrium
    fileprivate var yaml: Yaml!

    var natriumVariables: [NatriumKey: Yaml] = [:]
    var targetSpecific: [String: [NatriumKey: Yaml]] = [:]
    var targetFileSpecific: [String: [String: [NatriumKey: Yaml]]] = [:]
    var appIcon: [NatriumKey: Yaml] = [:]
    var settings: [Yaml: Yaml] = [:]

    init(natrium: Natrium) {
        self.natrium = natrium
    }

    func parse() {
        do {
            Logger.info("Parsing \(natrium.yamlFile)")
            Logger.insets += 1
            guard let contents = File(path: natrium.yamlFile).contents else {
                Logger.fatalError("Error reading \(natrium.yamlFile)")
                return
            }
            yaml = try Yaml.load(contents)

            // Auto create keys
            // This needs to be done, else target_specific values will not work
            let keys = natrium.parsers.filter { !$0.isOptional }.map { Yaml(stringLiteral: $0.yamlKey) }
            for key in keys where yaml[key] == nil {
                yaml[key] = Yaml(nilLiteral: ())
            }

            _parseEnvironments()
            _parseSettings()
            _parseNatriumVariables()
            _parseTargetSpecific()
            _parseAll(yaml)

        } catch let error {
            Logger.insets = 0
            Logger.fatalError("Error parsing \(natrium.yamlFile): \(error)")
        }
    }

    private func _parseAll(_ yaml: Yaml) { // swiftlint:disable:this function_body_length
        guard let dictionary = yaml.dictionary else {
            return
        }
        Logger.insets = 1

        let reservedKeys = [ "environments", "natrium_variables", "settings", "target_specific" ]
        var parsersNotDone = natrium.parsers
            .filter { $0.isRequired }
            .map { $0.yamlKey }

        for object in dictionary {
            var key = object.key.stringValue
            var yamlValue = object.value
            if reservedKeys.contains(key) {
                continue
            }

            if key == "misc" {
                Logger.warning("'\(key)' key is deprecated, use 'launch_screen_versioning' instead")
                key = "launch_screen_versioning"
                yamlValue = yamlValue[Yaml(stringLiteral: "launchScreenStoryboard")]

            } else if key == "infoplist" {
                Logger.warning("'\(key)' key is deprecated, use 'plists' instead")
                key = "plists"
                yamlValue = Yaml(dictionaryLiteral: (Yaml(stringLiteral: natrium.infoPlistPath), yamlValue))
            }

            guard let parser = (natrium.parsers.first { $0.yamlKey == key }) else {
                Logger.warning("No parsers found for '\(key)'")
                continue
            }

            parsersNotDone = parsersNotDone.filter { $0 != key }

            let xcconfig = (key == "xcconfig")
            Logger.insets = 1
            if !xcconfig {
                Logger.debug("[\(key)]")
            }

            var yamlFiles: [_YamlFile] = [ _YamlFile(yaml: yamlValue) ]
            if parser is PlistParser {
                yamlFiles.removeAll()
                for plistFile in (yamlValue.dictionary ?? [:]) {
                    yamlFiles.append(_YamlFile(yaml: plistFile.value, filePath: plistFile.key.string))
                }

                for plistFile in (targetFileSpecific["plists"] ?? [:]) {
                    var yamlDic: [Yaml: Yaml] = [:]
                    for obj in plistFile.value {
                        yamlDic[Yaml(stringLiteral: obj.key.string)] = obj.value
                    }
                    if let findFile = (yamlFiles.first { $0.filePath == plistFile.key }) {
                        var dic = findFile.yaml.dictionary ?? [:]
                        for copyObj in yamlDic {
                            dic[copyObj.key] = copyObj.value
                        }

                        findFile.yaml = Yaml.dictionary(dic)
                    } else {
                        yamlFiles.append(_YamlFile(yaml: Yaml.dictionary(yamlDic), filePath: plistFile.key))
                    }
                }
            }

            for yamlFileValue in yamlFiles {
                let tmpParser: Parser? = parser
                Logger.insets = 1
                if let filePath = yamlFileValue.filePath, let plistParser = tmpParser as? PlistParser {
                    Logger.insets += 1
                    plistParser.filePath = "\(natrium.projectDir)/\(filePath)"
                    Logger.log(Logger.colorWrap(text: filePath, in: "1"))
                }

                Logger.insets += 1

                var variablesDictionary = _parse(yamlFileValue.yaml, xcconfig: xcconfig)
                _replaceInnerVariables(key: key, &variablesDictionary)
                if !xcconfig {
                    _logDictionary(variablesDictionary)
                }
                parser.parse(variablesDictionary)
            }
        }
        Logger.insets = 1

        let parsers = natrium.parsers.filter { parsersNotDone.contains($0.yamlKey) }
        for parser in parsers {
            _logSection(parser.yamlKey)
            parser.parse([:])
            _logDictionary([:])
        }
    }
}

extension NatriumYamlHelper {
    fileprivate func _logSection(_ name: String) {
        Logger.insets = 1
        Logger.debug("[\(name)]")
        Logger.insets = 2
    }

    fileprivate func _parseEnvironments() {
        _logSection("environments")
        let environments = yaml["environments"].array?.compactMap { $0.string } ?? []
        if (environments.filter { $0 == self.natrium.environment }).isEmpty {
            Logger.fatalError("Environment '\(self.natrium.environment)' not available.")
            return
        }
        for environment in environments {
            Logger.log(" - \(environment)")
        }
        natrium.environments = environments
    }

    fileprivate func _parseSettings() {
        _logSection("settings")
        defer {
            if settings.isEmpty {
                Logger.verbose("-empty-")
            }
        }
        guard let settingsDictionary = yaml["settings"].dictionary else {
            return
        }
        let availableSettings = [ "class_name" ]
        for object in settingsDictionary {
            if !availableSettings.contains(object.key.stringValue) {
                Logger.warning("'\(object.key.stringValue)' is not a valid setting")
                continue
            }
            settings[object.key] = object.value
            Logger.log("\(object.key.stringValue) = \(object.value.stringValue)")
        }
    }

    fileprivate func _parseNatriumVariables() {
        _logSection("natrium_variables")
        natriumVariables = _parse(self.yaml["natrium_variables"])
        _logDictionary(natriumVariables)
        if let targetSpecificDic = self.yaml["target_specific"].dictionary,
            let dic = targetSpecificDic[Yaml(stringLiteral: self.natrium.target)]?.dictionary,
            let targetSpecificNatriumVariablesDic = dic["natrium_variables"] {
            let targetSpecificNatriumVariables = _parse(targetSpecificNatriumVariablesDic)
            for (key, value) in targetSpecificNatriumVariables {
                natriumVariables[key] = value
            }

        }
    }

    fileprivate func _parseTargetSpecific() {
        _logSection("target_specific:\(natrium.target)")

        if let targetSpecificDic = self.yaml["target_specific"].dictionary,
            let dic = targetSpecificDic[Yaml(stringLiteral: self.natrium.target)]?.dictionary {
            for object in dic {
                Logger.log(Logger.colorWrap(text: object.key.stringValue, in: "1"))
                if object.key.stringValue == "target_specific" {
                    Logger.fatalError("'target_specific' cannot contain 'target_specific'")
                    break
                } else if object.key.stringValue == "plists" {
                    if let plistDic = object.value.dictionary {
                        for plistObj in plistDic {
                            var dictionary = _parse(plistObj.value)
                            _replaceInnerVariables(key: plistObj.key.stringValue, &dictionary,
                                                   replaceTargetSpecificVariables: false)
                            Logger.insets += 1
                            _logDictionary(dictionary)
                            Logger.insets -= 1
                            let filePath = plistObj.key.stringValue
                            if targetFileSpecific[object.key.stringValue] == nil {
                                targetFileSpecific[object.key.stringValue] = [:]
                            }
                            targetFileSpecific[object.key.stringValue]![filePath] = dictionary
                        }
                    }
                    continue
                }

                var dictionary = _parse(object.value, xcconfig: object.key.stringValue == "xcconfig")
                _replaceInnerVariables(key: object.key.stringValue, &dictionary, replaceTargetSpecificVariables: false)
                targetSpecific[object.key.stringValue] = dictionary
                Logger.insets += 1
                _logDictionary(dictionary)
                Logger.insets -= 1
            }
        } else {
            Logger.verbose("-empty-")
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
        for object in dictionary {
            var yamlValue = object.value

            for natriumObject in natriumVariables {
                guard let natriumStringValue = natriumObject.value.string else {
                    continue
                }

                if var yamlDictionary = yamlValue.dictionary {
                    for yamlDicObject in yamlDictionary {
                        guard var stringValue = yamlDicObject.value.string else {
                            continue
                        }

                        stringValue = stringValue.replacingOccurrences(of: "#{\(natriumObject.key.string)}",
                            with: natriumStringValue)
                        yamlDictionary[yamlDicObject.key] = Yaml(stringLiteral: stringValue)
                        yamlValue = Yaml.dictionary(yamlDictionary)
                    }
                }

                if yamlValue.string != nil,
                    let stringValue = yamlValue.string?.replacingOccurrences(of: "#{\(natriumObject.key.string)}",
                    with: natriumStringValue) {
                    yamlValue = Yaml(stringLiteral: stringValue)
                }
            }

            dictionary[object.key] = yamlValue
        }

        if !replaceTargetSpecificVariables {
            return
        }

        let targetSpecificDictionary: [NatriumKey: Yaml] = targetSpecific[key] ?? [:]
        for tObject in targetSpecificDictionary {
            var found = false
            for dicObject in dictionary where dicObject.key == tObject.key {
                found = true
                if let dicObjectDic = dicObject.value.dictionary, let tObjectDic = tObject.value.dictionary {
                    dictionary[dicObject.key] = Yaml.dictionary(dicObjectDic.merging(tObjectDic) { (_, new) in new })
                } else {
                    dictionary[dicObject.key] = tObject.value
                }
            }

            if found {
                continue
            }

            for dicObject in dictionary where dicObject.key.string == tObject.key.string {
                dictionary[dicObject.key] = tObject.value
            }
        }
    }

    fileprivate func _logDictionary(_ dic: [NatriumKey: Yaml]) {
        if dic.keys.isEmpty {
            Logger.verbose("-empty-")
        }
        for obj in dic {
            Logger.log("\(obj.key.string) = \(obj.value.stringValue)")
        }
    }
}

private class _YamlFile {
    let filePath: String?
    var yaml: Yaml = Yaml.dictionary([:])

    init(yaml: Yaml, filePath: String? = nil) {
        self.yaml = yaml
        self.filePath = filePath
    }
}
