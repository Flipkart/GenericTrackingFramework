//
//  TrackableASNode.swift
//  Flipkart
//
//  Created by Krati Jain on 21/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import AsyncDisplayKit

//ASControlNode which confirms the ContentTrackableEntityProtocol and hence can be tracked
class TrackableASControlNode: ASControlNode, ContentTrackableEntityProtocol {

    internal var tracker: ScreenLevelTracker?
    internal var isScrollable: Bool = false

    internal var trackData: FrameData?

    //the list of content that need to be tracked
    func getTrackableChildren() -> [ContentTrackableEntityProtocol]? {
        return nil
    }

    //main thread
    override func didEnterVisibleState() {
        
        //calculate absolute frame
        self.trackData?.absoluteFrame = (self.convert(self.bounds, to: nil))
        //track view appear event
        self.tracker?.trackViewAppear(trackData: trackData)
    }

}
