//
//  EventThrottler.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

protocol EventThrottler{
    func throttleEvent(_ event: TrackableEvent)->Bool
}

struct ThrottlingManager : EventThrottler{
    
    var throttlingCriteria : [EventType : [Rule]]?
    
    //takes default throttling criteria
    init(){
        self.throttlingCriteria = [.scroll:[Rule(property:"offset",evalOp:.greater,value:0.5)]]
    }
    
    init(criteria : [EventType : [Rule]]?){
        self.throttlingCriteria = criteria
    }
    
    //TODO Support OR,And for rules
    func throttleEvent(_ event :TrackableEvent)->Bool{
        let ruleEngine = RuleEngine()
        
        //fetch the rules for this event type
        if let criteria = throttlingCriteria?[event.eventType]{
            for rule in criteria {
                //process the criteria
                if !ruleEngine.evaluateRule(rule,for:event.eventData) {
                    return false
                }
            }
        }
        
        DispatchQueue.global(qos: .background).async{
            //now send the event to Tracking Manager
            TrackingManager.sharedInstance.process(event)
        }
        return true
    }


}
