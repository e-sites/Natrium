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

if CommandLine.arguments.isEmpty {
    exit(EX_NOINPUT)
}

var url = URL(fileURLWithPath: CommandLine.arguments.first!)
url.deleteLastPathComponent()
FileManager.default.changeCurrentDirectoryPath(url.path)

// Did natrium run from a pre-action build script?
if let projectDir = dic["PROJECT_DIR"], let targetName = dic["TARGET_NAME"], let configuration = dic["CONFIGURATION"] {
    Logger.shouldPrint = false
    if CommandLine.arguments.count < 1 {
        Logger.fatalError("Missing environment argument")
        exit(EX_NOINPUT)
    }
    let environment = CommandLine.arguments[1]

    // Set the currentDirectory to the current file path

    natrium = Natrium(projectDir: projectDir,
                      target: targetName,
                      configuration: configuration,
                      environment: environment)
// ./natrium install
} else if CommandLine.arguments.count == 2 && CommandLine.arguments[1] == "install" {

    if !NatriumLock.file.isExisting {
        Logger.warning("Natrium.lock file not created yet, run natrium with the correct arguments")
        exit(EX_USAGE)
    }
    guard let tmpNatrium = NatriumLock.getNatrium() else {
        Logger.fatalError("Error parsing Natrium.lock")
        exit(EX_USAGE)
    }
    natrium = tmpNatrium

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
        print("Natrium version: \(Natrium.version)")
        print("")
        cli.printUsage(error)
        exit(EX_USAGE)
    }

    natrium = Natrium(projectDir: projectDirOption.value!,
                      target: targetOption.value!,
                      configuration: configOption.value!,
                      environment: environmentOption.value!)
}

natrium.run()
