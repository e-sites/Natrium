//
//  String.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation

typealias CaptureGroupResult = (Range<String.Index>, String)

extension String {
    func capturedGroups(withRegex pattern: String,
                        options: NSRegularExpression.Options = []) -> [CaptureGroupResult] {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            return []
        }

        guard let match = regex.matches(in: self, range: NSRange(location: 0, length: self.count)).first else {
            return []
        }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else {
            return []
        }

        return Array(1...lastRangeIndex)
            .map { match.range(at: $0) }
            .compactMap { index -> CaptureGroupResult? in

                guard let range = Range(index, in: self) else {
                    return nil
                }

                let matchedString = (self as NSString).substring(with: index)
                return (range, matchedString)
            }
    }

    func toConfigurations(with allConfigurations: [String]) -> [String] {
        let dicValueConfigurations = components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        if dicValueConfigurations.first == "*" {
            return allConfigurations
        }
        return dicValueConfigurations
    }
}
