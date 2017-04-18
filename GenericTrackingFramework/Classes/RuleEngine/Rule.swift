//
//  Rule.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

enum EvaluationOperation{
    case equal
    case greater
    case lesser
}

struct Rule{
    
    var propertyToEvaluate : String
    var operation : EvaluationOperation
    var requiredValue : Float
    
    init(property:String,evalOp:EvaluationOperation,value:Float){
        self.propertyToEvaluate = property
        self.operation = evalOp
        self.requiredValue = value
    }
}
