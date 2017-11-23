//
//  ConnectionConsumer.swift
//  TrackingDemo
//
//  Created by Krati Jain on 21/11/17.
//  Copyright © 2017 Flipkart. All rights reserved.
//

import Foundation
import GenericTrackingFramework

class ConnectionConsumer : NSObject, EventConsumer {
    
    var uniqueId: Int = 0
    static let sharedInstance = ConnectionConsumer()
    
    //rules for events that we want to consume
    var connectionConsumerRules : [EventWiseRules] = []
    
    private override init() {
        super.init()
        //populate the rules for events for consumption
        self.populateConnectionConsumerRules()
    }
    
    //populate rules for events from app config
    internal func populateConnectionConsumerRules() {
        connectionConsumerRules = []
        let rule1 = Rule(property: "minTime", evalOp: .greater , value: 10)
        let rule2 = Rule(property: "minPercent", evalOp: .greater, value: 1)
        connectionConsumerRules.append(EventWiseRules(eventType: EventNames.viewEnded, rules: [rule1,rule2]))
        
    }
    
    //consume each tracking data
    func consumeTrackData(_ trackData: TrackingData, for eventType: String) {
        
        switch (eventType) {
            
        case EventNames.viewEnded :
            print("View Ended Event Consumed \(trackData.uniqueId)")
        case EventNames.viewStarted:
            print("View Started Event Consumed \(trackData.uniqueId)")
        case EventNames.contentClick:
            print("Content Click Event Consumed \(trackData.uniqueId)")
            
        default:
            print("Unidentified Event Consumedm \(trackData.uniqueId)")
        }
    }
}
