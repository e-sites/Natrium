//
//  Yaml.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import Yaml

extension Yaml {
    var stringValue: String {
        switch self {
        case .null:
            return "nil"

        case .bool(let bool):
            return bool ? "true" : "false"

        case .int(let int):
            return "\(int)"

        case .double(let double):
            return "\(double)"

        case .string(let string):
            return string

        case .array(let array):
            return "[" + array.compactMap { $0.string }.joined(separator: ", ") + "]"
            
        case .dictionary(let dic):
            return "\(dic)"
        }
    }
}

extension Dictionary where Key == String, Value == Yaml {
    func toYaml() -> Yaml {
        var returnDictionary: [Yaml: Yaml] = [:]
        for keyValue in self {
            returnDictionary[Yaml.string(keyValue.key)] = keyValue.value
        }
        return Yaml.dictionary(returnDictionary)
    }
}
