//
//  EventConsumer.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

@objc public protocol EventConsumer {
    
    var uniqueId: Int { get set }
    func consumeTrackData(_ trackData: TrackingData,for eventType: String)
}
