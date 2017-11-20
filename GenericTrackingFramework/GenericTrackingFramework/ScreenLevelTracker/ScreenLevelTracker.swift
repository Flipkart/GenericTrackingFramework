//
//  AllTypeContainerDelegate.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import UIKit

/*** Uncomment to support tracking for Async DisplayKit
import AsyncDisplayKit
 ***/

//Every screen has only one screenLevelTracker which is responsible for view,scroll and click events of its widgets & content
public class ScreenLevelTracker: NSObject, UIScrollViewDelegate {

    //uniquely identifying the screen of this tracker
    var eventScreen: String
    
    //event throttler
    let throttler: ThrottlingManager

    //takes the default throttlingCriteria
    init(screen: String) {

        self.eventScreen = screen
        
        //default success handler should pass event to shared TrackingManager for processing
        self.throttler = ThrottlingManager(successHandler: { event in
            TrackingManager.sharedInstance.process(event)
        })
    }

    //custom trackingManager for processing events
    init(screen: String, trackingManager: TrackingManager) {

        self.eventScreen = screen
        
        //custom trackingManager passed in successHandler for eventThrottler
        self.throttler = ThrottlingManager(successHandler: { event in
            trackingManager.process(event)
        })
    }

    //custom throttling criteria for eventThrottler
    init(screen: String, throttlingCriteria: [String: [Rule]]?) {

        self.eventScreen = screen
        self.throttler = ThrottlingManager(criteria: throttlingCriteria, successHandler: { event in
            TrackingManager.sharedInstance.process(event)
        })
    }

    //for each scroll event, calculate offset delta and pass the event to eventThrottler
    func trackScrollEvent(_ scrollView: UIScrollView, lastTrackedOffset: CGPoint) -> Bool {

        let newContentOffset: CGPoint = scrollView.contentOffset
        let scrollOffsetDelta: CGPoint = CGPoint(x: newContentOffset.x - lastTrackedOffset.x, y: newContentOffset.y - lastTrackedOffset.y)

        let eventData = ScrollEventData(screen: self.eventScreen, scrollOffsetDelta: scrollOffsetDelta, scrollSourceTag: scrollView.tag)
        let event = TrackableEvent(eventType: EventNames.scroll, eventData: eventData)
        return throttler.throttleEvent(event)
    }

    //register scroll view for tracking and assign it a unique tag
    func registerScrollView(_ scrollView: UIScrollView) {

        if scrollView.tag <= 0 {
            scrollView.tag = TagGenerator.sharedInstance.getNextAvailableTag()
        }
    }

    //sends the event to eventThrottler if the track data is valid
    func trackEvent(eventName:String,data:FrameData?,parentId:String?,scrollTag:String?){
        
        //prepare ID,WigTracking data and pass to throttler
        if let trackData = data {
            
            let isVisible = (eventName == EventNames.viewStarted ? true : false)
            
            let eventData = ViewEventData(screen: self.eventScreen, uniqueId: trackData.uniqueId, absoluteFrame: trackData.absoluteFrame, impressionTracking: trackData.impressionTracking, percentVisibility: 0, scrollTag: scrollTag, parentId: parentId, tags: trackData.tags, isVisible: isVisible, isWidget: trackData.isWidget)
            let trackableEvent = TrackableEvent(eventType: eventName, eventData: eventData)
            let _ = throttler.throttleEvent(trackableEvent)
        }
    }
    
    //bubbles down the event while traversing the whole view hierarchy for trackable views and their children
    func trackViewHierarchyFor(view: ContentTrackableEntityProtocol, event: String, scrollTag: String?, parentId: String?) {

        var parentScrollTag = scrollTag
        var parent = parentId

        //prepare ID,WigTracking data and pass to throttler for this node
        if let trackData = view.trackData {

            self.trackEvent(eventName: event, data: trackData, parentId: parent, scrollTag: parentScrollTag)
            parent = trackData.uniqueId
        }

        //if this is scrollable node then start observing only if event is view started
        if view.isScrollable, event == EventNames.viewWillDisplay {

            var tag: Int? = nil
            var absoluteFrame: CGRect = CGRect.zero

            //TODO Implement reusabilitiy here;remove duplicate code
            switch (view) {
                
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
            case (let view as TrackableObjcUICollectionView):
                view.tracker = self
                tag = view.tag
                absoluteFrame = view.convert(view.bounds, to: nil)
                break
            case (let view as TrackableObjcUITableView):
                view.tracker = self
                tag = view.tag
                absoluteFrame = view.convert(view.bounds, to: nil)
                break
            case (let view as TrackableObjcScrollView):
                view.tracker = self
                tag = view.tag
                absoluteFrame = view.convert(view.bounds, to: nil)
                
                /***
                 
                 Uncomment following code to support tracking for Async Display KiT
                 
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
                 
            ***/
                
            default:
                break
            }

            //if this scrollable trackable view has valid tag then create an event for tracking this view as well
            if let validTag = tag {

                let eventData = ViewEventData(screen: self.eventScreen, uniqueId: String(validTag), absoluteFrame: absoluteFrame, impressionTracking: nil, percentVisibility: 0, scrollTag: scrollTag, parentId: parentId, tags: nil, isVisible: (event == EventNames.viewStarted ? true : false), isScrollView: true)
                let event = TrackableEvent(eventType: event, eventData: eventData)
                let _ = throttler.throttleEvent(event)

                //pass on this view's tag as parentTag for any child views here onwards
                parentScrollTag = String(validTag)
                parent = parentScrollTag
            }
        }

        //for every trackable child, traverse the hierarchy for throttling the event
        view.getTrackableChildren()?.forEach {
            self.trackViewHierarchyFor(view: $0, event: event, scrollTag: parentScrollTag, parentId: parent)
        }
    }

