//
//  NatriumValue.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation
import Yaml

struct NatriumValue {
    enum Level {
        case global
        case environment
        case configuration
    }

    let value: Yaml
    let level: Level

    init(value: Yaml, level: Level) {
        self.value = value
        self.level = level
    }

    var stringValue: String {
        switch value {
        case .string(let string):
            return string
        case .bool(let bool):
            return bool ? "true" : "false"

        case .int(let int):
            return String(describing: int)

        case .double(let double):
            return String(describing: double)

        case .null:
            return "null"

        default:
            return "\(value)"
        }
    }
}
