//
//  TrackableEvents.swift
//  Flipkart
//
//  Created by Krati Jain on 15/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

enum EventType{
    case scroll
    case viewWillDisplay
    case viewStarted
    case viewWillEnd
    case viewEnded
    case viewDisappeared
    case visibilityChange
    case dimensionChange
    case dataChange
    
    func toString()->String{
        var eventStr = "unknown"
        
        switch(self){
        case .scroll:
            eventStr = "scroll"
            break
        case .viewStarted:
            eventStr = "viewStarted"
            break
        case .viewEnded:
            eventStr = "viewEnded"
            break
        default:
            break
        }
        return eventStr
    }
}

protocol EventData {
    var screen : String {get set}
}

struct ScrollEventData : EventData{
    private var _screen : String = unknown
    var screen : String {
        get{ return self._screen}
        set(inputScreen){ _screen = inputScreen}
    }
    var scrollOffsetDelta : CGPoint
    var scrollSourceTag : Int
    
    init(screen:String,scrollOffsetDelta:CGPoint,scrollSourceTag:Int){
        self.scrollOffsetDelta = scrollOffsetDelta
        self.scrollSourceTag = scrollSourceTag
        self.screen = screen
    }
}

struct VisibilityChangeEventData : EventData{
    private var _screen : String = unknown
    var screen : String {
        get{ return self._screen}
        set(inputScreen){ _screen = inputScreen}
    }
    var isVisible : Bool
    
    init(screen:String,isVisible:Bool){
        self.isVisible = isVisible
        self.screen = screen
    }
}

struct ViewEventData : EventData{
    private var _screen : String = unknown
    var screen : String {
        get{ return self._screen}
        set(inputScreen){ _screen = inputScreen}
    }
    var isScrollView = false
    var uniqueId : String
    var affectingScrollTag:String?
    var parentId : String?
    var absoluteFrame: CGRect
    var impressionTracking : ImpressionTracking?
    var percentVisibility : Float
    
    init(screen:String,uniqueId:String,absoluteFrame : CGRect,impressionTracking:ImpressionTracking?,percentVisibility:Float,scrollTag:String?,parentId:String?, isScrollView:Bool=false){
        self.uniqueId = uniqueId
        self.absoluteFrame = absoluteFrame
        self.impressionTracking = impressionTracking
        self.percentVisibility = percentVisibility
        self.screen = screen
        
        self.parentId = parentId
        self.affectingScrollTag = scrollTag
    }
}

struct ModelChangeEventData : EventData{
    private var _screen : String = unknown
    var screen : String {
        get{ return self._screen}
        set(inputScreen){ _screen = inputScreen}
    }
    var uniqueId : String
    
    init(screen:String,uId:String){
        self.uniqueId = uId
        self.screen = screen
    }
}
struct TrackableEvent{
    
    var eventType : EventType
    var eventData : EventData
}
