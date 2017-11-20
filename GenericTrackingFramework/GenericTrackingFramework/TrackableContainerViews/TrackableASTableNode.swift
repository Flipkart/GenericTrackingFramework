//
//  TrackableASTableNode.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

/***
 Uncomment to support tracking for ASTableNode from Async Display Kit
 ***/
/*
import Foundation
import AsyncDisplayKit

//Trackable ASTableNode
open class TrackableASTableNode: ASTableNode, ContentTrackableEntityProtocol {

    internal var trackData: FrameData?
    internal var isScrollable: Bool = true
    
    //last offset which was tracked by the framework
    var lastTrackedOffset: CGPoint = CGPoint.zero

    fileprivate lazy var wrapperDelegate: WrapperDelegate? = self.initializeWrapperDelegate()

    fileprivate func initializeWrapperDelegate() -> WrapperDelegate {

        let tempWrapperDelegate = WrapperDelegate(tableNode: self)
        return tempWrapperDelegate
    }

    weak open var tracker: ScreenLevelTracker? {
        
        //every time the tracker is set and view is scrollable, register the tableNode and give it a unique tag; create its track data
        didSet {
            if isScrollable {
                tracker?.registerScrollView(self.view)
                trackData = FrameData(uId: String(self.view.tag), frame: CGRect.zero, impressionTracking: nil)
            }
            
            //this tracker is the trackerDelegate in the wrapperDelegate
            wrapperDelegate?.trackerDelegate = tracker
        }
    }

    override weak open var delegate: ASTableDelegate? {

        get {
            //returns the wrapper delegate
            return super.delegate
        }
        set {
            //set the delegate as wrapper delegate's delegate and then set wrapper delegate as the scrollview's delegate
            //this way we support both the delegates and pass on events to both
            wrapperDelegate?.delegate = newValue
            wrapperDelegate?.trackerDelegate = tracker
            super.delegate = wrapperDelegate
        }
    }

    internal func getTrackableChildren() -> [ContentTrackableEntityProtocol]? {

        return self.visibleNodes.flatMap { (node) in
            return node.subnodes.flatMap({ (subnode) in
                subnode as? ContentTrackableEntityProtocol
            })
        }
    }

    //when the table node becomes visible then set its absolute frame and track view appear event
    open override func didEnterVisibleState() {

        trackData?.absoluteFrame = (self.convert(self.bounds, to: nil))
        self.tracker?.trackViewAppear(trackData: trackData)
    }
}

//Custom delegate for the TrackableASTableNode ; This has both the tracking Delegate as well as delegate set from its creating view
fileprivate class WrapperDelegate: NSObject, ASTableDelegate {

    weak var trackerDelegate: ScreenLevelTracker?
    weak var delegate: ASTableDelegate?
    
    //weak reference to tracked tableNode so that last tracked offset can be fetched
    weak var tableNode: TrackableASTableNode?

    init(tableNode: TrackableASTableNode) {

        self.tableNode = tableNode
        super.init()
    }

    public func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {

        //track view will display
        if let cell = node as? ContentTrackableEntityProtocol {
            cell.trackData?.absoluteFrame = node.view.convert(node.view.bounds, to: nil)
            let scrollTag = String(tableNode.view.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: cell, event: EventNames.viewWillDisplay, scrollTag: scrollTag, parentId: scrollTag)
        }

        //pass on the event to original delegate if it exists
        if self.delegate?.responds(to: #selector(ASTableDelegate.tableNode(_:willDisplayRowWith:))) ?? false {
            self.delegate?.tableNode!(tableNode, willDisplayRowWith: node)
        }
    }

    public func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {

        //track view ended event
        if let cell = node as? ContentTrackableEntityProtocol {
            let scrollTag = String(tableNode.view.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: cell, event: EventNames.viewEnded, scrollTag: scrollTag, parentId: scrollTag)
        }

        //pass on the event to the original delegate if it exists
        if self.delegate?.responds(to: #selector(ASTableDelegate.tableNode(_:didEndDisplayingRowWith:))) ?? false {
            self.delegate?.tableNode!(tableNode, didEndDisplayingRowWith: node)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let newContentOffset: CGPoint = scrollView.contentOffset

        //track scroll event with last tracked offset
        if self.trackerDelegate?.trackScrollEvent(scrollView, lastTrackedOffset: (tableNode?.lastTrackedOffset ?? CGPoint.zero)) ?? false {
            self.tableNode?.lastTrackedOffset = newContentOffset
        }
        
        //pass on the event to the original delegate
        self.delegate?.scrollViewDidScroll?(scrollView)
    }

    /**
     Catch all the method calls which arent implemented here. The following 2 methods will forward the selectors to delegate MAGICALLY, without writing their implementations here.
     **/
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        guard let delegate = delegate else {
            return nil
        }
        if (delegate.responds(to: aSelector)) {
            return delegate
        }
        return nil;
    }

    override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || delegate?.responds(to: aSelector) == true
    }

}
 */
