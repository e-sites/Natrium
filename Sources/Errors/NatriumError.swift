//
//  NatriumError.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation

struct NatriumError: Error, CustomStringConvertible {
    private let string: String

    init(_ string: String) {
        self.string = string
    }

    var description: String {
        return string
    }
}
