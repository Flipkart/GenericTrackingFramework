//
//  TrackableEntityProtocol.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import UIKit

class FrameData : NSObject{
    
    //TODO Implement copy
    
    var uniqueId : String
    var absoluteFrame : CGRect
    var wigTracking : NHPWidgetTracking?
    
    init(uId:String,frame:CGRect,wigTracking:NHPWidgetTracking?){
        self.uniqueId = uId
        self.absoluteFrame = frame
        self.wigTracking = wigTracking
    }
}

@objc protocol  ContentTrackableEntityProtocol {
    
    var tracker:ScreenLevelTracker? {get}
    var trackData : FrameData? {get set}
    var isScrollable : Bool {get set}
    
    //the list of content that need to be tracked
    func getTrackableChildren()-> [ContentTrackableEntityProtocol]?

}
