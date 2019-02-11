//
//  Logger.swift
//  Natrium
//
//  Created by Bas van Kuijck on 07/06/2017.
//
//

import Foundation
import Francium

class Logger {
    
    static var shouldPrint = true
    static var showTime = true
    static var insets: Int = 0
    static var logLines: [String] = []

    static var fileLoggingName = "natrium.log"

    private static var fileLoggingPath: String {
        return "\(FileManager.default.currentDirectoryPath)/\(fileLoggingName)"
    }

    fileprivate static var _dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()

    fileprivate static var _dateFormatterFile: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()

    @discardableResult
    fileprivate static func _log(_ line: String, color: String = "39") -> String {
        let insetString = String(repeating: "\u{00A0}\u{00A0}", count: insets)
        _fileLog(insetString + line)
        let dateString = showTime ? _dateFormatter.string(from: Date()) : ""
        let timeString = showTime ? colorWrap(text: "[\(dateString)]: ▸ ", in: "90") : ""
        let line = timeString + insetString + colorWrap(text: line, in: color)
        if shouldPrint {
            print(line)
        } else {
            logLines.append(line)
        }
        return line
    }

    static func clearLogFile() {
        try? File(path: fileLoggingPath).delete()
    }
    
    static func colorWrap(text: String, `in` color: String) -> String {
        return "\u{001B}[0;\(color)m\(text)\u{001B}[0m"
    }
    
    @discardableResult
    static func error(_ line: String) -> String {
        return _log("❌  \(line)", color: "31")
    }

    static fileprivate func _fileLog(_ line: String) {
        let dateString = _dateFormatterFile.string(from: Date())
        do {
            let regex = try NSRegularExpression(pattern: "\u{001B}\\[0(.+?|)m", options: .caseInsensitive)
            let range = NSRange(location: 0, length: line.count)
            let line = regex.stringByReplacingMatches(in: line, options: [], range: range, withTemplate: "")
            let file = File(path: fileLoggingPath)
            try file.append(string: "\(dateString) - \(line)\n")
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    @discardableResult
    static func fatalError(_ line: String) -> String {
        insets = 0
        if !shouldPrint {
            let currentDirectory = FileManager.default.currentDirectoryPath
            let filePath = "\(currentDirectory)/Config.swift"
            let contents = "#error(\"\(line)\")"
            let file = File(path: filePath)
            do {
                if file.isExisting {
                    file.chmod(0o7777)
                }
                try file.write(string: contents)
            } catch { }
        }
        _log("❌  \(line)", color: "31")
        exit(EX_USAGE)
    }
    
    @discardableResult
    static func success(_ line: String) -> String {
        return _log("✅  \(line)", color: "92")
    }
    
    @discardableResult
    static func info(_ line: String) -> String {
        return _log(line, color: "93")
    }
    
    @discardableResult
    static func warning(_ line: String) -> String {
        return _log("⚠️  \(line)", color: "38;5;208")
    }
    
    @discardableResult
    static func debug(_ line: String) -> String {
        return _log(line, color: "36")
    }
    
    @discardableResult
    static func log(_ line: String) -> String {
        return _log(line, color: "39")
    }
    
    @discardableResult
    static func verbose(_ line: String) -> String {
        return _log(line, color: "37")
    }
}

extension Logger {
    static func log(key: String, _ obj: [String: NatriumValue]) {
        if obj.isEmpty {
            return
        }

        Logger.debug("[\(key)]")
        Logger.insets += 1
        for item in obj {
            if let dic = item.value.value.dictionary {
                for dicValue in dic {
                    Logger.verbose("\(item.key):\(dicValue.key.stringValue) = \(dicValue.value.stringValue)")
                }
            } else if let array = item.value.value.array {
                let stringValue = array.compactMap { $0.string }.joined(separator: ", ")
                Logger.verbose("\(item.key) = \(stringValue)")
            } else {
                Logger.verbose("\(item.key) = \(item.value.stringValue)")
            }
        }
        Logger.insets -= 1
    }
}
