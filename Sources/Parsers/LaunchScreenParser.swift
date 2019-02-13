//
//  LaunchScreenParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 12/02/2019.
//

import Foundation
import Yaml
import Francium

class LaunchScreenParser: Parseable {

    var yamlKey: String {
        return "launch_screen_versioning"
    }

    var isRequired: Bool {
        return false
    }

    func parse(_ dictionary: [String: Yaml]) throws {
        guard let labelName = dictionary["labelName"]?.string else {
            throw NatriumError.generic("No labelName given for launch-screen versioning")
        }

        guard let path = dictionary["path"]?.string else {
            throw NatriumError.generic("No path given for launch-screen versioning")
        }

        guard let version = PlistHelper.getValue(for: "CFBundleShortVersionString", in: infoPlistPath) else {
            throw NatriumError.generic("Cannot read CFBundleShortVersionString from \(infoPlistPath)")
        }

        let enabled = dictionary["enabled"]?.bool ?? true

        let file = File(path: "\(projectDir)/\(path)")
        guard file.isExisting, var contents = file.contents else {
            throw NatriumError.generic("Cannot find launch-screen: \(path)")
        }

        let appVersion = enabled ? "v\(version)" : ""
        let pattern = "<label.+?(text=.+?)\".+?>.+?<accessibility.+?label=\"\(labelName)\""
        guard let range = contents.capturedGroups(withRegex: pattern, options: .dotMatchesLineSeparators).first?.0 else {
            return
        }
        
        contents.replaceSubrange(range, with: "text=\"\(appVersion)")
        try file.write(string: contents)
    }
}
