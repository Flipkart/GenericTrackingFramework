//
//  TrackableEntityProtocol.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import UIKit

class FrameData: NSObject {

    //TODO Implement copy

    var uniqueId: String
    var absoluteFrame: CGRect
    var impressionTracking: ImpressionTracking?
    var isWidget: Bool
    var tags: [String]?

    init(uId: String, frame: CGRect, impressionTracking: ImpressionTracking?, isWidget: Bool = false, tags: [String]? = nil) {
        
        self.uniqueId = uId
        self.absoluteFrame = frame
        self.impressionTracking = impressionTracking
        self.isWidget = isWidget
        self.tags = tags
    }
}

@objc protocol ContentTrackableEntityProtocol {

    var tracker: ScreenLevelTracker? { get }
    var trackData: FrameData? { get set }
    var isScrollable: Bool { get set }

    //the list of content that need to be tracked
    func getTrackableChildren() -> [ContentTrackableEntityProtocol]?

}