    //triggers visiblity change for whole view hierarchy of screen when app becomes active - this indirectly fires view started for each trackable view on screen
    func appBecameActive() {

        let eventData = VisibilityChangeEventData(screen: self.eventScreen, isVisible: true)
        let event = TrackableEvent(eventType: EventNames.visibilityChange, eventData: eventData)
        let _ = throttler.throttleEvent(event)
    }

    //triggers visiblity change for whole view hierarchy of screen when app becomes inactive (pushed in background or locked) - this indirectly fires view ended for each trackable view on screen
    func appBecameInactive() {

        let eventData = VisibilityChangeEventData(screen: self.eventScreen, isVisible: false)
        let event = TrackableEvent(eventType: EventNames.visibilityChange, eventData: eventData)
        let _ = throttler.throttleEvent(event)
    }

    //triggers view started event for this node
    func trackViewAppear(trackData: FrameData?) {

        //update visiblity %
        if let trackData = trackData {
            let eventData = ViewEventData(screen: self.eventScreen, uniqueId: trackData.uniqueId, absoluteFrame: trackData.absoluteFrame, impressionTracking: trackData.impressionTracking, percentVisibility: 0, scrollTag: nil, parentId: nil, tags: trackData.tags, isVisible: true, isWidget: trackData.isWidget)
            let event = TrackableEvent(eventType: EventNames.viewStarted, eventData: eventData)
            let _ = throttler.throttleEvent(event)
        }
    }

    //triggers view ended event for this node
    func trackViewDisappear(trackData: FrameData?) {

        //delete the entry the widget/content
        if let trackData = trackData {
            let eventData = ViewEventData(screen: self.eventScreen, uniqueId: trackData.uniqueId, absoluteFrame: trackData.absoluteFrame, impressionTracking: trackData.impressionTracking, percentVisibility: 0, scrollTag: nil, parentId: nil, tags: trackData.tags, isVisible: false)
            let event = TrackableEvent(eventType: EventNames.viewEnded, eventData: eventData)
            let _ = throttler.throttleEvent(event)
        }
    }

    //triggers data change event to update thid node's data in the TrackingDataProcessor's view hierarchy for this screen
    func trackModelChange(oldId: String?, trackData: FrameData) {

        //update the data corresponding to this widget/content
        if let uId = oldId {
            let eventData = ModelChangeEventData(screen: self.eventScreen, uId: uId)
            let event = TrackableEvent(eventType: EventNames.dataChange, eventData: eventData)
            let _ = throttler.throttleEvent(event)
        }
    }

    //triggers content click event for this node
    func trackContentClick(trackData: FrameData?) {

        if let trackData = trackData {
            let eventData = ContentClickData(screen: self.eventScreen, uId: trackData.uniqueId)
            let event = TrackableEvent(eventType: EventNames.contentClick, eventData: eventData)
            let _ = throttler.throttleEvent(event)
        }
    }
    
    //triggers content click event for this node with additional event data to be passed on
    func trackContentClick(for event: String, with data:EventData) {
        if event == EventNames.video || event == EventNames.contentEngagement {
            let event = TrackableEvent(eventType: EventNames.contentClick, eventData: data)
            let _ = throttler.throttleEvent(event)
        }
    }
    
    //directly adds the entity with parent as tree root if parentId is nil and begins its tracking - this method should be used in cases when the view was not discovered and added before becoming visible
    func beginTracking(entity: ContentTrackableEntityProtocol, parentId : String?) {
        if let trackData = entity.trackData {
            
            let eventData = ViewEventData(screen: self.eventScreen, uniqueId: trackData.uniqueId, absoluteFrame: trackData.absoluteFrame, impressionTracking: trackData.impressionTracking, percentVisibility: 0, scrollTag: parentId, parentId: parentId, tags: trackData.tags, isVisible: false, isWidget: trackData.isWidget, additionalInfo : trackData.additionalInfo)
            let trackableEvent = TrackableEvent(eventType: EventNames.viewWillDisplay, eventData: eventData)
            let _ = throttler.throttleEvent(trackableEvent)

        }
    }
}
