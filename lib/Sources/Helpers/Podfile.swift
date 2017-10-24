//
//  Podfile.swift
//  Natrium
//
//  Created by Bas van Kuijck on 24/10/2017.
//

import Foundation

class Podfile {
    let natrium: Natrium

    init(natrium: Natrium) {
        self.natrium = natrium
    }

    func write() {
        let podFile = File(path: "\(natrium.projectDir)/Podfile")
        if !podFile.isExisting {
            return
        }
        guard let contents = podFile.contents else {
            return
        }

        let tab = "    "

        let script = "system(\"Pods/Natrium/bin/natrium install --silent-fail\")"
        if contents.contains(script) {
            return
        }

        let postInstallDef = "post_install do"
        var lines = contents.components(separatedBy: "\n")
        var postInstallLine: Int?
        for (index, line) in lines.enumerated() {
            if line.contains(postInstallDef) {
                postInstallLine = index
                break
            }
        }

        if let writeLine = postInstallLine {
            lines.insert("\(tab)\(script)", at: writeLine + 1)
        } else {
            lines.append(contentsOf: [
                "",
                "\(postInstallDef) |installer|",
                "\(tab)\(script)",
                "end"
                ])
        }
        podFile.write(lines.joined(separator: "\n"))
        Logger.success("Written './natrium reload' to Podfile post_install hook")
    }
}
