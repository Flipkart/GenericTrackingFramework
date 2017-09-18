//
//  RuleEngine.swift
//  Flipkart
//
//  Created by Krati Jain on 15/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//Protocol for evaluating rules
protocol RuleEvaluator {
    func evaluateRules(_ rules: [Rule], for event: TrackableEvent, data : TrackingData?) -> Bool
}

//This Rule Engine can evaluate specified set of rules
struct RuleEngine: RuleEvaluator {

    func evaluateRule(_ rule: Rule, for event: TrackableEvent, data: TrackingData?) -> Bool {
        
        switch (event.eventType) {
            
        case EventNames.scroll:
            
            if let scrollEventData = event.eventData as? ScrollEventData {
                
                let absXOffset = Float(abs(scrollEventData.scrollOffsetDelta.x))
                let absYOffset = Float(abs(scrollEventData.scrollOffsetDelta.y))
                
                if rule.propertyToEvaluate == "offset", let value = rule.requiredValue as? Float {
                    
                    switch rule.operation {
                        
                    case .lesser:
                        return (absXOffset < value) || (absYOffset < value)
                    case .equal:
                        return (absXOffset == value) || (absYOffset == value)
                    case .greater:
                        return (absXOffset > value) || (absYOffset > value)
                    default:
                        break
                    }
                }
            }
            break
            
        case EventNames.viewStarted,EventNames.viewEnded:
            
            if rule.propertyToEvaluate == "tag", let value = rule.requiredValue as? String, let trackData = data{
                
                let tags = trackData.tags ?? []
                
                switch rule.operation {
                    
                case .equal:
                    return tags.contains(value)
                case .unequal:
                    return !(tags.contains(value))
                default:
                    break
                }
                
                
            }
            else if rule.propertyToEvaluate == "minPercent", let value = rule.requiredValue as? Float, let trackData = data{
                return trackData.maxPercentVisibility >= value
            }
            else if rule.propertyToEvaluate == "minTime", let value = rule.requiredValue as? Int, let trackData = data {
                return (1000 * Int(Date().timeIntervalSince(trackData.startTime)) >= value)
            }
            break
            
        case EventNames.contentClick:
            
            if let contentClickData = event.eventData as? ContentClickData {
                if rule.propertyToEvaluate == "tag", let value = rule.requiredValue as? String {
                    switch rule.operation {
                    case .equal:
                        return contentClickData.tags?.contains(value) ?? false
                    case .unequal:
                        return !(contentClickData.tags?.contains(value) ?? false)
                    default:
                        break
                    }
                }
            }
            
            break
            
        default:
            break
        }
        
        return true
    }

    //evaluates rules and logically AND the results
    func evaluateRules(_ rules: [Rule], for event: TrackableEvent, data : TrackingData?) -> Bool {

        var result: Bool = true
        for rule in rules {
            result = result && self.evaluateRule(rule, for: event, data: data)
        }
        return result
    }

}

