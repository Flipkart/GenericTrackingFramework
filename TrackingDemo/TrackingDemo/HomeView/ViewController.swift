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

    @IBOutlet weak var tableView: UITableView!
    let tracker = ScreenLevelTracker(screen: "ViewController1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped cell")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
}

