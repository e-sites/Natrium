//
//  NatriumParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation
import Yaml
import Francium

class NatriumParser {
    let natrium: Natrium
    let infoPlistPath: String
    var yaml: Yaml!

    init(natrium: Natrium, infoPlistPath: String) {
        self.natrium = natrium
        self.infoPlistPath = infoPlistPath
    }

    func run() throws {
        try preconditionChecks()
    }

    func preconditionChecks() throws {
        guard let contents = File(path: natrium.yamlFile).contents else {
            Logger.fatalError("Error reading \(natrium.yamlFile)")
            return
        }
        yaml = try Yaml.load(contents)
    }
}
