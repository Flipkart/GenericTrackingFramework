//
//  EventData.swift
//  Flipkart
//
//  Created by Krati Jain on 24/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//Protocol to be followed by each EventData which represents the data of any TrackableEvent
@objc protocol EventData {
    
    //screen on which the event happened
    var screen: String { get set }
}

//scroll event data
class ScrollEventData: EventData {

    internal var screen: String = "unknown"
    
    //change in scroll offset
    var scrollOffsetDelta: CGPoint
    
    //tag of the scroll view which scrolled
    var scrollSourceTag: Int

    init(screen: String, scrollOffsetDelta: CGPoint, scrollSourceTag: Int) {

        self.scrollOffsetDelta = scrollOffsetDelta
        self.scrollSourceTag = scrollSourceTag
        self.screen = screen
    }
}

//visibility change event data
class VisibilityChangeEventData: EventData {

    internal var screen: String = "unknown"
    
    //whether screen is visible or not
    var isVisible: Bool

    init(screen: String, isVisible: Bool) {

        self.isVisible = isVisible
        self.screen = screen
    }
}

//ViewEvent data for view events like view start and view end
class ViewEventData: EventData {

    internal var screen: String = "unknown"

    //uniqueId of the trackData of the view
    var uniqueId: String
    
    //whether the view is trackable scrollview
    var isScrollView: Bool
    
    //is it a content or a widget
    var isWidget: Bool
    
    //is the view visible
    var isVisible: Bool

    //tag of the first scroll view in the parent hierarchy which affects the frame of this view
    var affectingScrollTag: String?
    
    //unique id of the parent trackable view
    var parentId: String?
    
    //view frame with respect to window
    var absoluteFrame: CGRect
    
    //tracking impression related data object
    var impressionTracking: ImpressionTracking?
    
    //current % visibility of the view
    var percentVisibility: Float
    
    //Set of tags for this view
    var tags: Set<String>?
    
    //any additionalInfo that needs to be sent for consumption
    var additionalInfo: NSDictionary?

    //by default isScrollView = false, isWidget = false, additionalInfo = nil
    init(screen: String, uniqueId: String, absoluteFrame: CGRect, impressionTracking: ImpressionTracking?, percentVisibility: Float, scrollTag: String?, parentId: String?, tags: Set<String>?, isVisible: Bool, isScrollView: Bool = false, isWidget: Bool = false, additionalInfo: NSDictionary? = nil) {

        self.uniqueId = uniqueId
        self.absoluteFrame = absoluteFrame
        self.impressionTracking = impressionTracking
        self.percentVisibility = percentVisibility
        self.screen = screen

        self.isScrollView = isScrollView
        self.isWidget = isWidget
        self.isVisible = isVisible

        self.parentId = parentId
        self.affectingScrollTag = scrollTag
        self.tags = tags
        self.additionalInfo = additionalInfo
    }
}

//eventData for event of data change
class ModelChangeEventData: EventData {

    internal var screen: String = "unknown"
    
    //unique id of the track data of view whose data changed
    var uniqueId: String

    init(screen: String, uId: String) {

        self.uniqueId = uId
        self.screen = screen
    }
}

//EventData for content click event
class ContentClickData: EventData {

    internal var screen: String = "unknown"
    
    //uniqueId of the track data of view which was clicked
    var uniqueId: String
    
    //tags associated with the track data of the view
    var tags: Set<String>? = nil

    init(screen: String, uId: String) {

        self.uniqueId = uId
        self.screen = screen
    }
}

//EventData for video widget related contentClick events like pause,resume etc
class VideoEventData: ContentClickData {
    
    //Tracking Impression object associated with the video
    var impressionTracking : ImpressionTracking
    
    //timestamp of the event
    var timestamp : TimeInterval
    
    //type of event
    var videoEventType : VideoEventType
    
    //point of time 
    var videoTime : Int
    
    //total duration
    var totalVideoDuration : Int
    
    init(screen: String, uniqueId : String, impressionTracking: ImpressionTracking, timestamp: TimeInterval, videoEventType: VideoEventType, videoTime: Int, totalVideoDuration: Int){
        
        self.impressionTracking = impressionTracking
        self.timestamp = timestamp
        self.videoEventType = videoEventType
        self.videoTime = videoTime
        self.totalVideoDuration = totalVideoDuration
        super.init(screen: screen, uId: uniqueId)
    }
}

//EventData for engagement related click events
class ContentEngagementData: ContentClickData {
    
    //Tracking Impression object associated with the video
    var impressionTracking: ImpressionTracking
    
    //type of interaction
    var interactionType: InteractionType
    
    //metadata for the interaction
    var metaData: Dictionary<String, Any>?
    
    init(screen: String, uniqueId : String, impressionTracking: ImpressionTracking, interactionType: InteractionType, metaData: Dictionary<String, Any>?){
        
        self.impressionTracking = impressionTracking
        self.interactionType = interactionType
        self.metaData = metaData
        super.init(screen: screen, uId: uniqueId)
    }
}
