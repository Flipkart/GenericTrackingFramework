//
//  TypeOneCell.swift
//  TrackingDemo
//
//  Created by Krati Jain on 21/11/17.
//  Copyright © 2017 Flipkart. All rights reserved.
//

import Foundation
import GenericTrackingFramework

class TypeOneCell : UITableViewCell,ContentTrackableEntityProtocol {
    
    var tracker: ScreenLevelTracker?
    var trackData: FrameData?
    var isScrollable: Bool = false
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(rowNo : Int){
        self.trackData = FrameData(uId: "TypeOneCell_" + String(rowNo), frame: CGRect.zero, impressionTracking: nil)
    }
    
    func getTrackableChildren() -> [ContentTrackableEntityProtocol]? {
        return nil
    }
    
    @IBAction func didTapConnect(_ sender: UIButton) {
        
    }
    
    override func didMoveToWindow() {
        if let _ = self.window {
            let absFrame = self.convert(self.bounds, to: nil)
            self.trackData?.absoluteFrame = absFrame;
        }
    }
    
}
