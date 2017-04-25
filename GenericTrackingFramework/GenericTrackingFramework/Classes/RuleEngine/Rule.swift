//
//  Rule.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

@objc public enum EvaluationOperation: Int {
    case equal
    case greater
    case lesser
    case unequal
}

public class Rule: NSObject {

    var propertyToEvaluate: String
    var operation: EvaluationOperation
    var requiredValue: Any

    init(property: String, evalOp: EvaluationOperation, value: Any) {
        self.propertyToEvaluate = property
        self.operation = evalOp
        self.requiredValue = value
    }
}

public class EventWiseRules: NSObject {

    var eventType: String
    var rules: [Rule]

    init(eventType: String, rules: [Rule]) {
        self.eventType = eventType
        self.rules = rules
    }
}
