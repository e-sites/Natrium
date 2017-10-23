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
        let script = "#!/bin/sh\n\n\(launchPath) \(arguments.joined(separator: " "))"
        let scriptName = "tmp_script.sh"
        let file = File.open(scriptName)
        file.write(script)
        let returnString = shell("/bin/sh", arguments: [ scriptName ])
        file.remove()
        return returnString
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
