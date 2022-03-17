//
//  PlistHelper.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 11/02/2019.
//

import Foundation

enum PlistHelper {
    static func getValue(`for` key: String, in plistFile: String) -> String? {

        guard let dic = NSDictionary(contentsOfFile: plistFile) else {
            return nil
        }
        return dic.object(forKey: key) as? String
    }
    
    private static func getValueType(_ value: String) -> String {
        if value == "true" || value == "false" {
            return "bool"
        } else if Int(value) != nil {
            return "integer"
        } else {
            return "string"
        }
    }

    static func write(value: String, `for` key: String, in plistFile: String) {
        let exists = Shell.execute("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
            "-c", "\"Print :\(key)\"",
            "\"\(plistFile)\"",
            "2>/dev/null"
            ]) ?? ""

        if exists.isEmpty {
            let type = getValueType(value)
            Shell.execute("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
                "-c", "\"Add :\(key) \(type) \(value)\"",
                "\"\(plistFile)\""
            ])
        } else {

            Shell.execute("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
                "-c", "\"Set :\(key) \(value)\"",
                "\"\(plistFile)\""
            ])
        }
    }

    static func write(array: [String], `for` key: String, in plistFile: String) {
        remove(key: key, in: plistFile)

        Shell.execute("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
            "-c", "\"Add :\(key) array\"",
            "\"\(plistFile)\""
        ])

        for value in array {
            let type = getValueType(value)
            Shell.execute("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
                "-c", "\"Add :\(key): \(type) \(value)\"",
                "\"\(plistFile)\""
            ])
        }
    }

    static func remove(key: String, in plistFile: String) {
        Shell.execute("/usr/libexec/PlistBuddy", useProxyScript: true, arguments: [
            "-c", "\"Delete :\(key)\"",
            "\"\(plistFile)\""
        ])
    }
}
