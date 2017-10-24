//
//  LaunchScreenStoryboardParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 23/10/2017.
//

import Foundation
import Yaml

class LaunchScreenStoryboardParser: Parser {
    let natrium: Natrium

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
        print(yaml)
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

        guard var contents = pathFile.contents else {
            return
        }

        let regex = "<label(.+?)text=('|\")(.+?)('|\")(.+?|)>(.+?|)<accessibility(.+?)label=('|\")LaunchscreenVersionLabel('|\")" // swiftlint:disable:this line_length

        let options = NSRegularExpression.Options([ .caseInsensitive, .dotMatchesLineSeparators ])
        let groups = contents.capturedGroups(withRegex: regex, options: options)
        if groups.count == 9 {
            let v = groups[2]
            let text = enabled ? "v\(self.natrium.appVersion)" : ""
            contents = contents.replacingOccurrences(of: v.1, with: text, options: [], range: v.0)
            pathFile.write(contents)
        }
    }
}
