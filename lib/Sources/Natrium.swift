//
//  Natrium.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import XcodeEdit

class Natrium {

    let projectDir: String
    let configuration: String
    let environment: String
    let target: String
    var infoPlistPath: String!
    var environments: [String] = []
    var configurations: [String] = []
    var appVersion: String = "1.0"
    var xcProjectFile: XCProjectFile!
    var xcTarget: PBXTarget!

    var xcodeProjectPath: String!

    lazy fileprivate var yamlHelper: NatriumYamlHelper = {
        return NatriumYamlHelper(natrium: self)
    }()

    lazy var parsers: [Parser] = {
        return [
            SwiftVariablesParser(natrium: self),
            XccConfigParser(natrium: self),
            AppIconParser(natrium: self),
            LaunchScreenStoryboardParser(natrium: self),
            InfoPlistParser(natrium: self),
            FilesParser(natrium: self)
        ]
    }()

    init(projectDir: String, target: String, configuration: String, environment: String) {
        self.projectDir = Dir.dirName(path: projectDir)
        self.target = target
        self.configuration = configuration
        self.environment = environment
    }

    func run() {
        if !File.exists(at: yamlFile) {
            Logger.fatalError("Cannot find \(yamlFile)")
        }

        guard let xcodeProjectPath = Dir.glob("\(projectDir)/*.xcodeproj").first else {
            Logger.fatalError("Cannot find xcodeproj in folder '\(projectDir)'")
            return
        }
        self.xcodeProjectPath = xcodeProjectPath
        _getXcodeProject()
        _getInfoPlistFile()

        if let version = PlistHelper.getValue(for: "CFBundleShortVersionString", in: infoPlistPath) {
            self.appVersion = version
        }
        yamlHelper.parse()

        Logger.success("Natrium ▸ Success!")
        print(Logger.logLines.joined(separator: "\n"))
        Logger.logLines.removeAll()
    }
}

extension Natrium {
    var yamlFile: String {
        return "\(projectDir)/.natrium.yml"
    }
}

extension Natrium {
    fileprivate func _getXcodeProject() {
        let xcodeproj = URL(fileURLWithPath: xcodeProjectPath)
        do {
            xcProjectFile = try XCProjectFile(xcodeprojURL: xcodeproj)
        } catch let error {
            Logger.fatalError("\(error)")
            return
        }

        guard let target = (xcProjectFile.project.targets.filter { $0.name == self.target }).first else {
            Logger.fatalError("Cannot find target '\(self.target)' in '\(xcodeProjectPath)'")
            return
        }

        self.configurations = target.buildConfigurationList.buildConfigurations.map { $0.name }
        self.xcTarget = target
    }

    fileprivate func _getInfoPlistFile() {
        guard let buildConfiguration = (xcTarget.buildConfigurationList.buildConfigurations
            .filter { $0.name == self.configuration }).first else {
                Logger.fatalError("Cannot find configuration '\(self.configuration)' in '\(xcodeProjectPath)'")
                return
        }
        guard let infoPlist = buildConfiguration.buildSettings?["INFOPLIST_FILE"] else {
            Logger.fatalError("Cannot find INFOPLIST_FILE in '\(xcodeProjectPath)'")
            return
        }

        infoPlistPath = "\(projectDir)/\(infoPlist)"

        if !File.exists(at: infoPlistPath) {
            Logger.fatalError("Cannot find \(infoPlistPath)")
        }
    }
}
