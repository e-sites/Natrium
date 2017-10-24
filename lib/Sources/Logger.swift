//
//  Logger.swift
//  Natrium
//
//  Created by Bas van Kuijck on 07/06/2017.
//
//

import Foundation

class Logger {
    
    static var shouldPrint = true
    
    static var insets: Int = 0
    
    static var logLines: [String] = []
    
    fileprivate static var _dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    @discardableResult
    fileprivate static func _log(_ line: String,
                                 color: String = "39") -> String {
        let dateString = _dateFormatter.string(from: Date())
        let line = colorWrap(text: "[\(dateString)]: ▸ ", in: "90") +
            String(repeating: "  ", count: insets) +
            colorWrap(text: line, in: color)
        
        if shouldPrint {
            print(line)
        } else {
            logLines.append(line)
        }
        return line
    }
    
    static func colorWrap(text: String, `in` color: String) -> String {
        return "\u{001B}[0;\(color)m\(text)\u{001B}[0m"
    }
    
    @discardableResult
    static func error(_ line: String) -> String {
        return _log("❌  \(line)", color: "31")
    }
    
    @discardableResult
    static func fatalError(_ line: String) -> String {
        insets = 0
        if !shouldPrint {
            let currentDirectory = FileManager.default.currentDirectoryPath
            let filePath = "\(currentDirectory)/Config.swift"
            let contents = "### NATRIUM ERROR ###\n\n\"\(line)\"\n\nSolve this and rebuild"
            FileHelper.write(filePath: filePath, contents: contents)
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
        return _log("⚠️  \(line)", color: "40;38;5;215")
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
