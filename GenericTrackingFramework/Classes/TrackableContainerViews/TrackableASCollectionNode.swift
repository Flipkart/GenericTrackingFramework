//
//  TrackableASCollectionNode.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import AsyncDisplayKit


open class TrackableASCollectionNode : ASCollectionNode,ContentTrackableEntityProtocol{
    
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
    
    override weak open var delegate: ASCollectionDelegate?{
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
}

fileprivate class WrapperDelegate: NSObject,ASCollectionDelegate{
    weak var trackerDelegate : ScreenLevelTracker?
    weak var delegate : ASCollectionDelegate?
    
    override init() {
        super.init()
    }
    public func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        if let cell = node as? ContentTrackableEntityProtocol{
            let scrollTag = String(collectionNode.view.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: cell, event: .viewWillDisplay,scrollTag: scrollTag,parentId:scrollTag)
        }
        if self.delegate?.responds(to:#selector(ASCollectionDelegate.collectionNode(_:willDisplayItemWith:))) ?? false{
            self.delegate?.collectionNode!(collectionNode, willDisplayItemWith: node)
        }
    }
    public func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        if let cell = node as? ContentTrackableEntityProtocol{
            let scrollTag = String(collectionNode.view.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: cell, event: .viewEnded,scrollTag: scrollTag,parentId:scrollTag)
        }
        if self.delegate?.responds(to:#selector(ASCollectionDelegate.collectionNode(_:didEndDisplayingItemWith:))) ?? false{
            self.delegate?.collectionNode!(collectionNode, didEndDisplayingItemWith: node)
        }
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.trackerDelegate?.trackScrollEvent(scrollView)
        if let _ = self.delegate?.responds(to: #selector(UIScrollViewDelegate.scrollViewDidScroll(_:))){
            self.delegate?.scrollViewDidScroll!(scrollView)
        }
    }
}
