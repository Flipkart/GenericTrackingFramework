//
//  TrackEventHandler.swift
//  Flipkart
//
//  Created by Krati Jain on 17/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation


@objc public protocol TrackEventHandler {
    weak var trackingManager: TrackingManager? { get }
    func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor)
}

class ViewWillDisplayEventHandler: NSObject, TrackEventHandler {
    
    weak public var trackingManager: TrackingManager?
    
    init(trackingManager: TrackingManager) {
        
        super.init()
        self.trackingManager = trackingManager
    }

    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {
        
        if let nodeInfo = NodeInfo(from: event) {
            dataProcessor.addData(nodeInfo)
        }
    }
}

class ViewDisappearedEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {
        
        super.init()
        self.trackingManager = trackingManager
    }

    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {
        
        if let viewData = event.eventData as? ViewEventData {
            dataProcessor.updateViewData(viewData: viewData)
        }
    }
}

class ViewStartedEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {
        
        super.init()
        self.trackingManager = trackingManager
    }

    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {
        
        if let data = event.eventData as? ViewEventData {
            
            dataProcessor.updateViewData(viewData: data)
            for data in (dataProcessor.fetchAllTreeNodes(for: data.uniqueId, screen: data.screen) ?? []) {
                self.trackingManager?.distributeData(data, for: event)
            }
        }
    }
}

class ViewEndedEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {
        
        super.init()
        self.trackingManager = trackingManager
    }

    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {
        
        if let data = event.eventData as? ViewEventData {
            dataProcessor.updateViewData(viewData: data)
            if let deletedData = dataProcessor.removeData(for: data.screen, withId: data.uniqueId) {
                for data in deletedData {
                    self.trackingManager?.distributeData(data, for: event)
                }
            }
        }
    }
}

class VisibilityChangeEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {
        
        super.init()
        self.trackingManager = trackingManager
    }

    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {
        
        if let data = event.eventData as? VisibilityChangeEventData {
            dataProcessor.updateAllData(for: data.screen, isVisible: data.isVisible)
        }
    }
}

class ScrollEventHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {
        
        super.init()
        self.trackingManager = trackingManager
    }

    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {
        
        if let eventData = event.eventData{
            dataProcessor.updateVisiblityDataUsing(eventData)
        }
    }
}

class ContentClickHandler: NSObject, TrackEventHandler {

    weak public var trackingManager: TrackingManager?

    init(trackingManager: TrackingManager) {
        
        super.init()
        self.trackingManager = trackingManager
    }

    internal func handleEvent(event: TrackableEvent, dataProcessor: TrackingDataProcessor) {
            
        if let eventData = event.eventData as? ContentClickData, let trackData = dataProcessor.fetchData(for: eventData.uniqueId, screen: eventData.screen) {
            eventData.tags = trackData.tags
            self.trackingManager?.distributeData(trackData, for: event)
        }
    }
}
