//
//  TypeTwoCell.swift
//  TrackingDemo
//
//  Created by Krati Jain on 21/11/17.
//  Copyright © 2017 Flipkart. All rights reserved.
//

import Foundation
import GenericTrackingFramework

class TypeTwoCell : UITableViewCell,ContentTrackableEntityProtocol {
    
    var tracker: ScreenLevelTracker?
    var trackData: FrameData?
    var isScrollable: Bool = false
    
    @IBOutlet weak var user1ImageView: UIImageView!
    @IBOutlet weak var user2ImageView: UIImageView!
    
    @IBOutlet weak var user1NameLabel: UILabel!
    @IBOutlet weak var user2NameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(rowNo : Int){
        self.trackData = FrameData(uId: "TypeTwoCell_" + String(rowNo), frame: CGRect.zero, impressionTracking: nil)
    }
    func getTrackableChildren() -> [ContentTrackableEntityProtocol]? {
        return nil
    }
    override func didMoveToWindow() {
        if let _ = self.window {
            let absFrame = self.convert(self.bounds, to: nil)
            self.trackData?.absoluteFrame = absFrame;
        }
    }
    
}
