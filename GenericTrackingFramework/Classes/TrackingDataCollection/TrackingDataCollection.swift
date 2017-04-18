//
//  TrackingDataCollection.swift
//  Flipkart
//
//  Created by Krati Jain on 13/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

class TrackingDataCollection{
    var trackIdNodeMap : [String:TrackDataNode]
    var trackDataTree : TrackDataNode?
    
    init(){
        trackIdNodeMap = [:]
        trackDataTree = nil
    }
    
    func addData(data:TrackingData,parentId:String?){
        
        let newNode = TrackDataNode(data: data, parent: nil)
        
        if trackDataTree == nil{
            trackDataTree = newNode
        }else{
            
            if let pId = parentId, let parentNode = trackIdNodeMap[pId]{
                newNode.parentNode = parentNode
                parentNode.childNodes?.append(newNode)
            }
        }
        
        trackIdNodeMap[data.uniqueId] = newNode
    }
    
    func deleteData(nodeId:String)->[TrackingData]?{
        
        var deletedTrackDataArr : [TrackingData]? = []
        
        if let node = trackIdNodeMap[nodeId]{
            
            deletedTrackDataArr?.append(node.data)
            trackIdNodeMap.removeValue(forKey: nodeId)
            
            //update the parentNode's childNodes
            if let parentNode = node.parentNode,let _ = trackIdNodeMap[parentNode.data.uniqueId],let childIdArr = parentNode.childNodes{
                var newChildren : [TrackDataNode] = []
                
                for child in childIdArr{
                    if child.data.uniqueId != nodeId{
                        newChildren.append(child)
                    }
                }
                parentNode.childNodes = newChildren
            }
            
            //recursively delete all chilren
            if let children = node.childNodes{
                for childNode in children{
                    deletedTrackDataArr?.append(contentsOf: (self.deleteData(nodeId: childNode.data.uniqueId) ?? []))
                }
            }
        }
        return deletedTrackDataArr
    }
    
    func getData(for dataId:String)->TrackDataNode?{
        return trackIdNodeMap[dataId]
    }
    
    func update(data:TrackingData,for dataId : String){
        trackIdNodeMap[dataId]?.data = data
    }
}

class TrackDataNode{
    var data : TrackingData
    weak var parentNode : TrackDataNode?
    var childNodes : [TrackDataNode]?
    
    init(data:TrackingData,parent:TrackDataNode?){
        self.data = data
        self.parentNode = parent
        self.childNodes = []
    }
}
