//
//  TrackingData
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

public class TrackingData: NSObject {

    internal var uniqueId: String
    var isWidget: Bool
    var tags: [String]?
    var impressionTracking: ImpressionTracking?

    var startTime: Date
    var maxPercentVisibility: Float
    
    var percentVisibility: Float {
        
        didSet {
            if percentVisibility > maxPercentVisibility {
                maxPercentVisibility = percentVisibility
            }
        }
    }

    init(uniqueId: String, impressionTracking: ImpressionTracking?, isWidget: Bool, tags: [String]?) {
        
        self.uniqueId = uniqueId
        self.isWidget = isWidget
        self.tags = tags
        self.percentVisibility = 0
        self.maxPercentVisibility = 0
        self.startTime = Date()
        self.impressionTracking = impressionTracking

    }
}

