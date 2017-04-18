//
//  TrackingData.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

let unknown = "unknown"
enum EventSourceScreen{
    case home
    case browse
    case product
    case offerZone
    case unknown
}

//TODO Keep minimum required fields here for the event consumers
class TrackingData{
    
    var parentId : String?
    
    internal var uniqueId: String
    internal var absoluteFrame: CGRect
    internal var affectingScrollViewTag: String?
    
    var screen : String
    
    var maxPercentVisibility:Float
    var percentVisibility : Float{
        didSet{
            if percentVisibility > maxPercentVisibility{
                maxPercentVisibility = percentVisibility
            }
        }
    }
    
    var impressionTracking : ImpressionTracking?
    
    var isScrollView : Bool = false
    var startTime : Date
    
    init(uniqueId:String,eventSourceTag:String?,frame:CGRect,impressionTracking:ImpressionTracking?) {
        self.screen = unknown
        self.percentVisibility = 0
        self.impressionTracking = impressionTracking
        self.uniqueId = uniqueId
        self.affectingScrollViewTag = eventSourceTag
        self.absoluteFrame = frame
        self.maxPercentVisibility = 0
        self.startTime = Date()
    }
    
    init?(from event:TrackableEvent){
        self.screen = event.eventData.screen
        
        if let data = event.eventData as? ViewEventData{
            self.percentVisibility = data.percentVisibility
            self.impressionTracking = data.impressionTracking
            self.uniqueId = data.uniqueId
            self.affectingScrollViewTag = data.affectingScrollTag
            self.absoluteFrame = data.absoluteFrame
            self.maxPercentVisibility = 0
            self.startTime = Date()
            self.isScrollView = data.isScrollView
            self.parentId = data.parentId
        }else{
            return nil
        }
    }
}
