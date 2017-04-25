//
//  TrackingDataCollection.swift
//  Flipkart
//
//  Created by Krati Jain on 13/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

public class TrackingDataCollection: NSObject {
    
    var trackIdNodeMap: [String: TrackDataNode]
    var trackDataTree: TrackDataNode?

    override init() {
        
        trackIdNodeMap = [:]
        trackDataTree = nil
        super.init()
    }

    func addData(nodeInfo: NodeInfo, parentId: String?) {

        let newNode = TrackDataNode(nodeInfo: nodeInfo, parent: nil)

        if trackDataTree == nil {
            trackDataTree = newNode
        } else {

            if let pId = parentId, let parentNode = trackIdNodeMap[pId] {
                newNode.parentNode = parentNode
                parentNode.childNodes?.append(newNode)
            }
        }

        trackIdNodeMap[nodeInfo.trackingData.uniqueId] = newNode
    }

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
