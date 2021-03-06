//
//  TrackableASNode.swift
//  Flipkart
//
//  Created by Krati Jain on 21/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

/***
 Uncomment to support tracking for ASControlNode from Async Display Kit
 ***/

/*
import Foundation
import AsyncDisplayKit

///ASControlNode which confirms the ContentTrackableEntityProtocol and hence can be tracked
class TrackableASControlNode: ASControlNode, ContentTrackableEntityProtocol {

    internal var tracker: ScreenLevelTracker?
    internal var isScrollable: Bool = false

    internal var trackData: FrameData?

    ///the list of content that need to be tracked
    func getTrackableChildren() -> [ContentTrackableEntityProtocol]? {
        return nil
    }

    ///when this node enters visible state, update its trackData with absolute frame with respect to window and track view appear event
    override func didEnterVisibleState() {
        
        //calculate absolute frame
        self.trackData?.absoluteFrame = (self.convert(self.bounds, to: nil))
        //track view appear event
        self.tracker?.trackViewAppear(trackData: trackData)
    }
}

*/
