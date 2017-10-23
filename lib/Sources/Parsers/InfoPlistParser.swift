//
//  InfoPlistParser.swift
//  NatriumPackageDescription
//
//  Created by Bas van Kuijck on 23/10/2017.
//

import Foundation
import Yaml

class InfoPlistParser: Parser {
    let natrium: Natrium

    var yamlKey: String {
        return "infoplist"
    }

    required init(natrium: Natrium) {
        self.natrium = natrium
    }

    func parse(_ yaml: [NatriumKey: Yaml]) {
        for object in yaml {
            PlistHelper.write(value: object.value.stringValue, for: object.key.string, in: natrium.infoPlistPath)
        }
    }
}
