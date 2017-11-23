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

    @IBOutlet weak var tableView: TrackableUITableView!
    let tracker = ScreenLevelTracker(screen: "ViewController1")
    let typeOneCellId = "TypeOneCell"
    let typeTwoCellId = "TypeTwoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupTable()
    }

    func setupTable() {
        tableView.register(UINib(nibName : typeOneCellId, bundle: nil), forCellReuseIdentifier: typeOneCellId)
        tableView.register(UINib(nibName : typeTwoCellId, bundle: nil), forCellReuseIdentifier: typeTwoCellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tracker.trackViewHierarchyFor(view: self.tableView, event: EventNames.viewWillDisplay, scrollTag: nil, parentId: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tracker.trackViewHierarchyFor(view: self.tableView, event: EventNames.viewEnded, scrollTag: nil, parentId: nil)
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
        if indexPath.row % 2 == 0 {
            return 175
        } else {
            return 122
        }
    }
    
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: typeOneCellId) as? TypeOneCell {
                cell.setData(rowNo: indexPath.row)
                return cell
            }
        }
        
        if indexPath.row % 2 != 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: typeTwoCellId) as? TypeTwoCell {
                cell.setData(rowNo: indexPath.row)
                cell.user1ImageView.layer.cornerRadius = 5
                cell.user2ImageView.layer.cornerRadius = 5
                return cell
            }
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
}

