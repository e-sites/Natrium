//
//  String.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation

infix operator =~

/**
 Regular expression match

 let match = ("ABC123" =~ "[A-Z]{3}[0-9]{3}") // true
 */
func =~ (string: String, regex: String) -> Bool {
    return string.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
}

extension String {
    func capturedGroups(withRegex pattern: String,
                        options: NSRegularExpression.Options = []) -> [(Range<String.Index>, String)] {
        var results: [(Range<String.Index>, String)] = []

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            return results
        }

        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))

        guard let match = matches.first else {
            return results
        }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else {
            return results
        }

        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)

            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            if let range = Range(capturedGroupIndex, in: self) {
                results.append((range, matchedString))
            }
        }

        return results
    }

    var md5: String {
        return (shell("/sbin/md5", arguments: [ "-q", "-s", self]) ?? self)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
    }
}
