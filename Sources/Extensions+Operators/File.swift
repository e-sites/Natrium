//
//  File.swift
//  
//
//  Created by George Kiriy on 24.11.2019.
//

import Foundation
import Francium

extension File {
    var data: Data? {
        return try? read()
    }
}
