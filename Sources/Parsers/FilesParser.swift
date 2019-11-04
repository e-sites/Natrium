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

    func parse(_ dictionary: [String: Yaml]) throws {
        for file in dictionary {
            let sourceFile = File(path: "\(data.projectDir)/\(file.value.stringValue)")
            if !sourceFile.isExisting {
                throw NatriumError("Cannot find file: \(sourceFile.absolutePath)")
            }

            let destinationFile = File(path: "\(data.projectDir)/\(file.key)")

            let dataIsDifferent = destinationFile.data != sourceFile.data
            let destinationExists = destinationFile.isExisting

            if destinationExists && dataIsDifferent {
                try destinationFile.delete()
            }

            if dataIsDifferent {
                try sourceFile.copy(to: Dir(path: destinationFile.dirName), newName: destinationFile.basename)
            }
        }
    }
}
