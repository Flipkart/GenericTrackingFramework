//
//  RuleBasedEventPublisher.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

protocol RuleBasedEventPublisher{
    
    var ruleConsumerMap : [Int : RuleBasedConsumer] {get set}
    
    func register(consumer : inout EventConsumer , rules : [EventType : [Rule]]?) -> Bool
    func deregister(consumer : EventConsumer) -> Bool
    func update(rules : [EventType : [Rule]]?, consumer : EventConsumer) -> Bool
}

protocol RuleBasedConsumer {
    var uniqueId : Int {get set}
    var consumer : EventConsumer {get set}
    var rules : [EventType : [Rule]]? {get set}
}

struct RuleBasedConsumerModel : RuleBasedConsumer{
    
    var uniqueId : Int {
        get{return self.uniqueId}
        set(uniqueId){self.uniqueId = uniqueId}
    }
    
    var consumer : EventConsumer {
        get{return self.consumer}
        set(consumer){self.consumer = consumer}
    }
    
    var rules : [EventType : [Rule]]? {
        get{return self.rules}
        set(rules){self.rules = rules}
    }
    
    init(uniqueId : Int, consumer : EventConsumer , rules : [EventType : [Rule]]?) {
        self.uniqueId = uniqueId;
        self.consumer = consumer
        self.rules = rules
    }
}
