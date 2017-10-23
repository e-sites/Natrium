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

    static private let logFile = File(path: "/Users/bvkuijck/Desktop/natrium.log")

    static var logLines: [String] = []

    fileprivate static var _dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()

    private static var exceptionLogFile: File = {
        return File(path: "\(FileManager.default.currentDirectoryPath)/results.log")
    }()

    static func setup() {
        exceptionLogFile.remove()
    }

    @discardableResult
    fileprivate static func _log(_ line: String,
                                 color: String = "39") -> String {
        let dateString = _dateFormatter.string(from: Date())
        let line = colorWrap(text: "[\(dateString)]: ▸ ", in: "90") + colorWrap(text: line, in: color)
        if !logFile.isExisting {
            logFile.write("")
        }
        if let data = "\(line)\n".data(using: .utf8), let fileHandle = FileHandle(forWritingAtPath: logFile.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        }

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
        return _log(line, color: "31")
    }

    @discardableResult
    static func fatalError(_ line: String) -> String {
        if !shouldPrint {
            let contents = "warning: [Natrium] \(line)\n"
            exceptionLogFile.write(contents)
        }
        _log(line, color: "31")
        exit(EX_USAGE)
    }
    
    @discardableResult
    static func success(_ line: String) -> String {
        return _log(line, color: "92")
    }

    @discardableResult
    static func info(_ line: String) -> String {
        return _log(line, color: "93")
    }

    @discardableResult
    static func warning(_ line: String) -> String {
        return _log(line, color: "40;38;5;215")
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
