//
//  FilesParser.swift
//  Natrium
//
//  Created by Bas van Kuijck on 23/10/2017.
//

import Foundation
import Francium
import Yaml

class FilesParser: Parser {
    let natrium: Natrium
    
    var isRequired: Bool {
        return false
    }

    var isOptional: Bool {
        return false
    }

    var yamlKey: String {
        return "files"
    }

    required init(natrium: Natrium) {
        self.natrium = natrium
    }

    func parse(_ yaml: [NatriumKey: Yaml]) {
        do {
        for object in yaml {
            let readFile = File(path: "\(natrium.projectDir)/\(object.value.stringValue)")
            if !readFile.isExisting {
                Logger.fatalError("\(readFile.path) does not exist")
                break
            }
            let dir = Dir(path: natrium.projectDir)
            let writeFile = File(path: "\(natrium.projectDir)/\(object.key.string)")
            if writeFile.isExisting {
                try writeFile.delete()
            }
            try readFile.copy(to: dir, newName: object.key.string)
        }
        } catch { }
    }
}
