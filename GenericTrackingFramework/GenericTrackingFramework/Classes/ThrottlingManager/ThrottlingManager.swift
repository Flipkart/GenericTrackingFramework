//
//  ThrottlingManager.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//protocol for throttling events
protocol EventThrottler {
    func throttleEvent(_ event: TrackableEvent) -> Bool
}

//Throttles different events according to the specified criteria/rules
struct ThrottlingManager: EventThrottler {

    //holds rules for each eventType so that throttling can be performed if rules evaluate to true
    var throttlingCriteria: [String: [Rule]]?
    
    //serial queue for dispatching the events
    let serialQueue = DispatchQueue(label: "Flipkart.eventQueue")
    
    //action to be performed if events are not throttled
    var successHandler: (TrackableEvent) -> ()

    //takes default throttling criteria
    init(successHandler: @escaping (TrackableEvent) -> ()) {

        //by default, throttle scroll events where offset delta is greater than 0.5
        self.throttlingCriteria = [EventNames.scroll: [Rule(property: "offset", evalOp: .greater, value: Float(0.5))]]
        self.successHandler = successHandler
    }

    //customize the criteria as well as successhandler
    init(criteria: [String: [Rule]]?, successHandler: @escaping (TrackableEvent) -> ()) {

        self.throttlingCriteria = criteria
        self.successHandler = successHandler
    }

    //TODO Support OR,And for rules
    func throttleEvent(_ event: TrackableEvent) -> Bool {

        let ruleEngine = RuleEngine()

        //fetch the rules for this event type
        if let criteria = throttlingCriteria?[event.eventType] {
            for rule in criteria {
                //process the criteria
                if !ruleEngine.evaluateRule(rule, for: event, data: nil) {
                    return false
                }
            }
        }

        //now dispatch the events to the serial queue with specified successHandler
        serialQueue.async {
            self.successHandler(event)
        }

        return true
    }


}
