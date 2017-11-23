//
//  TrackingManager.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

///protocol for processing any event which needs to be tracked and processed
protocol EventProcessor {

    ///add handler for specified event
    func add(event: TrackableEvent, handler: TrackEventHandler)

    ///process the event
    func process(_ event: TrackableEvent)
}


///The singleton Manager for Tracking operations. Note: Tracking Manager can be instantiated from anywhere but its preferable to use the sharedInstance in the same app
public class TrackingManager: NSObject {

    ///Shared singleton
    public static let sharedInstance = TrackingManager()

    ///counter to assign unique Id to each consumer at time of registering
    fileprivate var counter: Int = 1

    ///map of active event consumers against their unique Ids
    internal var ruleConsumerMap: [Int: RuleBasedConsumer]
    
    ///map of active event handlers against each event Name
    fileprivate var eventHandlerMap: [String: TrackEventHandler]
    
    ///the dataprocessor which holds the track data collection hierarchy for each tree
    fileprivate var dataProcessor: TrackingDataProcessor

    ///Note: Tracking Manager can be instantiated from anywhere but its preferable to use the sharedInstance in the same app
    override init() {

        ruleConsumerMap = [Int: RuleBasedConsumer]()
        dataProcessor = TrackingDataProcessor()
        eventHandlerMap = [String: TrackEventHandler]()
        super.init()

        //add the initial events and event handlers
        self.add(event: TrackableEvent(EventNames.viewWillDisplay), handler: ViewWillDisplayEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.viewStarted), handler: ViewStartedEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.viewEnded), handler: ViewEndedEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.visibilityChange), handler: VisibilityChangeEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.scroll), handler: ScrollEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.contentClick), handler: ContentClickHandler(trackingManager: self))
        //TODO Add data change handler
    }

}

///extending as event processor - handle each event and process it using the corresponding handler from the map
extension TrackingManager: EventProcessor {

    public func add(event: TrackableEvent, handler: TrackEventHandler) {
        eventHandlerMap[event.eventType] = handler
    }

    public func process(_ event: TrackableEvent) {
        eventHandlerMap[event.eventType]?.handleEvent(event: event, dataProcessor: self.dataProcessor)
    }
}

///extending as RuleBasedEventPublisher - manage consumers and their rules and distribute data after applying rules specified by each consumer
extension TrackingManager: RuleBasedEventPublisher {

    //registers a consumer
    public func register(consumer: EventConsumer, rules: [EventWiseRules]?) -> Bool {

        //assign uniqueId to each consumer
        consumer.uniqueId = counter
        if ruleConsumerMap[counter] != nil {
            return false
        }
        
        //store this consumer in the ruleConsumerMap for distributing events later
        ruleConsumerMap[counter] = RuleBasedConsumerModel(uniqueId: counter, consumer: consumer, rules: rules)
        counter += 1
        return true
    }

    ///deregisters consumer
    public func deregister(consumer: EventConsumer) -> Bool {

        let uId = consumer.uniqueId
        if ruleConsumerMap[uId] != nil {
            ruleConsumerMap.removeValue(forKey: uId)
            return true
        }
        return false
    }

    ///update the consumer rules
    public func update(rules: [EventWiseRules]?, consumer: EventConsumer) -> Bool {

        let id: Int = consumer.uniqueId
        
        //update the rules if this consumer exists in the map
        if var ruleBaseConsumer = ruleConsumerMap[id] {
            ruleBaseConsumer.rules = rules
            ruleConsumerMap[id] = ruleBaseConsumer
            return true
        } else {
            return false
        }
    }

    ///distributes the track Data to consumers if their rules evaluate to true for this event and trackData
    public func distributeData(_ trackData: TrackingData?, for event: TrackableEvent) {

        if let data = trackData {
//            print("Sending eventType: \(event.eventType) for ContentId: \(data.uniqueId) startTime: \(data.startTime) MaxVisiblity: \(data.maxPercentVisibility)")

            //evaluate rules and pass the event to the consumers
            let ruleEngine = RuleEngine()

            //for each consumer, distribute data only if rules allow
            for (_, ruleBasedConsumer) in ruleConsumerMap {
                var shouldConsumeData = true

                //evaluate all rules one by one
                if let rules = ruleBasedConsumer.rules {
                    for eventWiseRule in rules {
                        if eventWiseRule.eventType == event.eventType{
                            shouldConsumeData = ruleEngine.evaluateRules(eventWiseRule.rules, for: event, data: data)
                        }
                    }
                }

                //finally distribute data to the consumer
                if shouldConsumeData {
                    ruleBasedConsumer.consumer.consumeTrackData(data, for: event.eventType)
                }
            }
        }
    }
}
