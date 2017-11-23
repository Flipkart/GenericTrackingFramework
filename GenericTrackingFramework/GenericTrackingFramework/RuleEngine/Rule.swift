//
//  Rule.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//denotes the operation to be performed
@objc public enum EvaluationOperation: Int {
    case equal
    case greater
    case lesser
    case unequal
}

//Every rule is a check of propertyToEvaluate against requiredValue according to specified operation
public class Rule: NSObject {

    var propertyToEvaluate: String
    var operation: EvaluationOperation
    var requiredValue: Any

    public init(property: String, evalOp: EvaluationOperation, value: Any) {
        self.propertyToEvaluate = property
        self.operation = evalOp
        self.requiredValue = value
    }
}

//Holds rules for given eventType
public class EventWiseRules: NSObject {

    var eventType: String
    var rules: [Rule]

    public init(eventType: String, rules: [Rule]) {
        self.eventType = eventType
        self.rules = rules
    }
}
