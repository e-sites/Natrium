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
    
    static func write(value: String, `for` key: String, `in` plistFile: String) {
        let notAvailableString = "--~na~--"
        let exists = shell("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
            "-c", "\"Print :\(key)\"",
            plistFile,
            "2>/dev/null",
            "||", "printf '\(notAvailableString)'"
            ])
        if exists == notAvailableString {
            shell("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
                "-c", "\"Add :\(key) string \(value)\"",
                plistFile
                ])
        } else {
            shell("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
                "-c", "\"Set :\(key) \(value)\"",
                plistFile
                ])
        }
    }
}
