//
//  Parseable.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation
import Yaml

protocol Parseable: class {
    var yamlKey: String { get }
    var isRequired: Bool { get }

    func parse(_ dictionary: [String: Yaml]) throws
}

private var natriumDataKey: Int = 0

extension Parseable {
    var data: NatriumParserData {
        get {
            return objc_getAssociatedObject(self, &natriumDataKey) as? NatriumParserData ?? NatriumParserData()
        }
        set {
            objc_setAssociatedObject(self, &natriumDataKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
