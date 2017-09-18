//
//  NodeInfo.swift
//  Flipkart
//
//  Created by Krati Jain on 22/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//this holds the tracking data corresponding to each trackable view in view hierarchy for every screen
public class NodeInfo: NSObject {

    var screen: String
    internal var absoluteFrame: CGRect

    //whether this is a scrollable view whose data source events need to be tracked
    var isScrollView: Bool = false
    
    //id of the parent view in the hierarchy
    var parentId: String?
    
    //id of the first scrollable trackable view in the parent view hierarchy
    internal var affectingScrollViewTag: String?
    
    //Tracking Data for this node
    var trackingData: TrackingData

    init(uniqueId: String, screen: String, eventSourceTag: String?, frame: CGRect, impressionTracking: ImpressionTracking?, isWidget: Bool = false, tags: Set<String>? = nil, additionalInfo : NSDictionary? = nil) {

        self.trackingData = TrackingData(uniqueId: uniqueId, impressionTracking: impressionTracking, isWidget: isWidget, tags: tags, additionalInfo : additionalInfo)
        self.screen = screen
        self.affectingScrollViewTag = eventSourceTag
        self.absoluteFrame = frame
    }

    //to be invoked when converting viewEvents to TrackData
    init?(from event: TrackableEvent) {

        guard let data = event.eventData as? ViewEventData else {
            return nil
        }

        self.screen = data.screen
        self.trackingData = TrackingData(uniqueId: data.uniqueId, impressionTracking: data.impressionTracking, isWidget: data.isWidget, tags: data.tags, additionalInfo : data.additionalInfo)
        self.affectingScrollViewTag = data.affectingScrollTag
        self.absoluteFrame = data.absoluteFrame
        self.isScrollView = data.isScrollView
        self.parentId = data.parentId
    }
}
