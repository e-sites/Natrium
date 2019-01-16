//
//  Natrium.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import XcodeEdit
import Yaml
import Francium

class Natrium {
    static var version: String = "7.0.0"

    let projectDirPath: String
    let targetName: String
    let configuration: String
    let environment: String

    var yamlFile: String {
        return "\(projectDirPath)/.natrium.yml"
    }

    init(projectDirPath: String, targetName: String, configuration: String, environment: String) {
        self.projectDirPath = projectDirPath
        self.targetName = targetName
        self.configuration = configuration
        self.environment = environment

        Logger.log(Logger.colorWrap(text: "Running Natrium installer (v\(Natrium.version))", in: "1"))
        Logger.log("")

        Logger.info("Configuration:")
        Logger.log(" - project path: \(projectDirPath)")
        Logger.log(" - target name: \(targetName)")
        Logger.log(" - configuration: \(configuration)")
        Logger.log(" - environment: \(environment)")
        Logger.info("")

        preconditionChecks()
    }

    func preconditionChecks() {
        if !File(path: yamlFile).isExisting {
            Logger.fatalError("Cannot find \(yamlFile)")
        }
        
        do {
            let xcodeTarget = try _getXcodeProject()
            let infoPlistPath = try _getInfoPlistFile(from: xcodeTarget)
            Logger.info("Project configuration:")
            Logger.log(" - Xcode target name: \(xcodeTarget.name)")
            Logger.log(" - Info.plist path: \(infoPlistPath)")
            Logger.info("")
            Logger.info("Parsing \(yamlFile)...")

            let parser = NatriumParser(natrium: self, infoPlistPath: infoPlistPath)
            try parser.run()
        } catch let error {
            Logger.fatalError("\(error)")
        }
    }
}

extension Natrium {
    fileprivate func _getXcodeProject() throws -> PBXNativeTarget {
        guard let xcodeProjectPath = Dir(path: projectDirPath).glob("*.xcodeproj").first?.path else {
            throw NatriumError.generic("Cannot find xcodeproj in folder '\(projectDirPath)'")
        }
        let xcodeproj = URL(fileURLWithPath: xcodeProjectPath)
        let xcProjectFile = try XCProjectFile(xcodeprojURL: xcodeproj)

        guard let target = (xcProjectFile.project.targets.first { $0.name == self.targetName }) else {
            throw NatriumError.generic("Cannot find target '\(self.targetName)' in '\(xcodeProjectPath)'")
        }

        return target
    }

    fileprivate func _getInfoPlistFile(from xcTarget: PBXNativeTarget) throws -> String {
        guard let buildConfiguration = (xcTarget.buildConfigurationList.buildConfigurations
            .first { $0.name == self.configuration }) else {
                throw NatriumError.generic("Cannot find configuration '\(self.configuration)' in '\(xcTarget.name)'")
        }

        guard let infoPlist = buildConfiguration.buildSettings?["INFOPLIST_FILE"] as? String else {
            throw NatriumError.generic("Cannot find INFOPLIST_FILE in '\(xcTarget.name)'")
        }

        let infoPlistPath = _replaceSettingsReferences(infoPlist)

        if !File(path: infoPlistPath).isExisting {
            throw NatriumError.generic("Cannot find \(String(describing: infoPlistPath))")
        }

        return infoPlistPath
    }

    private func _replaceSettingsReferences(_ string: String) -> String {
        let mapping: [String: String] = [
            "SRCROOT": projectDirPath,
            "PROJECT_DIR": projectDirPath
        ]

        var string = string
        for (key, value) in mapping {
            string = string
                .replacingOccurrences(of: "$(\(key))", with: value)
                .replacingOccurrences(of: "${\(key)}", with: value)
                .replacingOccurrences(of: "$\(key)", with: value)
        }
        if !string.hasPrefix(projectDirPath) {
            string = "\(projectDirPath)/\(string)"
        }
        return string
    }
}
