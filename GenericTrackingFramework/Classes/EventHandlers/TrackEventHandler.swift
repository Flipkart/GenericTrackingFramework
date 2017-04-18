//
//  TrackEventHandler.swift
//  Flipkart
//
//  Created by Krati Jain on 17/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation


protocol TrackEventHandler{
    func handleEvent(event:TrackableEvent,dataProcessor:inout TrackingDataProcessor)
}

class ViewWillDisplayEventHandler : NSObject , TrackEventHandler{
    internal func handleEvent(event: TrackableEvent,dataProcessor:inout TrackingDataProcessor) {
        if let data = TrackingData(from:event){
            dataProcessor.addData(data)
        }
    }
}

class ViewDisappearedEventHandler : NSObject , TrackEventHandler{
    internal func handleEvent(event: TrackableEvent,dataProcessor:inout TrackingDataProcessor) {
        dataProcessor.updateRelevantData(event.eventData)
    }
}

class ViewStartedEventHandler : NSObject , TrackEventHandler{
    internal func handleEvent(event: TrackableEvent, dataProcessor:inout TrackingDataProcessor) {
        if let data = event.eventData as? ViewEventData{
            dataProcessor.updateRelevantData(data)
            for data in (dataProcessor.fetchAllTreeNodes(for:data.uniqueId,screen:data.screen) ?? []){
                TrackingManager.sharedInstance.distributeData(data, for: event)
            }
        }
    }
}

class ViewEndedEventHandler : NSObject , TrackEventHandler{
    internal func handleEvent(event: TrackableEvent, dataProcessor:inout TrackingDataProcessor) {
        if let data = TrackingData(from:event){
            dataProcessor.updateData(data)
            if let deletedData = dataProcessor.removeData(data.uniqueId){
                for data in deletedData{
                    TrackingManager.sharedInstance.distributeData(data, for: event)
                }
            }
        }
    }
}

class VisibilityChangeEventHandler : NSObject , TrackEventHandler{
    internal func handleEvent(event: TrackableEvent, dataProcessor:inout TrackingDataProcessor) {
        if let data = TrackingData(from: event){
            dataProcessor.updateData(data)
        }
    }
}

class ScrollEventHandler : NSObject , TrackEventHandler{
    internal func handleEvent(event: TrackableEvent, dataProcessor:inout TrackingDataProcessor) {
        dataProcessor.updateRelevantData(event.eventData)
    }
}
