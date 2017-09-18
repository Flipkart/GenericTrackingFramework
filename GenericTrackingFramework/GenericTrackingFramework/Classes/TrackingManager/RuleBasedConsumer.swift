//
//  RuleBasedConsumer.swift
//  Flipkart
//
//  Created by Krati Jain on 30/05/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//protocol to be followed to act as a consumer/listener of events
protocol RuleBasedConsumer {
    
    var uniqueId: Int { get set }
    var consumer: EventConsumer { get set }
    
    //specify the rules to be evaluated before consuming the event
    var rules: [EventWiseRules]? { get set }
}

class RuleBasedConsumerModel: NSObject, RuleBasedConsumer {
    
    internal var rules: [EventWiseRules]?
    internal var consumer: EventConsumer
    internal var uniqueId: Int
    
    init(uniqueId: Int, consumer: EventConsumer, rules: [EventWiseRules]?) {
        
        self.uniqueId = uniqueId;
        self.consumer = consumer
        self.rules = rules
    }
}
