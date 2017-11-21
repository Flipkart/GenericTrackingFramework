//
//  ViewController.swift
//  TrackingDemo
//
//  Created by Krati Jain on 21/11/17.
//  Copyright © 2017 Flipkart. All rights reserved.
//

import UIKit
import GenericTrackingFramework

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tracker = ScreenLevelTracker(screen: "homeScreen")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

