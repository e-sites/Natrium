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

    private var _buildSettings: [String: Any]?

    init(buildSettings: [String: Any]?) {
        self._buildSettings = buildSettings
    }

    func parse(_ dictionary: [String: Yaml]) throws {
        guard let labelName = dictionary["labelName"]?.string else {
            throw NatriumError("No labelName given for launch-screen versioning")
        }

        guard let path = dictionary["path"]?.string else {
            throw NatriumError("No path given for launch-screen versioning")
        }

        guard var version = PlistHelper.getValue(for: "CFBundleShortVersionString", in: data.infoPlistPath) else {
            throw NatriumError("Cannot read CFBundleShortVersionString from \(data.infoPlistPath)")
        }

        let capturedGroups = version.capturedGroups(withRegex: #"\$(\{|\()(.+?)(\}|\))"#)
        if capturedGroups.count > 1 {
            let xcconfigKey = capturedGroups[1].1
            version = (_buildSettings?[xcconfigKey] as? String) ?? ""
            if version.isEmpty {
                throw NatriumError("Cannot find xcconfig key \(xcconfigKey)")
            }
        }

        let enabled = dictionary["enabled"]?.bool ?? true

        let file = File(path: "\(data.projectDir)/\(path)")
        guard file.isExisting, var contents = file.contents else {
            throw NatriumError("Cannot find launch-screen: \(path)")
        }

        let appVersion = enabled ? "v\(version)" : ""
        let pattern = "<label.+?(text=.+?)\".+?>.+?<accessibility.+?label=\"\(labelName)\""
        guard let range = contents.capturedGroups(withRegex: pattern, options: .dotMatchesLineSeparators).first?.0 else {
            return
        }
        
        contents.replaceSubrange(range, with: "text=\"\(appVersion)")
        try file.writeChanges(string: contents)
    }
}
