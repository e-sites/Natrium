//
//  NatriumError.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 16/01/2019.
//

import Foundation

enum NatriumError: Error, CustomStringConvertible {
    case generic(String)

    var description: String {
        switch self {
        case .generic(let string):
            return string
        }
    }
}
