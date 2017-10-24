//
//  InfoPlistParser.swift
//  NatriumPackageDescription
//
//  Created by Bas van Kuijck on 23/10/2017.
//

import Foundation
import Yaml

class PlistParser: Parser {
    let natrium: Natrium

    var yamlKey: String {
        return "plists"
    }

    var filePath: String!

    required init(natrium: Natrium) {
        self.natrium = natrium
    }

    func parse(_ yaml: [NatriumKey: Yaml]) {
        if !File(path: filePath).isExisting {
            Logger.fatalError("\(filePath!) does not exist")
            return
        }
        for object in yaml {
            PlistHelper.write(value: object.value.stringValue, for: object.key.string, in: filePath)
        }
    }
}
