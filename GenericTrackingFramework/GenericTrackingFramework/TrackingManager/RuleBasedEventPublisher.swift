//
//  RuleBasedEventPublisher.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

///protocol to be followed to act as a publisher/distributor of events among rule based consumer
protocol RuleBasedEventPublisher {

    ///maintain the uniqueId map of each consumer
    var ruleConsumerMap: [Int: RuleBasedConsumer] { get set }

    ///register the consumer with its rules for events that its interested in
    func register(consumer: EventConsumer, rules: [EventWiseRules]?) -> Bool

    ///deregister the consumer so it wont receive any events in future
    func deregister(consumer: EventConsumer) -> Bool

    ///update the rules for this consumer
    func update(rules: [EventWiseRules]?, consumer: EventConsumer) -> Bool
}

