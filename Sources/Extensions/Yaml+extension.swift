//
//  Yaml+extension.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation

extension Dictionary where Key == String, Value == NatriumValue {
    
    func merging(from sourceDictionary: [Key: Value]?, onlyOverwriteExisting: Bool = true) -> [Key: Value] {
        guard let sourceDictionary = sourceDictionary else {
            return self
        }
//        if onlyOverwriteExisting {
//            var returnDictionary = self
//            for key in keys {
//                if let value = sourceDictionary[key] {
//                    returnDictionary[key] = value
//                }
//            }
//            return returnDictionary
//        }
        return self.merging(sourceDictionary) { (_, new) in new }
    }
}
