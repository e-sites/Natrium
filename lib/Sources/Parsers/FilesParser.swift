//
//  FilesParser.swift
//  Natrium
//
//  Created by Bas van Kuijck on 23/10/2017.
//

import Foundation
import Yaml

class FilesParser: Parser {
    let natrium: Natrium

    var yamlKey: String {
        return "files"
    }

    required init(natrium: Natrium) {
        self.natrium = natrium
    }

    func parse(_ yaml: [NatriumKey: Yaml]) {
        for object in yaml {
            let readFile = File(path: "\(natrium.projectDir)/\(object.value.stringValue)")
            if !readFile.isExisting {
                Logger.fatalError("\(readFile.path) does not exist")
                break
            }
            let writeFile = File(path: "\(natrium.projectDir)/\(object.key.string)")
            if writeFile.isExisting {
                writeFile.remove()
            }
            readFile.copy(to: writeFile)
            writeFile.touch()
        }
    }
}
