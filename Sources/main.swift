//
//  main.swift
//  Natrium
//
//  Created by Bas van Kuijck on 07/06/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import Foundation
import CommandLineKit
import AppKit
import Yaml
import Francium

let environmentVariables = ProcessInfo.processInfo.environment
let commandlineArguments = Swift.CommandLine.arguments
let natrium: Natrium

var isCocoaPods = false

private func _changeCurrentWorkingDirectory(from projectDir: String) {
    var firstArgs = (commandlineArguments.first ?? "").components(separatedBy: "/")
    firstArgs.removeLast()
    let url = URL(fileURLWithPath: firstArgs.joined(separator: "/"))
    if url.path.contains("/Pods/Natrium/bin") {
        isCocoaPods = true
        FileManager.default.changeCurrentDirectoryPath(url.path)
        return
    }

    let dir = Dir(path: "\(projectDir)/.natrium")
    if !dir.isExisting {
        do {
            try dir.make()
        } catch let error {
            Logger.fatalError("Error creating dir: \(error)")
        }
    }
    FileManager.default.changeCurrentDirectoryPath(dir.absolutePath)
}

// Did natrium run from a pre-action build script?
if let projectDir = environmentVariables["PROJECT_DIR"],
   let targetName = environmentVariables["TARGET_NAME"],
   let configuration = environmentVariables["CONFIGURATION"],
   commandlineArguments.count == 2 {
    Logger.shouldPrint = false
    if commandlineArguments.isEmpty {
        Logger.fatalError("Missing environment argument")
    }
    let environment = commandlineArguments[1]
    _changeCurrentWorkingDirectory(from: projectDir)
    natrium = Natrium(projectDirPath: projectDir, targetName: targetName, configuration: configuration, environment: environment)
    natrium.run()
} else {
    let file = File(path: commandlineArguments.first!)
    var projectDirPath = file.dirName
    let urlString = projectDirPath
    var pathComponents = urlString.components(separatedBy: "/")

    if let index = pathComponents.firstIndex(of: "Pods") {
        pathComponents = Array(pathComponents[0..<index])
    } else if let index = pathComponents.firstIndex(of: "Carthage") {
        pathComponents = Array(pathComponents[0..<index])
    }

    projectDirPath = pathComponents.joined(separator: "/")

    let cli = CommandLineKit.CommandLine()

    let configOption = StringOption(shortFlag: "c",
                                    longFlag: "configuration",
                                    required: true,
                                    helpMessage: "Configuration name.")

    let environmentOption = StringOption(shortFlag: "e",
                                         longFlag: "environment",
                                         required: true,
                                         helpMessage: "Environment.")

    let targetOption = StringOption(shortFlag: "t",
                                    longFlag: "target",
                                    required: true,
                                    helpMessage: "Target name.")

    let timeOption = BoolOption(shortFlag: "n",
                                longFlag: "no_timestamp",
                                required: false,
                                helpMessage: "Hide timestamp in logs")
    cli.addOptions(configOption, environmentOption, targetOption, timeOption)

    do {
        try cli.parse()

        if timeOption.value {
            Logger.showTime = false
        }
        _changeCurrentWorkingDirectory(from: projectDirPath)
        natrium = Natrium(projectDirPath: projectDirPath,
                          targetName: targetOption.value!,
                          configuration: configOption.value!,
                          environment: environmentOption.value!)
        natrium.run()
    } catch {
        print("Natrium version: \(Natrium.version)")
        print("")
        cli.printUsage(error)
        exit(EX_USAGE)
    }

}
