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

private var targetKey: Int = 0
private var projectDirKey: Int = 0
private var environmentsKey: Int = 0
private var configurationsKey: Int = 0
private var environmentKey: Int = 0
private var configurationKey: Int = 0
private var infoPlistPathKey: Int = 0

extension Parseable {
    var environments: [String] {
        get {
            return objc_getAssociatedObject(self, &environmentsKey) as? [String] ?? []
        }
        set {
            objc_setAssociatedObject(self, &environmentsKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var configurations: [String] {
        get {
            return objc_getAssociatedObject(self, &configurationsKey) as? [String] ?? []
        }
        set {
            objc_setAssociatedObject(self, &configurationsKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var configuration: String {
        get {
            return objc_getAssociatedObject(self, &configurationKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &configurationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var environment: String {
        get {
            return objc_getAssociatedObject(self, &environmentKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &environmentKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var target: String {
        get {
            return objc_getAssociatedObject(self, &targetKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &targetKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var projectDir: String {
        get {
            return objc_getAssociatedObject(self, &projectDirKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &projectDirKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var infoPlistPath: String {
        get {
            return objc_getAssociatedObject(self, &infoPlistPathKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &infoPlistPathKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
