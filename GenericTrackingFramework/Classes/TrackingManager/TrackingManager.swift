//
//  TrackingManager.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

protocol EventProcessor{
    func add(eventType:EventType,handler:TrackEventHandler)
    func process(_ event:TrackableEvent)
}

class TrackingManager {
    
    static let sharedInstance = TrackingManager()
    
    internal var counter : Int = 1
    
    internal var ruleConsumerMap : [Int : RuleBasedConsumer]
    internal var eventHandlerMap : [EventType : TrackEventHandler]
    internal var dataProcessor : TrackingDataProcessor
    
    private init() {
        ruleConsumerMap = [Int : RuleBasedConsumer]()
        dataProcessor = TrackingDataProcessor()
        eventHandlerMap = [EventType : TrackEventHandler]()
        
        //add the initial events and event handlers
        self.add(eventType: .viewWillDisplay, handler: ViewWillDisplayEventHandler())
        self.add(eventType: .viewWillEnd, handler: ViewDisappearedEventHandler())
        self.add(eventType: .viewStarted, handler: ViewStartedEventHandler())
        self.add(eventType: .viewEnded, handler: ViewEndedEventHandler())
        self.add(eventType: .visibilityChange, handler: VisibilityChangeEventHandler())
        self.add(eventType: .scroll, handler: ScrollEventHandler())
    }
    
}

extension TrackingManager : EventProcessor{
    
    func add(eventType:EventType,handler:TrackEventHandler){
        eventHandlerMap[eventType] = handler
    }
    
    internal func process(_ event:TrackableEvent) {
        eventHandlerMap[event.eventType]?.handleEvent(event: event, dataProcessor: &self.dataProcessor)
    }
}

extension TrackingManager : RuleBasedEventPublisher{
    
    func register(consumer : inout EventConsumer , rules : [EventType : [Rule]]?) -> Bool{
        consumer.uniqueId = counter
        if ruleConsumerMap[counter] != nil {
            return false
        }
        ruleConsumerMap[counter] = RuleBasedConsumerModel(uniqueId: counter, consumer: consumer, rules: rules)
        return true
    }
    
    func deregister(consumer : EventConsumer) -> Bool{
        let uId = consumer.uniqueId
        if ruleConsumerMap[uId] != nil {
            ruleConsumerMap.removeValue(forKey: uId)
            return true
        }
        return false
    }
    
    func update(rules :[EventType : [Rule]]?, consumer : EventConsumer) -> Bool{
        
        let id : Int = consumer.uniqueId
        if var ruleBaseConsumer = ruleConsumerMap[id] {
            ruleBaseConsumer.rules = rules
            ruleConsumerMap[id] = ruleBaseConsumer
            return true
        }else { return false }
    }
    func distributeData(_ trackData:TrackingData?,for event:TrackableEvent){
        
        if let data = trackData{
            print("Sending eventType: \(event.eventType.toString()) for ContentId: \(data.uniqueId) with Frame : \(data.absoluteFrame) startTime: \(data.startTime) MaxVisiblity: \(data.maxPercentVisibility)")
            
            //evaluate rules and pass the event to the consumers
            let ruleEngine = RuleEngine()
            
            for (_,ruleBasedConsumer) in ruleConsumerMap{
                if let rules = ruleBasedConsumer.rules?[event.eventType]{
                    if ruleEngine.evaluateRules(rules,for:event.eventData){
                        ruleBasedConsumer.consumer.consumeTrackData(data)
                    }
                }else{
                    ruleBasedConsumer.consumer.consumeTrackData(data)
                }
            }
        }
    }
}
