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
if dic["PROJECT_DIR"] != nil && dic["TARGET_NAME"] != nil && dic["CONFIGURATION"] != nil {
    Logger.shouldPrint = false
    if CommandLine.arguments.count < 1 {
        Logger.fatalError("Missing environment")
        exit(EX_USAGE)
    }
    let environment = CommandLine.arguments[1]

    var url = URL(fileURLWithPath: CommandLine.arguments.first!)
    url.deleteLastPathComponent()
    FileManager.default.changeCurrentDirectoryPath(url.path)

    natrium = Natrium(projectDir: dic["PROJECT_DIR"]!,
                      target: dic["TARGET_NAME"]!,
                      configuration: dic["CONFIGURATION"]!,
                      environment: environment)
} else {

    let cli = CommandLineKit.CommandLine()

    let projectDirOption = StringOption(shortFlag: "p",
                                        longFlag: "project_dir",
                                        required: false,
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
