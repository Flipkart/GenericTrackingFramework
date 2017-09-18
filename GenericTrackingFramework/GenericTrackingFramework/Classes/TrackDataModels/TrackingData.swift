//
//  TrackingData
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//This is the consumable tracking data of every view
public class TrackingData: NSObject {

    internal var uniqueId: String
    var isWidget: Bool
    var tags: Set<String>?
    
    //any additionalInfo that needs to be sent to consumers of this view
    var additionalInfo: NSDictionary? = nil
    
    var impressionTracking: ImpressionTracking?
    
    var startTime: Date
    var maxPercentVisibility: Float
    
    var isVisible : Bool
    var percentVisibility: Float {

        didSet {
            
            //update maximum percent everytime % visibility is updated
            if percentVisibility > maxPercentVisibility {
                maxPercentVisibility = percentVisibility
            }
        }
    }

    init(uniqueId: String, impressionTracking: ImpressionTracking?, isWidget: Bool, tags: Set<String>?, additionalInfo : NSDictionary? = nil) {

        self.uniqueId = uniqueId
        self.isWidget = isWidget
        self.tags = tags
        self.percentVisibility = 0
        self.maxPercentVisibility = 0
        self.isVisible = true
        self.startTime = Date()
        self.impressionTracking = impressionTracking
        self.additionalInfo = additionalInfo

    }
}

//Consumable track data for video widget
public class VideoTrackingData : TrackingData {
    
    var timestamp : TimeInterval = 0
    var videoEventType : VideoEventType = .invalid
    var videoTime : Int = 0
    var totalVideoDuration : Int = 0
}

//Consumable track data for engagement events
public class EngagementTrackingData : TrackingData {
    
    var interactionType : InteractionType = .CLICK
    var metaData: Dictionary<String, Any>?
}

