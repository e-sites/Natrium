//
//  Parseable.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation
import Yaml

protocol Parseable {
    var yamlKey: String { get }
    var isRequired: Bool { get }

    func parse(_ yaml: Yaml) throws
}
