//
//  EventConsumer.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//each event consumer should have a unique id and should know how to consume the TrackData
@objc public protocol EventConsumer {

    var uniqueId: Int { get set }
    func consumeTrackData(_ trackData: TrackingData, for eventType: String)
}

