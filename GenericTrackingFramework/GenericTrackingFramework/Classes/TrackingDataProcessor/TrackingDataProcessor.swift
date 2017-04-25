//
//  TrackingDataProcessor.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation

protocol TrackingEntityProcessor {

    var screenWiseData: [String: TrackingDataCollection] { get }

    mutating func addData(_ nodeInfo: NodeInfo)

    mutating func updateData(_ nodeInfo: NodeInfo)

    mutating func removeData(for screen: String, withId trackDataId: String) -> [TrackingData]?

    func fetchData(for id: String, screen: String) -> TrackingData?

    func fetchAllTreeNodes(for id: String, screen: String) -> [TrackingData]?
}

public class TrackingDataProcessor: NSObject, TrackingEntityProcessor {

    var screenWiseData: [String: TrackingDataCollection]

    func addData(_ nodeInfo: NodeInfo) {
        
        let screen = nodeInfo.screen
        if self.screenWiseData[screen] == nil {
            self.screenWiseData[screen] = TrackingDataCollection()
        }
        self.screenWiseData[screen]?.addData(nodeInfo: nodeInfo, parentId: nodeInfo.parentId)
    }

    func removeData(for screen: String, withId trackDataId: String) -> [TrackingData]? {
        return self.screenWiseData[screen]?.deleteData(nodeId: trackDataId)
    }

    func updateData(_ nodeInfo: NodeInfo) {

        let dataId = nodeInfo.trackingData.uniqueId

        if let oldData = (self.screenWiseData[nodeInfo.screen]?.getData(for: dataId)?.nodeInfo) {
            oldData.absoluteFrame = nodeInfo.absoluteFrame
            oldData.trackingData.impressionTracking = nodeInfo.trackingData.impressionTracking //should we update tracking??
            oldData.trackingData.percentVisibility = nodeInfo.trackingData.percentVisibility

            self.screenWiseData[nodeInfo.screen]?.update(nodeInfo: oldData, for: dataId)
        }

    }

    func updateVisiblityDataUsing(_ eventData: EventData) {
        
        //update only the tracking data affected by this scroll event
        if let scrollData = eventData as? ScrollEventData, let trackingData = self.screenWiseData[scrollData.screen]?.getData(for: String(scrollData.scrollSourceTag)), let childIdArr = trackingData.childNodes {
            childIdArr.forEach {
                self.updateFramesRecursively(on: scrollData.screen, scrollTag: $0.nodeInfo.trackingData.uniqueId, scrollDelta: scrollData.scrollOffsetDelta)
            }
        }
    }

    internal func updateViewData(viewData: ViewEventData) {
        
        let dataId = viewData.uniqueId

        if let oldData = self.screenWiseData[viewData.screen]?.getData(for: dataId)?.nodeInfo {
            oldData.absoluteFrame = viewData.absoluteFrame
            oldData.trackingData.percentVisibility = self.calculateVisibility(for: oldData)
            oldData.trackingData.startTime = Date()
        }
    }

    internal func updateFramesRecursively(on screen: String, scrollTag: String?, scrollDelta: CGPoint) {

        if let tag = scrollTag, let trackingData = self.screenWiseData[screen]?.getData(for: tag) {

            var frame: CGRect = trackingData.nodeInfo.absoluteFrame
            frame.origin.x -= scrollDelta.x
            frame.origin.y -= scrollDelta.y
            trackingData.nodeInfo.absoluteFrame = frame

            //update the % visiblity
            trackingData.nodeInfo.trackingData.percentVisibility = self.calculateVisibility(for: trackingData.nodeInfo)

            //update the data
            self.screenWiseData[screen]?.update(nodeInfo: trackingData.nodeInfo, for: tag)

            if let childIdArr = trackingData.childNodes {
                childIdArr.forEach {
                    self.updateFramesRecursively(on: screen, scrollTag: $0.nodeInfo.trackingData.uniqueId, scrollDelta: scrollDelta)
                }
            }
        }
    }

    internal func calculateVisibility(for nodeInfo: NodeInfo) -> Float {
        
        var visibility: Float = 0.0
        var visibleFrame = nodeInfo.absoluteFrame
        let totalArea: Float = Float(visibleFrame.size.width) * Float(visibleFrame.size.height)
        var tag: String? = nodeInfo.affectingScrollViewTag

        while let scrollTag = tag, let scrollViewData = self.screenWiseData[nodeInfo.screen]?.getData(for: scrollTag)?.nodeInfo {
            let parentFrame = scrollViewData.absoluteFrame
            visibleFrame = visibleFrame.intersection(parentFrame)

            tag = scrollViewData.parentId
        }

        let visibleArea: Float = Float(visibleFrame.size.width) * Float(visibleFrame.size.height)

        if totalArea > 0 {
            visibility = visibleArea * 100 / totalArea
        }
//        print("visibility for \(nodeInfo.trackingData.uniqueId) with frame:\(nodeInfo.absoluteFrame) is : \(visibility)")
        return visibility
    }

    internal func fetchData(for id: String, screen: String) -> TrackingData? {
        return self.screenWiseData[screen]?.getData(for: id)?.nodeInfo.trackingData
    }

    func fetchAllTreeNodes(for id: String, screen: String) -> [TrackingData]? {
        
        var allData: [TrackingData]? = []
        let currentEntityId = id

        if let currentNode = self.screenWiseData[screen]?.getData(for: currentEntityId) {
            allData?.append(currentNode.nodeInfo.trackingData)

            if let childNodes = currentNode.childNodes {
                for childNode in childNodes {
                    if let nodes = self.fetchAllTreeNodes(for: childNode.nodeInfo.trackingData.uniqueId, screen: screen) {
                        allData?.append(contentsOf: nodes)
                    }
                }
            }
        }
        return allData
    }

    func updateAllData(for screen: String, isVisible: Bool) {
        //TODO
    }

    override init() {
        self.screenWiseData = [:]
    }
}
