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
        let destinationExists = destinationFile.isExisting
        var dataIsDifferent = true
        if !sourceFile.isDirectory {
            dataIsDifferent = destinationFile.data != sourceFile.data
        }
        if !dataIsDifferent || NatriumParserData.instance.dryRun {
            continue
        }
        if destinationExists {
            try destinationFile.delete()
        }
        let dir = Dir(path: destinationFile.dirName)
        if !dir.isDirectory {
            try dir.make()
        }
        try sourceFile.copy(to: dir, newName: destinationFile.basename)
    }
}
}
