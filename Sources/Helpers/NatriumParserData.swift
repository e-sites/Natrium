//
//  NatriumParserData.swift
//  Natrium
//
//  Created by Bas van Kuijck on 22/02/2019.
//

import Foundation

struct NatriumParserData {
    var configurations: [String] = []
    var configuration: String = ""
    var environments: [String] = []
    var environment: String = ""
    var target: String = ""
    var projectDir: String = ""
    var infoPlistPath: String = ""

    init(factory: ((inout NatriumParserData) -> Void)? = nil) {
        factory?(&self)
    }
}
