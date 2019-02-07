//
//  FilesParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 06/02/2019.
//

import Foundation
import Yaml
import Francium

class FilesParser: Parseable {
    
    var yamlKey: String {
        return "files"
    }

    var isRequired: Bool {
        return true
    }

    func parse(_ dictionary: [String: NatriumValue]) throws {
        for file in dictionary {
            let sourceFile = File(path: "\(projectDir)/\(file.value.stringValue)")
            if !sourceFile.isExisting {
                throw NatriumError.generic("Cannot find file: \(sourceFile.absolutePath)")
            }

            let destinationFile = File(path: "\(projectDir)/\(file.key)")
            if destinationFile.isExisting {
                try destinationFile.delete()
            }
            try sourceFile.copy(to: Dir(path: destinationFile.dirName), newName: destinationFile.basename)
        }
    }
}
