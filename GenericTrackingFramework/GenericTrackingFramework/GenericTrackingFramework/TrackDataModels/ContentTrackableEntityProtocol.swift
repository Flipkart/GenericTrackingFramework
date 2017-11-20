//
//  TrackableEntityProtocol.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import UIKit

@objc public class FrameData: NSObject {

    //TODO Implement copy

    var uniqueId: String
    @objc public var absoluteFrame: CGRect
    var impressionTracking: ImpressionTracking?
    var isWidget: Bool
    var tags: Set<String>?
    var additionalInfo : NSDictionary? = nil
    
    @objc public init(uId: String, frame: CGRect, impressionTracking: ImpressionTracking?, isWidget: Bool = false, tags: Set<String>? = nil) {

        self.uniqueId = uId
        self.absoluteFrame = frame
        self.impressionTracking = impressionTracking
        self.isWidget = isWidget
        self.tags = tags
    }
}

//Any view that wants to be tracked should implement this protocol
@objc public protocol ContentTrackableEntityProtocol {

    //tracker for calling tracking related methods
    var tracker: ScreenLevelTracker? { get }
    
    //every view will have its own trackData which will later be consumed after event processing
    var trackData: FrameData? { get set }
    
    //flag to denote whether this view is scrollable and trackable, so that its data source/delegate callbacks can be tracked
    var isScrollable: Bool { get set }

    //the list of child views that need to be tracked and follow ContentTrackableEntityProtocol
    func getTrackableChildren() -> [ContentTrackableEntityProtocol]?

}
