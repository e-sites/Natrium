//
//  Parser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import Yaml

protocol Parser {
    var natrium: Natrium { get }
    var yamlKey: String { get }
    init(natrium: Natrium)
    func parse(_ yaml: [NatriumKey: Yaml])
}
