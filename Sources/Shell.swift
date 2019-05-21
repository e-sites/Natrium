//
//  Shell.swift
//  Natrium
//
//  Created by Bas van Kuijck on 07/06/2017.
//
//

import Foundation
import Francium

enum Shell {
    @discardableResult
    static func execute(_ launchPath: String, useProxyScript: Bool = false, arguments: [String] = []) -> String? {
        if useProxyScript {
            let argumentsString = arguments.joined(separator: " ")
            let script = "#!/bin/sh\n\n\(launchPath) \(argumentsString)"
            let scriptName = "._\(UUID().uuidString).sh"
            do {
                let file = File(path: scriptName)
                if !file.isExisting {
                    try file.create()
                }
                defer {
                    try? file.delete()
                }
                try file.write(string: script)

                return execute("/bin/sh", arguments: [ scriptName ])
            } catch {
                return execute(launchPath, arguments: arguments)
            }
        }
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        task.waitUntilExit()
        return output
    }
}
