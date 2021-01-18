//
//  SettingsParser.swift
//  Natrium
//
//  Created by Bas van Kuijck on 10/12/2020.
//

import Foundation
import Yaml

class Settings {
    fileprivate static var dictionary: [String: Yaml] = [:]
    
    static var stringType: String {
        return dictionary["stringType"]?.string ?? "String"
    }
}

class SettingsParser: Parseable {
    
    var yamlKey: String {
        return "settings"
    }
    
    var isRequired: Bool {
        return false
    }
    
    func parse(_ dictionary: [String: Yaml]) throws {
        Settings.dictionary = dictionary
    }
}
