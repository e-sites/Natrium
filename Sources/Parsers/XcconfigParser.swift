//
//  XcconfigParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation
import Yaml

class XcconfigParser: Parseable {
    var yamlKey: String {
        return "xcconfig"
    }

    var isRequired: Bool {
        return true
    }

    func parse(_ yaml: Yaml) throws {

    }
}
