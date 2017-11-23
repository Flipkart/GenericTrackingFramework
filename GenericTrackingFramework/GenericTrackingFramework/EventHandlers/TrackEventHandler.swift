//
//  TrackEventHandler.swift
//  Flipkart
//
//  Created by Krati Jain on 17/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

///protocol to be followed by each event handler
@objc public protocol TrackEventHandler {
    weak var trackingManager: TrackingManager? { get }
    func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor)
}

///handler for view will display events - this adds tracking data in track collection hierarchy
class ViewWillDisplayEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    ///EventHandler for ViewWillDisplay event
    init(trackingManager: TrackingManager) {

        super.init()
        self.trackingManager = trackingManager
    }

    ///Handles viewWillDisplay event by creating a new data node in DataProcessor and distributes this event to the consumers
    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {

        if let nodeInfo = NodeInfo(from: event) {
            dataProcessor.addData(nodeInfo)
            
            //only for PLA_ADS, temporarily we will start view event here and distribute it
            if let tags = nodeInfo.trackingData.tags, tags.contains("PLA_ADS"){
                
                //only for PLA_ADS from browse page, we take view will display as view started and distribute them
                event.eventType = EventNames.viewStarted
                self.trackingManager?.distributeData(nodeInfo.trackingData, for: event)
            }
        }
    }
}

///handler called when view becomes visible - updates the visiblity % and fires view events for all children of this node
class ViewStartedEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {

        super.init()
        self.trackingManager = trackingManager
    }

    ///Handles ViewStarted event by updating its visibility in its corresponding data node in DataProcessor and distributes this event to the consumers
    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {

        if let data = event.eventData as? ViewEventData {

            //update the visiblity
            dataProcessor.updateData(from: event)
            
            //distribute view started event for nodes in the subtree for this node
            for trackData in (dataProcessor.fetchAllTreeNodes(for: data.uniqueId, screen: data.screen, forEachNode: {_ in }) ?? []) {
                
                //distribtue only if this is not a content because content related view events are triggered from scroll events
                if trackData.percentVisibility>0 { self.trackingManager?.distributeData(trackData, for: event) }
            }
        }
    }
}

///handler for view ended events
class ViewEndedEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {

        super.init()
        self.trackingManager = trackingManager
    }

    ///Handles ViewEnded event by deleting its corresponding data node from TrackingDataProcessor and distributing it
    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {

        if let data = event.eventData as? ViewEventData {
            
            //update visibility
            dataProcessor.updateData(from: event)
            
            //delete data
            if let deletedData = dataProcessor.removeData(for: data.screen, withId: data.uniqueId) {
                
                //for each node in deleted data, distribute view ended event only if it is not a content
                for data in deletedData {
                    if data.isWidget { self.trackingManager?.distributeData(data, for: event) }
                }
            }
        }
    }
}

///handler for visiblity change events like app moving to/from background,app getting locked, VC view disappear/appear when screen changes
class VisibilityChangeEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {

        super.init()
        self.trackingManager = trackingManager
    }

    ///Handles VisibilityChangeEvents by updating the visibility in data node and distributing the data
    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {

        if let data = event.eventData as? VisibilityChangeEventData {
            
            //convert into view event
            event.eventType = (data.isVisible ? EventNames.viewStarted : EventNames.viewEnded)

            //update the visibility for this node's subtree
            if let updatedNodes = dataProcessor.updateAllData(for: data.screen, isVisible: data.isVisible){
                
                //for each node in the subtree of this node, distribute the view event
                for trackData in updatedNodes{
                    self.trackingManager?.distributeData(trackData, for: event)
                }
            }
        }
    }
}

///handler for scroll events
class ScrollEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {

        super.init()
        self.trackingManager = trackingManager
    }

    ///handles Scroll events by updating % visibility of all nodes and their children and distributes the data
    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {

        if let eventData = event.eventData {
            
            //update the absolute frame and visiblity % for each node in this node's sub tree
            if let viewEvents = dataProcessor.updateVisiblityDataUsing(eventData){
                
                //distribute the view events for any eligible content in this subtree
                for (trackData,event) in viewEvents{
                    self.trackingManager?.distributeData(trackData, for: event)
                }
            }
        }
    }
}

///handler for content click events
class ContentClickHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {

        super.init()
        self.trackingManager = trackingManager
    }

    ///handles contentClick event by distributing it
    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {
        
        if let eventData = event.eventData {
            
            //Segregating event data on the basis of its type
            switch eventData {
            case let clickEventData as ContentClickData:
                processClickEvent(event: event, dataProcessor: dataProcessor, eventData: clickEventData)
            default:
                break
            }
        }
    }
    
    ///Handling all click events
    private func processClickEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor, eventData: ContentClickData) {
        guard let trackData = dataProcessor.fetchData(for: eventData.uniqueId, screen: eventData.screen) else {
            return
        }
        eventData.tags = trackData.tags
        self.trackingManager?.distributeData(trackData, for: event)
    }
}
