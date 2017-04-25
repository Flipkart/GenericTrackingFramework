//
//  TrackableASCollectionNode.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import Foundation
import AsyncDisplayKit

open class TrackableASCollectionNode: ASCollectionNode, ContentTrackableEntityProtocol {

    internal var trackData: FrameData?
    internal var isScrollable: Bool = true
    var lastTrackedOffset: CGPoint = CGPoint.zero

    fileprivate lazy var wrapperDelegate: WrapperDelegate? = self.initializeWrapperDelegate()

    fileprivate func initializeWrapperDelegate() -> WrapperDelegate {
        
        let tempWrapperDelegate = WrapperDelegate(collectionNode: self)
        return tempWrapperDelegate
    }

    weak open var tracker: ScreenLevelTracker? {
        
        didSet {
            if isScrollable {
                tracker?.registerScrollView(self.view)
                trackData = FrameData(uId: String(self.view.tag), frame: CGRect.zero, impressionTracking: nil)
            }
            wrapperDelegate?.trackerDelegate = tracker
        }
    }

    override weak open var delegate: ASCollectionDelegate? {
        
        get {
            return super.delegate
        }
        set {
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

fileprivate class WrapperDelegate: NSObject, ASCollectionDelegate {

    weak var trackerDelegate: ScreenLevelTracker?
    weak var delegate: ASCollectionDelegate?
    weak var collectionNode: TrackableASCollectionNode?

    init(collectionNode: TrackableASCollectionNode) {
        
        self.collectionNode = collectionNode
        super.init()
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {

        if let cell = node as? ContentTrackableEntityProtocol {
            let scrollTag = String(collectionNode.view.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: cell, event: EventNames.viewWillDisplay, scrollTag: scrollTag, parentId: scrollTag)
        }

        if self.delegate?.responds(to: #selector(ASCollectionDelegate.collectionNode(_:willDisplayItemWith:))) ?? false {
            self.delegate?.collectionNode!(collectionNode, willDisplayItemWith: node)
        }
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {

        if let cell = node as? ContentTrackableEntityProtocol {
            let scrollTag = String(collectionNode.view.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: cell, event: EventNames.viewEnded, scrollTag: scrollTag, parentId: scrollTag)
        }

        if self.delegate?.responds(to: #selector(ASCollectionDelegate.collectionNode(_:didEndDisplayingItemWith:))) ?? false {
            self.delegate?.collectionNode!(collectionNode, didEndDisplayingItemWith: node)
        }
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {

        if self.delegate?.responds(to: #selector(ASCollectionDelegate.collectionNode(_:constrainedSizeForItemAt:))) ?? false {
            return self.delegate?.collectionNode!(collectionNode, constrainedSizeForItemAt: indexPath) ?? ASSizeRangeZero
        }

        return ASSizeRangeZero
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return self.delegate?.shouldBatchFetch?(for: collectionNode) ?? false
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        self.delegate?.collectionNode?(collectionNode, willBeginBatchFetchWith: context)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let newContentOffset: CGPoint = scrollView.contentOffset

        if self.trackerDelegate?.trackScrollEvent(scrollView, lastTrackedOffset: (collectionNode?.lastTrackedOffset ?? CGPoint.zero)) ?? false {
            self.collectionNode?.lastTrackedOffset = newContentOffset
        }

        self.delegate?.scrollViewDidScroll?(scrollView)
    }
}
