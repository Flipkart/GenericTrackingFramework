//
//  TrackingDataCollection.swift
//  Flipkart
//
//  Created by Krati Jain on 13/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

//The data structure for holding the track data hierarchy corresponding to view hierarchy of a screen
public class TrackingDataCollection: NSObject {

    //map of unique id to TrackDataNode - to be used for directly accesing the node data
    var trackIdNodeMap: [String: TrackDataNode]
    
    //the tree hierarchy itself
    var trackDataTree: TrackDataNode?

    override init() {

        trackIdNodeMap = [:]
        trackDataTree = nil
        super.init()
    }

    //adding data for a node with specified parent Id
    func addData(nodeInfo: NodeInfo, parentId: String?) {

        if trackIdNodeMap[nodeInfo.trackingData.uniqueId] != nil {
            return 
        }
        
        let newNode = TrackDataNode(nodeInfo: nodeInfo, parent: nil)

        //if tree is empty, make this node as root
        if trackDataTree == nil {
            trackDataTree = newNode
        } else{

            var parent = parentId
            
            //only in case of PLA_ADS , push the data as child of current tree root
            if let tags = nodeInfo.trackingData.tags, tags.contains("PLA_ADS"){
                parent  = trackDataTree?.nodeInfo.trackingData.uniqueId
            }
            
            //if parent node exists, then add this node as a child of parent node
            if let pId = parent, let parentNode = trackIdNodeMap[pId] {
                newNode.parentNode = parentNode
                parentNode.childNodes?.append(newNode)
                
                //populate parentId and navigationContextId
                if newNode.nodeInfo.trackingData.impressionTracking?.navigationContextId == nil {
                    newNode.nodeInfo.trackingData.impressionTracking?.navigationContextId = parentNode.nodeInfo.trackingData.impressionTracking?.navigationContextId
                }
                if newNode.nodeInfo.trackingData.impressionTracking?.parentImpression == nil {
                    newNode.nodeInfo.trackingData.impressionTracking?.parentImpression = parentNode.nodeInfo.trackingData.impressionTracking?.impression
                }
            }
        }

        
        //finally add the entry of this node in the directly accessible map
        trackIdNodeMap[nodeInfo.trackingData.uniqueId] = newNode
    }

    //delete data for this node and each ndoe in its subtree and return the deleted nodes
    func deleteData(nodeId: String) -> [TrackingData]? {

        var deletedTrackDataArr: [TrackingData]? = []

        if let node = trackIdNodeMap[nodeId] {

            deletedTrackDataArr?.append(node.nodeInfo.trackingData)

            trackIdNodeMap.removeValue(forKey: nodeId)

            //update the parentNode's childNodes
            if let parentNode = node.parentNode, let _ = trackIdNodeMap[parentNode.nodeInfo.trackingData.uniqueId], let childIdArr = parentNode.childNodes {
                var newChildren: [TrackDataNode] = []

                for child in childIdArr {
                    if child.nodeInfo.trackingData.uniqueId != nodeId {
                        newChildren.append(child)
                    }
                }
                parentNode.childNodes = newChildren
            }

            //recursively delete all chilren
            if let children = node.childNodes {
                for childNode in children {
                    deletedTrackDataArr?.append(contentsOf: (self.deleteData(nodeId: childNode.nodeInfo.trackingData.uniqueId) ?? []))
                }
            }
            
            //if this is root of the tree then set the tree to nil
            if let treeRoot = trackDataTree, node === treeRoot{
                trackDataTree = nil
            }
        }
        return deletedTrackDataArr
    }

    func getData(for dataId: String) -> TrackDataNode? {
        return trackIdNodeMap[dataId]
    }

    func update(nodeInfo: NodeInfo, for dataId: String) {
        trackIdNodeMap[dataId]?.nodeInfo = nodeInfo
    }
}

//Represents the node in the data structure : holds NodeInfo, parentNode reference,childNodes as array
class TrackDataNode {

    var nodeInfo: NodeInfo
    weak var parentNode: TrackDataNode?
    var childNodes: [TrackDataNode]?

    init(nodeInfo: NodeInfo, parent: TrackDataNode?) {

        self.nodeInfo = nodeInfo
        self.parentNode = parent
        self.childNodes = []
    }
}
