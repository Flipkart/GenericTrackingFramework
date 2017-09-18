//
//  TagGenerator.swift
//  Flipkart
//
//  Created by Krati Jain on 05/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//Singleton class for uniquely assiging tag to each scrollable trackable view
class TagGenerator {

    static let sharedInstance = TagGenerator()

    internal var nextAvailableTag: Int = 1322

    private init() {
    }

    func getNextAvailableTag() -> Int {

        nextAvailableTag += 1

        //if this view already exists then increment the counter tag
        if let mainWindow = UIApplication.shared.delegate?.window {
            while let _ = mainWindow?.viewWithTag(nextAvailableTag) {
                nextAvailableTag += 1
            }
        }
        return nextAvailableTag
    }

}
