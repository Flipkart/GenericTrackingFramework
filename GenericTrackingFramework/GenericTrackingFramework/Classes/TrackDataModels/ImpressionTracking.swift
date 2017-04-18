//
//  ImpressionTracking.swift
//  Flipkart
//
//  Created by Krati Jain on 18/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

struct ImpressionTracking {
    
    var navigationContextId : String?
    var findingMethod : String?
    
    var impressionId : String?
    var tabImpressionId : String?
    var parentImpressionId : String?
    
    var contentType : String?
    var contextType : String?
    
    var otracker : String?
    var position : String?
    
    var pageType : String?
    var viewType : String?
    var widgetType : String?
    
    init(navigationContextId:String?,impressionId:String?) {
        self.navigationContextId = navigationContextId
        self.impressionId = impressionId
    }
}
