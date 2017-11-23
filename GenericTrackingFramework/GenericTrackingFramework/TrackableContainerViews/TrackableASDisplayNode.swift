//
//  TrackableASDisplayNode.swift
//  Flipkart
//
//  Copyright © 2017 flipkart.com. All rights reserved.
//

/***
 Uncomment to support tracking for ASDisplayNode from Async Display Kit
 ***/

/*
import Foundation

import AsyncDisplayKit

///ASDisplayNode which conforms the ContentTrackableEntityProtocol and hence can be tracked
class TrackableASDisplayNode: ASDisplayNode, ContentTrackableEntityProtocol {
    
    internal var tracker: ScreenLevelTracker?
    internal var isScrollable: Bool = false
    
    internal var trackData: FrameData?
    
    //the list of content that need to be tracked
    func getTrackableChildren() -> [ContentTrackableEntityProtocol]? {
        return nil
    }
    
    //main thread
    override func didEnterVisibleState() {
        
        //Initialising trackdata
        if trackData == nil {
            trackData = FrameData(uId: String(self.view.tag), frame: CGRect.zero, impressionTracking: nil)
        }

        //calculate absolute frame
        self.trackData?.absoluteFrame = (self.convert(self.bounds, to: nil))
        //track view appear event
        self.tracker?.trackViewAppear(trackData: trackData)
    }
}
*/
