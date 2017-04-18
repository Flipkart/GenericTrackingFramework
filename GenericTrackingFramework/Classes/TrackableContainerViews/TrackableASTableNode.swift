//
//  TrackableASTableNode.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import AsyncDisplayKit

open class TrackableASTableNode : ASTableNode,ContentTrackableEntityProtocol{
    
    internal var trackData: FrameData?
    internal var isScrollable: Bool = true
    private var wrapperDelegate:WrapperDelegate? = WrapperDelegate()
    weak open var tracker: ScreenLevelTracker?{
        didSet{
            if isScrollable{
                tracker?.registerScrollView(self.view)
                trackData = FrameData(uId: String(self.view.tag), frame: CGRect.zero, wigTracking: nil)
            }
            wrapperDelegate?.trackerDelegate = tracker
        }
    }
    
    override weak open var delegate: ASTableDelegate?{
        get{
            return super.delegate
        }
        set{
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

    open override func didEnterVisibleState() {
        trackData?.absoluteFrame = (self.convert(self.bounds, to: nil))
        self.tracker?.trackViewAppear(trackData: trackData)
    }
}

fileprivate class WrapperDelegate: NSObject,ASTableDelegate{
    weak var trackerDelegate : ScreenLevelTracker?
    weak var delegate : ASTableDelegate?
    
    override init() {
        super.init()
    }
    public func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode){
        if let cell = node as? ContentTrackableEntityProtocol{
            cell.trackData?.absoluteFrame = node.view.convert(node.view.bounds, to: nil)
            let scrollTag =  String(tableNode.view.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: cell, event: .viewWillDisplay,scrollTag:scrollTag,parentId:scrollTag)
        }
        if self.delegate?.responds(to:#selector(ASTableDelegate.tableNode(_:willDisplayRowWith:))) ?? false{
            self.delegate?.tableNode!(tableNode, willDisplayRowWith: node)
        }
    }
    
    public func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode){
        if let cell = node as? ContentTrackableEntityProtocol{
            let scrollTag =  String(tableNode.view.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: cell, event: .viewEnded,scrollTag:scrollTag,parentId:scrollTag)
        }
        if self.delegate?.responds(to:#selector(ASTableDelegate.tableNode(_:didEndDisplayingRowWith:))) ?? false{
            self.delegate?.tableNode!(tableNode, didEndDisplayingRowWith: node)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.trackerDelegate?.trackScrollEvent(scrollView)
        if let _ = self.delegate?.responds(to: #selector(UIScrollViewDelegate.scrollViewDidScroll(_:))){
            self.delegate?.scrollViewDidScroll!(scrollView)
        }
    }
}

