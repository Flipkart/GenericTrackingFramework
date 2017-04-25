//
//  TrackingManager.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

protocol EventProcessor {
    
    func add(event: TrackableEvent, handler: TrackEventHandler)

    func process(_ event: TrackableEvent)
}

public class TrackingManager: NSObject {

    static let sharedInstance = TrackingManager()

    fileprivate var counter: Int = 1

    internal var ruleConsumerMap: [Int: RuleBasedConsumer]
    fileprivate var eventHandlerMap: [String: TrackEventHandler]
    fileprivate var dataProcessor: TrackingDataProcessor


    //Tracking Manager can be instantiated from anywhere but its preferable to use the sharedInstance in the same app
    override init() {
        
        ruleConsumerMap = [Int: RuleBasedConsumer]()
        dataProcessor = TrackingDataProcessor()
        eventHandlerMap = [String: TrackEventHandler]()
        super.init()

        //add the initial events and event handlers
        self.add(event: TrackableEvent(EventNames.viewWillDisplay), handler: ViewWillDisplayEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.viewWillEnd), handler: ViewDisappearedEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.viewStarted), handler: ViewStartedEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.viewEnded), handler: ViewEndedEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.visibilityChange), handler: VisibilityChangeEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.scroll), handler: ScrollEventHandler(trackingManager: self))
        self.add(event: TrackableEvent(EventNames.contentClick), handler: ContentClickHandler(trackingManager: self))
        //TODO Add data change handler
    }

}

extension TrackingManager: EventProcessor {

    public func add(event: TrackableEvent, handler: TrackEventHandler) {
        eventHandlerMap[event.eventType] = handler
    }

    public func process(_ event: TrackableEvent) {
        eventHandlerMap[event.eventType]?.handleEvent(event: event, dataProcessor: self.dataProcessor)
    }
}

extension TrackingManager: RuleBasedEventPublisher {

    public func register(consumer: EventConsumer, rules: [EventWiseRules]?) -> Bool {
        
        consumer.uniqueId = counter
        if ruleConsumerMap[counter] != nil {
            return false
        }
        ruleConsumerMap[counter] = RuleBasedConsumerModel(uniqueId: counter, consumer: consumer, rules: rules)
        counter += 1
        return true
    }

    public func deregister(consumer: EventConsumer) -> Bool {
        
        let uId = consumer.uniqueId
        if ruleConsumerMap[uId] != nil {
            ruleConsumerMap.removeValue(forKey: uId)
            return true
        }
        return false
    }

    public func update(rules: [EventWiseRules]?, consumer: EventConsumer) -> Bool {

        let id: Int = consumer.uniqueId
        if var ruleBaseConsumer = ruleConsumerMap[id] {
            ruleBaseConsumer.rules = rules
            ruleConsumerMap[id] = ruleBaseConsumer
            return true
        } else {
            return false
        }
    }

    public func distributeData(_ trackData: TrackingData?, for event: TrackableEvent) {

        if let data = trackData {
            print("Sending eventType: \(event.eventType) for ContentId: \(data.uniqueId) startTime: \(data.startTime) MaxVisiblity: \(data.maxPercentVisibility)")

            //evaluate rules and pass the event to the consumers
            let ruleEngine = RuleEngine()

            for (_, ruleBasedConsumer) in ruleConsumerMap {
                var shouldConsumeData = true

                if let rules = ruleBasedConsumer.rules {
                    for eventWiseRule in rules {
                        if eventWiseRule.eventType == event.eventType, let eventData = event.eventData {
                            shouldConsumeData = ruleEngine.evaluateRules(eventWiseRule.rules, for: eventData)
                        }
                    }
                }

                if shouldConsumeData {
                    ruleBasedConsumer.consumer.consumeTrackData(data, for: event.eventType)
                }
            }
        }
    }
}
