//
//  NatriumParserData.swift
//  Natrium
//
//  Created by Bas van Kuijck on 22/02/2019.
//

import Foundation

class NatriumParserData {
    static var instance = NatriumParserData()

    var configurations: [String] = []
    var configuration: String = ""
    var environments: [String] = []
    var environment: String = ""
    var target: String = ""
    var projectDir: String = ""
    var infoPlistPath: String = ""
    var dryRun: Bool = false

    init(factory: ((NatriumParserData) -> Void)? = nil) {
        factory?(self)
    }
}
