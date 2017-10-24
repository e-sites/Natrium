//
//  Shell.swift
//  Natrium
//
//  Created by Bas van Kuijck on 07/06/2017.
//
//

import Foundation

@discardableResult
func shell(_ launchPath: String, useProxyScript: Bool = false, arguments: [String] = []) -> String? {
    if useProxyScript {
        let argumentsString = arguments.joined(separator: " ")
        let script = "#!/bin/sh\n\n\(launchPath) \(argumentsString)"
        let scriptName = "tmp_script.sh"
        let file = File.open(scriptName)
        file.write(script)
        defer {
            file.remove()
        }
        return shell("/bin/sh", arguments: [ scriptName ])
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
