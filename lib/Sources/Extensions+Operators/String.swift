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

        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))

        guard let match = matches.first else { return results }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }

        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)

            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            if let range = self.rangeFromNSRange(capturedGroupIndex) {
                results.append((range, matchedString))
            }
        }

        return results
    }

    func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
        return Range(nsRange, in: self)
    }

    static func random(length: Int) -> String {

        let letters: NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    var md5: String {
        return shell("/sbin/md5", arguments: [ "-q", "-s", self]) ?? self
    }
}
