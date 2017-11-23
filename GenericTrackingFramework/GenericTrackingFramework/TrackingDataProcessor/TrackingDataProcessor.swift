//
//  TrackingDataProcessor.swift
//  Flipkart
//
//  Created by Krati Jain on 14/03/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import CoreGraphics

///protocol for processing track data
protocol TrackingEntityProcessor {

    ///to hold track data hierarchy for each screen
    var screenWiseData: [String: TrackingDataCollection] { get }

    ///adding track data in the right screen's track data hierarchy
    mutating func addData(_ nodeInfo: NodeInfo)

    ///updating track data in the specified screen's track data hierarchy
    mutating func updateData(_ nodeInfo: NodeInfo)

    ///removing track data for the specified screen's track data hierarchy
    mutating func removeData(for screen: String, withId trackDataId: String) -> [TrackingData]?

    ///fetch track data for this id in specified screen's track data hierarchy
    func fetchData(for id: String, screen: String) -> TrackingData?

    ///return all nodes (as array) in the specified screen's hierarchy which are part of the subtree of this node id. Optionally perform operations on each node while traversing by specifying it as forEachNode closure
    func fetchAllTreeNodes(for id: String, screen: String, forEachNode: (NodeInfo)->()) -> [TrackingData]?
}

///The Data processor for screen ; Holds TrackData for view hierarchy according to each screen
public class TrackingDataProcessor: NSObject, TrackingEntityProcessor {

    var screenWiseData: [String: TrackingDataCollection]

    override init() {
        self.screenWiseData = [:]
    }
    
    func addData(_ nodeInfo: NodeInfo) {

        let screen = nodeInfo.screen
        
        //first node in this screen's hierarchy
        if self.screenWiseData[screen] == nil {
            self.screenWiseData[screen] = TrackingDataCollection()
        }
        self.screenWiseData[screen]?.addData(nodeInfo: nodeInfo, parentId: nodeInfo.parentId)
    }

    func removeData(for screen: String, withId trackDataId: String) -> [TrackingData]? {
        return self.screenWiseData[screen]?.deleteData(nodeId: trackDataId)
    }

    ///update track data from given NodeInfo
    func updateData(_ nodeInfo: NodeInfo) {

        let dataId = nodeInfo.trackingData.uniqueId

        ///update absolute frame,% visibility and impression tracking
        if let oldData = (self.screenWiseData[nodeInfo.screen]?.getData(for: dataId)?.nodeInfo) {
            oldData.absoluteFrame = nodeInfo.absoluteFrame
            oldData.trackingData.impressionTracking = nodeInfo.trackingData.impressionTracking
            oldData.trackingData.percentVisibility = nodeInfo.trackingData.percentVisibility

            self.screenWiseData[nodeInfo.screen]?.update(nodeInfo: oldData, for: dataId)
        }

    }

    ///updates visibility % using scroll delta and returns any view-start/view-end events (in form of a map of trackData:event) to be bubbled up
    func updateVisiblityDataUsing(_ eventData: EventData) -> [TrackingData : TrackableEvent]? {
        
        ///store any view Events by observing change in % visibility for each content
        var viewEvents : [TrackingData : TrackableEvent]? = [:]

        ///update only the tracking data affected by this scroll event
        if let scrollData = eventData as? ScrollEventData, let trackingData = self.screenWiseData[scrollData.screen]?.getData(for: String(scrollData.scrollSourceTag)), let childIdArr = trackingData.childNodes {
            
            //for each child, update frames and get any view events if they occur while updating the % visibility
            for child in childIdArr {
                if let childViewEvents = self.updateFramesRecursively(on: scrollData.screen, scrollTag: child.nodeInfo.trackingData.uniqueId, scrollDelta: scrollData.scrollOffsetDelta){
                
                    for (data,event) in childViewEvents{
                        viewEvents?[data] = event
                    }
                }
                
            }
        }
        
        return viewEvents
    }

    ///update track data from given view event
    internal func updateData(from event: TrackableEvent) {

        if let viewData = event.eventData as? ViewEventData {
            
            let dataId = viewData.uniqueId
            
            if let oldData = self.screenWiseData[viewData.screen]?.getData(for: dataId)?.nodeInfo {
                oldData.absoluteFrame = viewData.absoluteFrame
                oldData.trackingData.percentVisibility = self.calculateVisibility(for: oldData)
                oldData.trackingData.isVisible = viewData.isVisible
                
                //TODO Separate out the ViewDataModels for viewStartedEvent and other view events
                if event.eventType == EventNames.viewStarted {
                    oldData.trackingData.startTime = Date()
                }
            }
        }
    }

    ///get view event from change in visibility so that view start/view end can be detected
    fileprivate func getViewEventType(oldVisibility : Float, newVisibility: Float) -> Int {
        if oldVisibility<=0 && newVisibility > 0 { return 1 } // view start event
        else if oldVisibility > 0 && newVisibility <= 0 { return 2} //view end event
        return 0
    }
    
