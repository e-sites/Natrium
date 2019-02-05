//
//  CGFloat.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 07/02/2019.
//

import Foundation

extension CGFloat {
    var isInteger: Bool {
        return rint(self) == self
    }
}
