//
//  FilesParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 06/02/2019.
//

import Foundation
import Yaml

class FilesParser: Parseable {
    
    var yamlKey: String {
        return "files"
    }

    var isRequired: Bool {
        return true
    }

    func parse(_ dictionary: [String: NatriumValue]) throws {

    }
}
