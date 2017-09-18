//
//  ImpressionTrackingPopulator.swift
//  Flipkart
//
//  Created by Krati Jain on 18/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//Utility class for populating ImpressionTracking from NHPWidgetTracking(new home page) or WigActionTracking(old pages)
public class ImpressionTrackingPopulator: NSObject {

    static func getImpressionTrackingFromNHPTracking(_ widgetTracking: NHPWidgetTracking?) -> ImpressionTracking? {

        var impressionTracking: ImpressionTracking?

        if let wigTracking = widgetTracking {
            
            let impression = CompositeImpression(impressionId: wigTracking.impressionId, baseImpressionId: wigTracking.baseImpressionId, useBaseImpression: wigTracking.useBaseImpression)

            let tempImpressionTracking = ImpressionTracking(navigationContextId: "navId", impression: impression)

            tempImpressionTracking.findingMethod = wigTracking.findingMethod
            tempImpressionTracking.pageType = wigTracking.pageType
            tempImpressionTracking.otracker = wigTracking.otracker
            tempImpressionTracking.position = wigTracking.position
            tempImpressionTracking.widgetType = wigTracking.widgetType
            tempImpressionTracking.contentType = wigTracking.contentType

            tempImpressionTracking.tabImpression = wigTracking.tabImpression
            tempImpressionTracking.parentImpression = wigTracking.parentImpression
            tempImpressionTracking.navigationContextId = wigTracking.navigationContextId
            tempImpressionTracking.widgetKey = wigTracking.dataKey

            impressionTracking = tempImpressionTracking
        }
        return impressionTracking
    }

    static func populateImpressionTrackingFromWigActionTracking(_ wigActionTracking: WigActionTracking?) -> ImpressionTracking? {

        var impressionTracking: ImpressionTracking?

        if let wigTracking = wigActionTracking {

            
            let impression = CompositeImpression(impressionId: wigTracking.impressionId)
            let parentImpression = CompositeImpression(impressionId: wigTracking.parentImpressionId)
            let tabImpression = CompositeImpression(impressionId: wigTracking.tabImpressionId)
            
            let tempImpressionTracking = ImpressionTracking(navigationContextId: "navId", impression: impression)

            tempImpressionTracking.findingMethod = wigTracking.findingMethod
            tempImpressionTracking.pageType = wigTracking.pageType
            tempImpressionTracking.otracker = wigTracking.oTracker
            tempImpressionTracking.position = wigTracking.position
            tempImpressionTracking.widgetType = wigTracking.widgetType
            tempImpressionTracking.contentType = wigTracking.contentType

            tempImpressionTracking.tabImpression = tabImpression
            tempImpressionTracking.parentImpression = parentImpression
            tempImpressionTracking.widgetKey = wigTracking.widgetKey

            impressionTracking = tempImpressionTracking
        }
        return impressionTracking
    }
}
