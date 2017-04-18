//
//  AllTypeContainerDelegate.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

public class ScreenLevelTracker : NSObject,UIScrollViewDelegate{
    
    var eventScreen : String
    let throttler : ThrottlingManager
    var activeScrollMap : [Int : CGPoint]
    
    //takes the default throttlingCriteria
    init(screen:String){
        self.eventScreen = screen
        self.throttler = ThrottlingManager()
        activeScrollMap = [:]
    }
    
    init(screen:String,throttlingCriteria:[EventType:[Rule]]?){
        self.eventScreen = screen
        self.throttler = ThrottlingManager(criteria : throttlingCriteria)
        activeScrollMap = [:]
    }
    
    func trackScrollEvent(_ scrollView: UIScrollView) // any offset changes
    {
        let scrollTag = scrollView.tag
        if let lastContentOffset = self.activeScrollMap[scrollTag]{
            let newContentOffset : CGPoint  = scrollView.contentOffset
            let scrollOffsetDelta : CGPoint = CGPoint(x: newContentOffset.x-lastContentOffset.x, y: newContentOffset.y-lastContentOffset.y)
            
            let eventData = ScrollEventData(screen:self.eventScreen,scrollOffsetDelta:scrollOffsetDelta,scrollSourceTag:scrollView.tag)
            let event = TrackableEvent(eventType:.scroll,eventData:eventData)
            if throttler.throttleEvent(event) {
                //update the content offset
                self.activeScrollMap[scrollTag] = newContentOffset
            }
            
        }
    }
    
    func registerScrollView(_ scrollView:UIScrollView){
        if scrollView.tag<=0{
            scrollView.tag = TagGenerator.sharedInstance.getNextAvailableTag()
        }
        self.activeScrollMap[scrollView.tag] = scrollView.contentOffset
    }
    
    func trackViewHierarchyFor(view:ContentTrackableEntityProtocol,event:EventType,scrollTag:String?,parentId:String?){
        
        var parentScrollTag = scrollTag
        var parent = parentId
        
        //prepare ID,impressionTracking data and pass to throttler
        if let trackData = view.trackData{
            
            let eventData = ViewEventData(screen:self.eventScreen,uniqueId:trackData.uniqueId,absoluteFrame:trackData.absoluteFrame,impressionTracking:trackData.impressionTracking,percentVisibility:0,scrollTag:scrollTag,parentId:parent)
            let event = TrackableEvent(eventType:event,eventData:eventData)
            throttler.throttleEvent(event)
            
            parent = trackData.uniqueId
        }
        
        //start observing only when view started
        if view.isScrollable,event==EventType.viewStarted{
            var tag : Int? = nil
            var absoluteFrame : CGRect = CGRect.zero
            
            //TODO Implement reusabilitiy here;remove duplicate code
            switch(view){
            case (let node as TrackableASCollectionNode):
                node.tracker = self
                tag = node.view.tag
                absoluteFrame = node.view.convert(node.view.bounds, to: nil)
                break
            case (let node as TrackableASTableNode):
                node.tracker = self
                tag = node.view.tag
                absoluteFrame = node.view.convert(node.view.bounds, to: nil)
                break
            case (let view as TrackableUICollectionView):
                view.tracker = self
                tag = view.tag
                absoluteFrame = view.convert(view.bounds, to: nil)
                break
            case (let view as TrackableUITableView):
                view.tracker = self
                tag = view.tag
                absoluteFrame = view.convert(view.bounds, to: nil)
                break
            default:
                break
            }
            
            if let validTag = tag{
                //create an event for this scrollView
                let eventData = ViewEventData(screen:self.eventScreen,uniqueId:String(validTag),absoluteFrame:absoluteFrame,impressionTracking:nil,percentVisibility:0,scrollTag:scrollTag,parentId:parentId,isScrollView:true)
                let event = TrackableEvent(eventType:event,eventData:eventData)
                throttler.throttleEvent(event)
                
                parentScrollTag = String(validTag)
                parent = parentScrollTag
            }
        }
        
        view.getTrackableChildren()?.forEach{
            self.trackViewHierarchyFor(view: $0, event: event,scrollTag:parentScrollTag,parentId:parent)
        }
    }
    func appBecameActive(){
        let eventData = VisibilityChangeEventData(screen:self.eventScreen,isVisible:true)
        let event = TrackableEvent(eventType:.visibilityChange,eventData:eventData)
        throttler.throttleEvent(event)
    }
    
    func appBecameInactive(){
        let eventData = VisibilityChangeEventData(screen:self.eventScreen,isVisible:false)
        let event = TrackableEvent(eventType:.visibilityChange,eventData:eventData)
        throttler.throttleEvent(event)
    }
    
    func trackViewAppear(trackData : FrameData?){
        //update visiblity %
        if let trackData = trackData{
            let eventData = ViewEventData(screen: self.eventScreen, uniqueId: trackData.uniqueId, absoluteFrame: trackData.absoluteFrame, impressionTracking: trackData.impressionTracking, percentVisibility: 0,scrollTag:nil,parentId:nil)
            let event = TrackableEvent(eventType:.viewStarted,eventData:eventData)
            throttler.throttleEvent(event)
        }
    }
    
    
    func trackViewDisappear(trackData : FrameData?){
        //delete the entry the widget/content
        if let trackData = trackData{
            let eventData = ViewEventData(screen: self.eventScreen, uniqueId: trackData.uniqueId, absoluteFrame: trackData.absoluteFrame, impressionTracking: trackData.impressionTracking, percentVisibility: 0,scrollTag:nil,parentId:nil)
            let event = TrackableEvent(eventType:.viewDisappeared,eventData:eventData)
            throttler.throttleEvent(event)
        }
    }
    func trackModelChange(oldId : String?,trackData : FrameData){
        //update the data corresponding to this widget/content
        if let uId = oldId{
            let eventData = ModelChangeEventData(screen: self.eventScreen, uId: uId)
            let event = TrackableEvent(eventType:.dataChange,eventData:eventData)
            throttler.throttleEvent(event)
        }
    }
}
