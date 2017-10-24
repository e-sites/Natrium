//
//  NatriumKey.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import Yaml

enum NatriumKey: Hashable, CustomStringConvertible {
    case global(String)
    case environment(String, String)
    case configuration(String, String)

    var hashValue: Int {
        return description.hashValue
    }

    var string: String {

        switch self {
        case .global(let string):
            return string

        case .environment(_, let string):
            return string

        case .configuration(_, let string):
            return string
        }
    }

    static func == (lhs: NatriumKey, rhs: NatriumKey) -> Bool {
        return lhs.description == rhs.description
    }

    var description: String {
        switch self {
        case .global(let string):
            return "global_\(string)"

        case .environment(let environment, let string):
            return "environment_\(environment)_\(string)"

        case .configuration(let configuration, let string):
            return "configuration_\(configuration)_\(string)"
        }
    }
}
