//
//  NatriumExampleProjectTests.swift
//  NatriumExampleProjectTests
//
//  Created by Bas van Kuijck on 26/10/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import XCTest
import UIKit

@testable import NatriumExampleProject

class NatriumExampleProjectTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testEnvironment() {
        XCTAssertEqual(Natrium.Config.environment, Natrium.Environment.production)
    }

    func testConfiguration() {
        XCTAssertEqual(Natrium.Config.configuration, Natrium.Configuration.debug)
    }

    func testCustomVariables() {
        XCTAssertNil(Natrium.Config.nilVariable)
        XCTAssertEqual(Natrium.Config.testVariableDouble, 5.5)
        XCTAssertEqual(Natrium.Config.testVariableString, "debugString")
        XCTAssertEqual(Natrium.Config.testVariableBoolean, false)
        XCTAssertEqual(Natrium.Config.testVariableInteger, 125)
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
