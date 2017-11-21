//
//  TrackableUICollectionView.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import UIKit

//Trackable swift collection view
open class TrackableUICollectionView: UICollectionView, ContentTrackableEntityProtocol {

    public var trackData: FrameData?
    public var isScrollable: Bool = true
    
    //last offset which was tracked by the framework
    var lastTrackedOffset: CGPoint = CGPoint.zero

    fileprivate lazy var wrapperDelegate: TrackableCollectionViewWrapperDelegate? = self.initializeWrapperDelegate()

    fileprivate func initializeWrapperDelegate() -> TrackableCollectionViewWrapperDelegate {

        let tempWrapperDelegate = TrackableCollectionViewWrapperDelegate(collectionView: self)
        return tempWrapperDelegate
    }

    weak open var tracker: ScreenLevelTracker? {

        didSet {
            if isScrollable {
                tracker?.registerScrollView(self)
                trackData = FrameData(uId: String(self.tag), frame: CGRect.zero, impressionTracking: nil)
            }
            wrapperDelegate?.trackerDelegate = tracker
        }
    }

    override weak open var delegate: UICollectionViewDelegate? {

        get {
            return super.delegate
        }
        set {
            wrapperDelegate?.delegate = newValue
            wrapperDelegate?.trackerDelegate = tracker
            super.delegate = wrapperDelegate
        }
    }

    public func getTrackableChildren() -> [ContentTrackableEntityProtocol]? {

        return self.visibleCells.flatMap { (node) in
            return node.subviews.flatMap({ (subnode) in
                subnode as? ContentTrackableEntityProtocol
            })
        }
    }

    open override func didMoveToWindow() {

        if self.window != nil {
            trackData?.absoluteFrame = (self.convert(self.bounds, to: nil))
            self.tracker?.trackViewAppear(trackData: trackData)
        }
    }
}

@objc public class TrackableCollectionViewWrapperDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @objc public weak var trackerDelegate: ScreenLevelTracker?
    @objc public weak var delegate: UICollectionViewDelegate?
    weak var collectionView: UICollectionView?

    @objc public init(collectionView: UICollectionView) {

        self.collectionView = collectionView
        super.init()
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let trackableCell = cell as? ContentTrackableEntityProtocol {
            let scrollTag = String(collectionView.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: trackableCell, event: EventNames.viewWillDisplay, scrollTag: scrollTag, parentId: scrollTag)
        }

        if self.delegate?.responds(to: #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:))) ?? false {
            self.delegate?.collectionView!(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let trackableCell = cell as? ContentTrackableEntityProtocol {
            let scrollTag = String(collectionView.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: trackableCell, event: EventNames.viewEnded, scrollTag: scrollTag, parentId: scrollTag)
        }

        if self.delegate?.responds(to: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:))) ?? false {
            self.delegate?.collectionView!(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let newContentOffset: CGPoint = scrollView.contentOffset

        if let trackableObjcCollection = collectionView as? TrackableObjcUICollectionView {
            if self.trackerDelegate?.trackScrollEvent(scrollView, lastTrackedOffset: trackableObjcCollection.lastTrackedOffset) ?? false {
                trackableObjcCollection.lastTrackedOffset = newContentOffset
            }
        }

        if let trackableCollection = collectionView as? TrackableUICollectionView {
            if self.trackerDelegate?.trackScrollEvent(scrollView, lastTrackedOffset: trackableCollection.lastTrackedOffset) ?? false {
                trackableCollection.lastTrackedOffset = newContentOffset
            }
        }

        self.delegate?.scrollViewDidScroll?(scrollView)
    }/*

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    //CollectionViewFlowDelegate related methods
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let flowDelegate = self.delegate as? UICollectionViewDelegateFlowLayout {
            return flowDelegate.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize.zero
        }
        return CGSize.zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        if let flowDelegate = self.delegate as? UICollectionViewDelegateFlowLayout {
            return flowDelegate.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: section) ?? UIEdgeInsets.zero
        }
        return UIEdgeInsets.zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        if let flowDelegate = self.delegate as? UICollectionViewDelegateFlowLayout {
            return flowDelegate.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) ?? CGSize.zero
        }
        return CGSize.zero
    }
    */
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        guard let delegate = self.delegate else {
            return nil
        }
        if (delegate.responds(to: aSelector)) {
            return delegate
        }
        return nil;
    }
    
    public override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || delegate?.responds(to: aSelector) == true
    }
}
