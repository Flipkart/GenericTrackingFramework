//
//  ImpressionTracking.swift
//  Flipkart
//
//  Created by Krati Jain on 18/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//Object for holding tracking impressions and relevant parameters. This is independent of app and can be created from app specific tracking objects using ImpressionTrackingPopulator
public class ImpressionTracking: NSObject {

    var navigationContextId: String?
    var findingMethod: String?

    var impression: CompositeImpression?
    var tabImpression: CompositeImpression?
    var parentImpression: CompositeImpression?
    
    var widgetKey: String?

    var contentType: String?
    var contextType: String?

    var otracker: String?
    var position: String?

    var pageType: String?
    var viewType: String?
    var widgetType: String?

    init(navigationContextId: String?, impression: CompositeImpression?) {

        self.navigationContextId = navigationContextId
        self.impression = impression
    }
}
