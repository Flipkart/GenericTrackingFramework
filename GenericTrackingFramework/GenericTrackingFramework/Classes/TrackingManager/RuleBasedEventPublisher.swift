//
//  RuleBasedEventPublisher.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

protocol RuleBasedEventPublisher {

    var ruleConsumerMap: [Int: RuleBasedConsumer] { get set }

    func register(consumer: EventConsumer, rules: [EventWiseRules]?) -> Bool

    func deregister(consumer: EventConsumer) -> Bool

    func update(rules: [EventWiseRules]?, consumer: EventConsumer) -> Bool
}

protocol RuleBasedConsumer {
    
    var uniqueId: Int { get set }
    var consumer: EventConsumer { get set }
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
