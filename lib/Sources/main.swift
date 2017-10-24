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
import XcodeEdit

let dic = ProcessInfo.processInfo.environment
let natrium: Natrium

// Did natrium run from a pre-action build script?
if let projectDir = dic["PROJECT_DIR"], let targetName = dic["TARGET_NAME"], let configuration = dic["CONFIGURATION"] {
    Logger.shouldPrint = false
    if CommandLine.arguments.count < 1 {
        Logger.fatalError("Missing environment argument")
        exit(EX_USAGE)
    }
    let environment = CommandLine.arguments[1]

    // Set the currentDirectory to the current file path
    var url = URL(fileURLWithPath: CommandLine.arguments.first!)
    url.deleteLastPathComponent()
    FileManager.default.changeCurrentDirectoryPath(url.path)

    natrium = Natrium(projectDir: projectDir,
                      target: targetName,
                      configuration: configuration,
                      environment: environment)
} else {
    // Else use the cli

    let cli = CommandLineKit.CommandLine()

    let projectDirOption = StringOption(shortFlag: "p",
                                        longFlag: "project_dir",
                                        required: true,
                                        helpMessage: "Project directory.")

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

    cli.addOptions(projectDirOption, configOption, environmentOption, targetOption)

    do {
        try cli.parse()
    } catch {
        cli.printUsage(error)
        exit(EX_USAGE)
    }

    natrium = Natrium(projectDir: projectDirOption.value!,
                      target: targetOption.value!,
                      configuration: configOption.value!,
                      environment: environmentOption.value!)
}

natrium.run()
