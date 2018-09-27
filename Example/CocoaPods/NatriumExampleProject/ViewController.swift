//
//  ViewController.swift
//  NatriumExampleProject
//
//  Created by Bas van Kuijck on 11-05-16.
//  Copyright © 2016 E-sites. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Bundle identifier: \(Bundle.main.bundleIdentifier!)")
        print("Environment: \(Natrium.Config.environment)")
    }
}
