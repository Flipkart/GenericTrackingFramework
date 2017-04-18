//
//  TagGenerator.swift
//  Flipkart
//
//  Created by Krati Jain on 05/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

class TagGenerator{
    
    static let sharedInstance = TagGenerator()
    
    internal var nextAvailableTag : Int = 1323
    
    private init() {
    }
    
    func getNextAvailableTag()->Int{
        if let mainWindow = UIApplication.shared.delegate?.window{
            while let _ = mainWindow?.viewWithTag(nextAvailableTag){
                nextAvailableTag += 1
            }
        }
        return nextAvailableTag
    }
    
}
