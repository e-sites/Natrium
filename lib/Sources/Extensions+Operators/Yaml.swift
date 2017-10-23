//
//  Yaml.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation

import Yaml

extension Yaml {
    public var stringValue: String {
        switch self {
        case .null:
            return "nil"

        case .bool(let b):
            return b ? "true" : "false"

        case .int(let i):
            return "\(i)"

        case .double(let f):
            return "\(f)"

        case .string(let s):
            return s

        case .array(let s):
            return "[" + s.flatMap { $0.string }.joined(separator: ", ") + "]"
            
        case .dictionary(let m):
            return "\(m)"
        }
    }
}
