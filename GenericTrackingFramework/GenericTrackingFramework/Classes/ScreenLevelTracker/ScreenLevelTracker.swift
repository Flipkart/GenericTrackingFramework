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

public class ScreenLevelTracker: NSObject, UIScrollViewDelegate {

    var eventScreen: String
    let throttler: ThrottlingManager

    //takes the default throttlingCriteria
    init(screen: String) {
        
        self.eventScreen = screen
        self.throttler = ThrottlingManager(successHandler: { event in
            TrackingManager.sharedInstance.process(event)
        })
    }

    init(screen: String, trackingManager: TrackingManager) {
        
        self.eventScreen = screen
        self.throttler = ThrottlingManager(successHandler: { event in
            trackingManager.process(event)
        })
    }

    init(screen: String, throttlingCriteria: [String: [Rule]]?) {
        
        self.eventScreen = screen
        self.throttler = ThrottlingManager(criteria: throttlingCriteria, successHandler: { event in
            TrackingManager.sharedInstance.process(event)
        })
    }

    func trackScrollEvent(_ scrollView: UIScrollView, lastTrackedOffset: CGPoint) -> Bool {

        let newContentOffset: CGPoint = scrollView.contentOffset
        let scrollOffsetDelta: CGPoint = CGPoint(x: newContentOffset.x - lastTrackedOffset.x, y: newContentOffset.y - lastTrackedOffset.y)

        let eventData = ScrollEventData(screen: self.eventScreen, scrollOffsetDelta: scrollOffsetDelta, scrollSourceTag: scrollView.tag)
        let event = TrackableEvent(eventType: EventNames.scroll, eventData: eventData)
        return throttler.throttleEvent(event)
    }

    func registerScrollView(_ scrollView: UIScrollView) {
        
        if scrollView.tag <= 0 {
            scrollView.tag = TagGenerator.sharedInstance.getNextAvailableTag()
        }
    }

    func trackViewHierarchyFor(view: ContentTrackableEntityProtocol, event: String, scrollTag: String?, parentId: String?) {

        var parentScrollTag = scrollTag
        var parent = parentId

        //prepare ID,WigTracking data and pass to throttler
        if let trackData = view.trackData {

            let eventData = ViewEventData(screen: self.eventScreen, uniqueId: trackData.uniqueId, absoluteFrame: trackData.absoluteFrame, impressionTracking: trackData.impressionTracking, percentVisibility: 0, scrollTag: scrollTag, parentId: parent, tags: trackData.tags, isWidget: trackData.isWidget)
            let event = TrackableEvent(eventType: event, eventData: eventData)
            throttler.throttleEvent(event)

            parent = trackData.uniqueId
        }

        //start observing only when view started
        if view.isScrollable, event == EventNames.viewWillDisplay {
            
            var tag: Int? = nil
            var absoluteFrame: CGRect = CGRect.zero

            //TODO Implement reusabilitiy here;remove duplicate code
            switch (view) {
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
            case (let view as TrackableObjcUITableView):
                view.tracker = self
                tag = view.tag
                absoluteFrame = view.convert(view.bounds, to: nil)
                break
            case (let view as TrackableObjcUICollectionView):
                view.tracker = self
                tag = view.tag
                absoluteFrame = view.convert(view.bounds, to: nil)
                break
            case (let view as TrackableObjcScrollView):
                view.tracker = self
                tag = view.tag
                absoluteFrame = view.convert(view.bounds, to: nil)
            default:
                break
            }

            if let validTag = tag {
                //create an event for this scrollView
                let eventData = ViewEventData(screen: self.eventScreen, uniqueId: String(validTag), absoluteFrame: absoluteFrame, impressionTracking: nil, percentVisibility: 0, scrollTag: scrollTag, parentId: parentId, tags: nil, isScrollView: true)
                let event = TrackableEvent(eventType: event, eventData: eventData)
                throttler.throttleEvent(event)

                parentScrollTag = String(validTag)
                parent = parentScrollTag
            }
        }

        view.getTrackableChildren()?.forEach {
            self.trackViewHierarchyFor(view: $0, event: event, scrollTag: parentScrollTag, parentId: parent)
        }
    }

    func appBecameActive() {
        
        let eventData = VisibilityChangeEventData(screen: self.eventScreen, isVisible: true)
        let event = TrackableEvent(eventType: EventNames.visibilityChange, eventData: eventData)
        throttler.throttleEvent(event)
    }

    func appBecameInactive() {
        
        let eventData = VisibilityChangeEventData(screen: self.eventScreen, isVisible: false)
        let event = TrackableEvent(eventType: EventNames.visibilityChange, eventData: eventData)
        throttler.throttleEvent(event)
    }

    func trackViewAppear(trackData: FrameData?) {
        
        //update visiblity %
        if let trackData = trackData {
            let eventData = ViewEventData(screen: self.eventScreen, uniqueId: trackData.uniqueId, absoluteFrame: trackData.absoluteFrame, impressionTracking: trackData.impressionTracking, percentVisibility: 0, scrollTag: nil, parentId: nil, tags: trackData.tags)
            let event = TrackableEvent(eventType: EventNames.viewStarted, eventData: eventData)
            throttler.throttleEvent(event)
        }
    }


    func trackViewDisappear(trackData: FrameData?) {
        
        //delete the entry the widget/content
        if let trackData = trackData {
            let eventData = ViewEventData(screen: self.eventScreen, uniqueId: trackData.uniqueId, absoluteFrame: trackData.absoluteFrame, impressionTracking: trackData.impressionTracking, percentVisibility: 0, scrollTag: nil, parentId: nil, tags: trackData.tags)
            let event = TrackableEvent(eventType: EventNames.viewEnded, eventData: eventData)
            throttler.throttleEvent(event)
        }
    }

    func trackModelChange(oldId: String?, trackData: FrameData) {
        
        //update the data corresponding to this widget/content
        if let uId = oldId {
            let eventData = ModelChangeEventData(screen: self.eventScreen, uId: uId)
            let event = TrackableEvent(eventType: EventNames.dataChange, eventData: eventData)
            throttler.throttleEvent(event)
        }
    }

    func trackContentClick(trackData: FrameData?) {
        
        if let trackData = trackData {
            let eventData = ContentClickData(screen: self.eventScreen, uId: trackData.uniqueId)
            let event = TrackableEvent(eventType: EventNames.contentClick, eventData: eventData)
            throttler.throttleEvent(event)
        }
    }
}
