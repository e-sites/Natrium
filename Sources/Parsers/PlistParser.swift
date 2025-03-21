//
//  PlistParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 11/02/2019.
//

import Foundation
import Yaml
import Francium

class PlistParser: Parseable {

    var yamlKey: String {
        return "plists"
    }

    var isRequired: Bool {
        return false
    }

    func parse(_ dictionary: [String: Yaml]) throws {
        let tmpFile = File(path: "tmp.plist")
        
        defer {
            try? tmpFile.delete()
        }
        
        if !tmpFile.isExisting {
            try tmpFile.create()
            tmpFile.chmod(0o0777)
        }
        
        let absoluteFilePath = tmpFile.absolutePath
        for plist in dictionary {
            let originalFile = File(path: "\(data.projectDir)/\(plist.key)")
            if !originalFile.isExisting {
                throw NatriumError("Cannot find plist: \(originalFile.absolutePath)")
            }
            
            guard let plistDictionary = plist.value.dictionary, !NatriumParserData.instance.dryRun else {
                continue
            }
            let originalMD5 = originalFile.md5Checksum
            try tmpFile.write(string: originalFile.contents ?? "")
            
            for keyValue in plistDictionary {
                switch keyValue.value {
                case .null:
                    PlistHelper.remove(key: keyValue.key.stringValue, in: absoluteFilePath)
                    
                case .array(let array):
                    PlistHelper.write(array: array.map { $0.stringValue }, for: keyValue.key.stringValue, in: absoluteFilePath)
                    
                default:
                    let currentValue = PlistHelper.getValue(for: keyValue.key.stringValue, in: absoluteFilePath)
                    if currentValue != keyValue.value.stringValue {
                        PlistHelper.write(value: keyValue.value.stringValue, for: keyValue.key.stringValue, in: absoluteFilePath)
                    }
                }
            }
            if tmpFile.md5Checksum != originalMD5, let newContents = tmpFile.contents {
                try originalFile.write(string: newContents)
            }
        }
    }
}
