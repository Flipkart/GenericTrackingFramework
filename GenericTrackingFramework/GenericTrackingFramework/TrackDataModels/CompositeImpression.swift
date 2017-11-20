//
//  CompositeImpression.swift
//  Flipkart
//
//  Created by Krati Jain on 26/07/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

public class CompositeImpression: NSObject {
    
    var impressionId: String?
    
    /* Added for v4 APIs */
    var baseImpressionId: String?
    var useBaseImpression: Bool
    
    init(impressionId: String?, baseImpressionId: String? = nil, useBaseImpression: Bool = false) {
        
        self.impressionId = impressionId
        self.baseImpressionId = baseImpressionId
        self.useBaseImpression = useBaseImpression

    }
}
