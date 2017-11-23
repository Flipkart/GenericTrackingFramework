//
//  TrackableEvents.swift
//  Flipkart
//
//  Created by Krati Jain on 15/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

///Trackable Event Names
public class EventNames: NSObject {
    public static let viewWillDisplay = "viewWillDisplay"
    public static let viewStarted = "viewStarted"
    public static let viewEnded = "viewEnded"
    public static let visibilityChange = "visibilityChange"
    public static let scroll = "scroll"
    public static let contentClick = "contentClick"
    public static let contentEngagement = "contentEngagement"
    public static let video = "video"
    public static let dataChange = "dataChange"
}

///Represents any event which fires tracking related changes
public class TrackableEvent: NSObject {

    ///Event Name
    var eventType: String
    
    ///Event Specific Data
    var eventData: EventData?

    ///default init where data is nil
    init(_ eventName: String) {

        self.eventType = eventName
        self.eventData = nil
    }

    ///custom data with specified event name
    init(eventType: String, eventData: EventData?) {

        self.eventType = eventType
        self.eventData = eventData
    }
}
