//
//  RuleEngine.swift
//  Flipkart
//
//  Created by Krati Jain on 15/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

protocol RuleEvaluator {
    func evaluateRules(_ rules: [Rule], for input: EventData) -> Bool
}


struct RuleEngine: RuleEvaluator {

    func evaluateRule(_ rule: Rule, for input: EventData) -> Bool {

        switch (input) {
            
        case (let scrollEventData as ScrollEventData):
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
            break
            
        case (let viewEventData as ViewEventData):
            if rule.propertyToEvaluate == "tag", let value = rule.requiredValue as? String {
                switch rule.operation {
                case .equal:
                    return viewEventData.tags?.contains(value) ?? false
                case .unequal:
                    return !(viewEventData.tags?.contains(value) ?? false)
                default:
                    break
                }
            }
            break
            
        case (let contentClickData as ContentClickData):
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
            break
            
        default:
            break
        }
        return false
    }

    func evaluateRules(_ rules: [Rule], for input: EventData) -> Bool {
        
        var result: Bool = true
        for rule in rules {
            result = result && self.evaluateRule(rule, for: input)
        }
        return result
    }

}