    ///update frames for each node in the subtree of view identified by scrollTag and pass on any view events on the way
    internal func updateFramesRecursively(on screen: String, scrollTag: String?, scrollDelta: CGPoint) -> [TrackingData : TrackableEvent]? {

        var viewEvents : [TrackingData :  TrackableEvent]? = [:]
        
        if let tag = scrollTag, let trackingData = self.screenWiseData[screen]?.getData(for: tag) {

            //update the absolute frame from offset delta
            var frame: CGRect = trackingData.nodeInfo.absoluteFrame
            frame.origin.x -= scrollDelta.x
            frame.origin.y -= scrollDelta.y
            trackingData.nodeInfo.absoluteFrame = frame

            let oldVisibility = trackingData.nodeInfo.trackingData.percentVisibility

            //calculate and update the % visiblity
            let visibility = self.calculateVisibility(for: trackingData.nodeInfo)
            trackingData.nodeInfo.trackingData.percentVisibility = visibility
            
            //Only if this is a content, then detect and pass on the view events based on visibility delta
            if !trackingData.nodeInfo.trackingData.isWidget{

                //get view event Type
                let viewEventType = getViewEventType(oldVisibility: oldVisibility, newVisibility: visibility)
                
                switch viewEventType {
                    
                case 1:
                    //fire view start and reset the relevant data
                    trackingData.nodeInfo.trackingData.startTime = Date()
                    trackingData.nodeInfo.trackingData.maxPercentVisibility = visibility
                    viewEvents?[trackingData.nodeInfo.trackingData] = TrackableEvent(eventType: EventNames.viewStarted, eventData: nil)
                    break
                    
                case 2:
                    //fire view end
                    viewEvents?[trackingData.nodeInfo.trackingData] = TrackableEvent(eventType: EventNames.viewEnded, eventData: nil)
                    break
                    
                default: break
                    //no changes
                }
            }

            //update the data
            self.screenWiseData[screen]?.update(nodeInfo: trackingData.nodeInfo, for: tag)

            //update the frame of each child of this view from the offset delta and bubble up view events if any
            if let childIdArr = trackingData.childNodes {
                for child in childIdArr {
                    
                    if let childViewEvents = self.updateFramesRecursively(on: screen, scrollTag: child.nodeInfo.trackingData.uniqueId, scrollDelta: scrollDelta){
                        
                        //bubble up view events
                        for (data,event) in childViewEvents{
                            viewEvents?[data] = event
                        }
                    }
                }
            }
        }
        return viewEvents
    }

    ///calculate the visibility of the node in the screen window
    internal func calculateVisibility(for nodeInfo: NodeInfo) -> Float {

        var visibility: Float = 0.0
        
        ///current frame with respect to Window
        var visibleFrame = nodeInfo.absoluteFrame
        
        ///Area right now
        let totalArea: Float = Float(visibleFrame.size.width) * Float(visibleFrame.size.height)
        
        ///tag of the scroll view whose scrolling affects this view's frame
        var tag: String? = nodeInfo.affectingScrollViewTag

        ///recursively calculate intersection with every scrollview/parent trackable in the parent hierarchy untill window and then update visible frame
        while let scrollTag = tag, let scrollViewData = self.screenWiseData[nodeInfo.screen]?.getData(for: scrollTag)?.nodeInfo {
            
            let parentFrame = scrollViewData.absoluteFrame
            visibleFrame = visibleFrame.intersection(parentFrame)

            tag = scrollViewData.parentId
        }

        //visible Area after calculating intersection with all trackable parent views till window
        let visibleArea: Float = Float(visibleFrame.size.width) * Float(visibleFrame.size.height)

        //% visibility calculation
        if totalArea > 0 {
            visibility = visibleArea * 100 / totalArea
        }

        return visibility
    }

    internal func fetchData(for id: String, screen: String) -> TrackingData? {
        return self.screenWiseData[screen]?.getData(for: id)?.nodeInfo.trackingData
    }

    ///traverse the subtree of the specified node id and perform closure forEachNode while traversing; return the array of all nodes in subtree at last
    func fetchAllTreeNodes(for id: String, screen: String, forEachNode: (NodeInfo)->()) -> [TrackingData]? {

        var allData: [TrackingData]? = []
        let currentEntityId = id

        if let currentNode = self.screenWiseData[screen]?.getData(for: currentEntityId) {
            allData?.append(currentNode.nodeInfo.trackingData)

            if let childNodes = currentNode.childNodes {
                
                for childNode in childNodes {
                    
                    if let nodes = self.fetchAllTreeNodes(for: childNode.nodeInfo.trackingData.uniqueId, screen: screen, forEachNode: forEachNode) {
                        allData?.append(contentsOf: nodes)
                    }
                }
            }
        }
        return allData
    }

    ///update each node in the screen with given visibility
    func updateAllData(for screen: String, isVisible: Bool) ->[TrackingData]?{
        
        //if the tree for this screen exists
        if let rootId = self.screenWiseData[screen]?.trackDataTree?.nodeInfo.trackingData.uniqueId{
            
            return fetchAllTreeNodes(for: rootId, screen: screen, forEachNode: { (nodeInfo: NodeInfo)->() in nodeInfo.trackingData.isVisible = isVisible } )
        }
        
        return nil
        
    }
}
