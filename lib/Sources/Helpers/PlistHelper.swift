//
//  PlistHelper.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation

class PlistHelper {
    static func getValue(`for` key: String, `in` plistFile: String) -> String? {

        guard let dic = NSDictionary(contentsOfFile: plistFile) else {
            return nil
        }
        return dic.object(forKey: key) as? String
    }
}
