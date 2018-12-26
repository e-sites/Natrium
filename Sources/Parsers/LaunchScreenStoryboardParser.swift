//
//  LaunchScreenStoryboardParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 23/10/2017.
//

import Foundation
import Yaml
import Francium

class LaunchScreenStoryboardParser: Parser {
    let natrium: Natrium
    var isRequired: Bool {
        return false
    }

    var isOptional: Bool {
        return true
    }

    var yamlKey: String {
        return "launch_screen_versioning"
    }

    required init(natrium: Natrium) {
        self.natrium = natrium
    }

    func parse(_ yaml: [NatriumKey: Yaml]) {
        var labelName: String = ""
        var enabled: Bool = true
        var pathFile: File!
        for object in yaml {
            switch object.key.string {
            case "path":
                if let value = object.value.string {
                    pathFile = File(path: "\(natrium.projectDir)/\(value)")
                }
            case "labelName":
                if let value = object.value.string {
                    labelName = value
                }
            case "enabled":
                if let value = object.value.bool {
                    enabled = value
                }
            default:
                break
            }
        }

        if !enabled {
            return
        }

        if pathFile == nil {
            Logger.fatalError("Missing 'path' parameter for 'launch_screen_versioning' key")
            return
        }

        if labelName.isEmpty {
            Logger.fatalError("Missing 'labelName' parameter for 'launch_screen_versioning' key")
            return
        }
        if !pathFile!.isExisting {
            Logger.fatalError("'\(pathFile!.path)' does not exist")
            return
        }
        _run(labelName: labelName, pathFile: pathFile)
    }

    private func _run(labelName: String, pathFile: File) {

        guard var contents = pathFile.contents else {
            return
        }
        var pattern = "<label.+?text=('|\")(.+?)('|\")(.+?|)>.+?>(.+?)</label>"
        let options = NSRegularExpression.Options([ .caseInsensitive, .dotMatchesLineSeparators ])

        do {
            var regex = try NSRegularExpression(pattern: pattern, options: options)

            var matches = regex.matches(in: contents,
                                        options: [],
                                        range: NSRange(location: 0, length: contents.count))
            for match in matches {
                guard let range = Range(match.range, in: contents) else {
                    continue
                }
                let subContents = String(contents[range])
                pattern = "<label.+?text=('|\")(.+?|)('|\").+?>.+?<accessibility.+?label=('|\")\(labelName)('|\")(.+?|)/>.+?</label>" // swiftlint:disable:this line_length
                regex = try NSRegularExpression(pattern: pattern, options: options)
                matches = regex.matches(in: subContents,
                                        options: [],
                                        range: NSRange(location: 0, length: subContents.count))

                guard let subMatch = matches.first, subMatch.numberOfRanges == 7 else {
                    continue
                }

                guard let versionRange = Range(subMatch.range(at: 2), in: subContents) else {
                    continue
                }

                let matchedString = String(subContents[versionRange])
                let newSubContents = subContents.replacingOccurrences(of: matchedString,
                                                               with: "v\(natrium.appVersion)",
                                                               options: [],
                                                               range: versionRange)

                contents = contents.replacingOccurrences(of: subContents,
                                                         with: newSubContents,
                                                         options: [],
                                                         range: range)
                if pathFile.isExisting {
                    pathFile.chmod(0o7777)
                }
                try pathFile.write(string: contents)
                return
            }
        } catch let error {
            Logger.error("\(error)")
        }
    }
}
