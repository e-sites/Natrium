//
//  EnvironmentVariables.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 11/02/2019.
//

import Foundation
import Francium

class EnvironmentVariables {
    /// Environment variables
    ///
    /// Merges `ProcessInfo.processInfo.environment` with `.env` and `.natrium-env` files
    ///
    /// - parameters:
    ///   - projectDir: `String` the project directory path
    ///
    /// - returns: `[String: String]` Key value dictionary with environment variables
    static func get(from projectDir: String) -> [String: String] {
        var returnDictionary = ProcessInfo.processInfo.environment

        let lines = [ ".natrium-env", ".env" ]
            .map { File(path: "\(projectDir)/\($0)") }
            .filter { $0.isExisting }
            .compactMap { $0.contents }
            .flatMap { $0.components(separatedBy: "\n") }

        for line in lines {
            let keyValue = line.split(separator: "=", maxSplits: 1).map(String.init)
            guard keyValue.count == 2 else {
                continue
            }
            let key = keyValue[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let value = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
            returnDictionary[key] = value
        }

        return returnDictionary
    }
}
