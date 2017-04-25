//
//  TrackableEvents.swift
//  Flipkart
//
//  Created by Krati Jain on 15/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

public class EventNames: NSObject {
    public static let viewWillDisplay = "viewWillDisplay"
    public static let viewWillEnd = "viewWillEnd"
    public static let viewStarted = "viewStarted"
    public static let viewEnded = "viewEnded"
    public static let visibilityChange = "visibilityChange"
    public static let scroll = "scroll"
    public static let contentClick = "contentClick"
    public static let dataChange = "dataChange"
}

public class TrackableEvent: NSObject {

    var eventType: String
    var eventData: EventData?

    init(_ eventName : String){
        
        self.eventType = eventName
        self.eventData = nil
    }
    
    init(eventType: String, eventData: EventData?) {
        
        self.eventType = eventType
        self.eventData = eventData
    }
}
