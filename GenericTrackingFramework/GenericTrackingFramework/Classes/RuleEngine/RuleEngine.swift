//
//  RuleEngine.swift
//  Flipkart
//
//  Created by Krati Jain on 15/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

protocol RuleEvaluator{
    func evaluateRules(_ rules:[Rule],for input:EventData)->Bool
}


struct RuleEngine : RuleEvaluator{
    
    func evaluateRule(_ rule: Rule,for input:EventData)->Bool {
        //TODO Optimise the swift code here ; remove duplicacy
        switch (input,rule.operation){
        case (let scrollEventData as ScrollEventData,.equal) :
            return (Float(abs(scrollEventData.scrollOffsetDelta.x)) == rule.requiredValue) || (Float(abs(scrollEventData.scrollOffsetDelta.y)) == rule.requiredValue)
        case (let scrollEventData as ScrollEventData,.greater):
            return (Float(abs(scrollEventData.scrollOffsetDelta.x)) > rule.requiredValue) || (Float(abs(scrollEventData.scrollOffsetDelta.y)) > rule.requiredValue)
        case (let scrollEventData as ScrollEventData,.lesser):
            return (Float(abs(scrollEventData.scrollOffsetDelta.x)) < rule.requiredValue) || (Float(abs(scrollEventData.scrollOffsetDelta.y)) < rule.requiredValue)
        default:
            break
        }
        return false
    }
    
    func evaluateRules(_ rules:[Rule],for input:EventData)->Bool{
        var result : Bool = true
        for rule in rules{
            result = result && self.evaluateRule(rule,for:input)
        }
        return result
    }

}

