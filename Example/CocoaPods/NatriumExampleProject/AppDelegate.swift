//
//  AppDelegate.swift
//  NatriumExampleProject
//
//  Created by Bas van Kuijck on 11-05-16.
//  Copyright © 2016 E-sites. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("testVariableString: '\(Natrium.Config.testVariableString)'")
        return true
    }
}

