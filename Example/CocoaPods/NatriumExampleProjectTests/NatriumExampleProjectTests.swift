//
//  NatriumExampleProjectTests.swift
//  NatriumExampleProjectTests
//
//  Created by Bas van Kuijck on 26/10/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import XCTest
import UIKit
import Natrium
@testable import NatriumExampleProject

class NatriumExampleProjectTests: XCTestCase {

    let config = Natrium.Config.self

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testEnvironment() {
        XCTAssertEqual(config.environment, Natrium.Config.EnvironmentType.production)
    }

    func testConfiguration() {
        XCTAssertEqual(config.configuration, Natrium.Config.ConfigurationType.debug)
    }

    func testCustomVariables() {
        XCTAssertNil(config.nilVariable)
        XCTAssertEqual(config.testVariableDouble, 5.5)
        XCTAssertEqual(config.testVariableString, "debugString")
        XCTAssertEqual(config.testVariableBoolean, false)
        XCTAssertEqual(config.testVariableInteger, 125)
    }

    func testBundleIdentifier() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, "com.esites.app.production")
    }

    func testFile() {
        let bundle = Bundle(for: ViewController.self)
        guard let file = bundle.path(forResource: "file", ofType: "html") else {
            XCTAssert(false, "file.html not found")
            return
        }

        guard let contents = try? String(contentsOfFile: file) else {
            XCTAssert(false, "file.html has not contents")
            return
        }

        XCTAssert(contents.contains("PRODUCTION!"))
    }
}
