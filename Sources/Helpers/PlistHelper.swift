//
//  PlistHelper.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 11/02/2019.
//

import Foundation

enum PlistHelper {
    static func getValue(`for` key: String, `in` plistFile: String) -> String? {

        guard let dic = NSDictionary(contentsOfFile: plistFile) else {
            return nil
        }
        return dic.object(forKey: key) as? String
    }

    static func write(value: String, `for` key: String, `in` plistFile: String) {
        let exists = Shell.execute("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
            "-c", "\"Print :\(key)\"",
            "\"\(plistFile)\"",
            "2>/dev/null"
            ]) ?? ""

        if exists.isEmpty {
            Shell.execute("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
                "-c", "\"Add :\(key) string \(value)\"",
                "\"\(plistFile)\""
                ])
        } else {

            Shell.execute("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
                "-c", "\"Set :\(key) \(value)\"",
                "\"\(plistFile)\""
                ])
        }
    }
}
