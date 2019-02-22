//
//  Parseable.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation
import Yaml

protocol Parseable: class {
    var yamlKey: String { get }
    var isRequired: Bool { get }
    var data: NatriumParserData { get }

    func parse(_ dictionary: [String: Yaml]) throws
}

extension Parseable {
    var data: NatriumParserData {
        return NatriumParserData.instance
    }
}
