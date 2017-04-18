//
//  TrackingDataProcessor.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

protocol  TrackingEntityProcessor{
    
    var activeTrackData : TrackingDataCollection {get}
    
    mutating func addData(_ trackData : TrackingData)
    mutating func updateData(_ trackData : TrackingData)
    mutating func removeData(_ trackDataId : String)->[TrackingData]?
    func fetchData(for id:String,screen:String)->TrackingData?
    func fetchAllTreeNodes(for id:String,screen:String)->[TrackingData]?
}

struct TrackingDataProcessor : TrackingEntityProcessor{
    
    var activeTrackData : TrackingDataCollection
    
    mutating func addData(_ trackData : TrackingData){
        self.activeTrackData.addData(data: trackData, parentId: trackData.parentId)
    }
    
    mutating func removeData(_ trackDataId : String)->[TrackingData]?{
        return self.activeTrackData.deleteData(nodeId: trackDataId)
    }
    
    mutating func updateData(_ trackData : TrackingData){
        
        let dataId = trackData.uniqueId
        
        if let oldData = (self.activeTrackData.getData(for: dataId)?.data){
            oldData.absoluteFrame = trackData.absoluteFrame
            oldData.impressionTracking = trackData.impressionTracking //should we update tracking??
            oldData.percentVisibility = trackData.percentVisibility
            
            self.activeTrackData.update(data:oldData,for:dataId)
        }
        
    }
    
    mutating func updateRelevantData(_ eventData : EventData){
        switch(eventData){
        case (let scrollData as ScrollEventData):
            //update only the tracking data affected by this scroll event
            if let trackingData = self.activeTrackData.getData(for: String(scrollData.scrollSourceTag)),let childIdArr = trackingData.childNodes{
                childIdArr.forEach{
                    self.updateFramesRecursively(on: scrollData.screen, scrollTag: $0.data.uniqueId, scrollDelta: scrollData.scrollOffsetDelta)
                }
            }
            break
        case (let viewData as ViewEventData):
            self.updateViewData(viewData:viewData)
            break
        default:
            break
        }
    }
    
    internal mutating func updateViewData(viewData:ViewEventData){
        let dataId = viewData.uniqueId
        
        if let oldData = self.activeTrackData.getData(for:dataId)?.data{
            oldData.absoluteFrame = viewData.absoluteFrame
            oldData.percentVisibility = self.calculateVisibility(for: oldData)
            oldData.startTime = Date()
            
            self.activeTrackData.update(data:oldData,for:dataId)
        }
    }
    
    internal func updateFramesRecursively(on screen:String,scrollTag:String?,scrollDelta:CGPoint){
        
        if let tag =  scrollTag,let trackingData = self.activeTrackData.getData(for: tag){
            
            var frame : CGRect = trackingData.data.absoluteFrame
            frame.origin.x += scrollDelta.x
            frame.origin.y += scrollDelta.y
            trackingData.data.absoluteFrame = frame
            
            //update the % visiblity
            trackingData.data.percentVisibility = self.calculateVisibility(for:trackingData.data)
            
            //update the data
            self.activeTrackData.update(data: trackingData.data, for: tag)
            
            if let childIdArr = trackingData.childNodes{
                childIdArr.forEach{
                    self.updateFramesRecursively(on: screen, scrollTag: $0.data.uniqueId, scrollDelta: scrollDelta)
                }
            }
        }
    }
    
    internal func calculateVisibility(for trackData:TrackingData)->Float{
        var visibility : Float = 0.0
        var visibleFrame = trackData.absoluteFrame
        let totalArea :Float = Float(visibleFrame.size.width)*Float(visibleFrame.size.height)
        var tag : String? = trackData.affectingScrollViewTag
        
        while let scrollTag = tag,let scrollViewData = self.activeTrackData.getData(for: scrollTag)?.data{
            let parentFrame = scrollViewData.absoluteFrame
            visibleFrame = visibleFrame.intersection(parentFrame)
            
            tag = scrollViewData.parentId
        }
        
        let visibleArea :Float = Float(visibleFrame.size.width)*Float(visibleFrame.size.height)
        
        if totalArea>0{
            visibility = visibleArea*100/totalArea
        }
        return visibility
    }
    
    internal func fetchData(for id: String,screen:String) -> TrackingData? {
        return self.activeTrackData.getData(for: id)?.data
    }
    
    func fetchAllTreeNodes(for id:String,screen:String)->[TrackingData]?{
        var allData : [TrackingData]? = []
        let currentEntityId = id
        
        if let currentNode = self.activeTrackData.getData(for: currentEntityId){
            allData?.append(currentNode.data)
            
            if let childNodes = currentNode.childNodes{
                for childNode in childNodes{
                    if let nodes = self.fetchAllTreeNodes(for: childNode.data.uniqueId, screen: screen){
                        allData?.append(contentsOf: nodes)
                    }
                }
            }
        }
        return allData
    }
    
    
    init()
    {
        self.activeTrackData = TrackingDataCollection()
    }
}
