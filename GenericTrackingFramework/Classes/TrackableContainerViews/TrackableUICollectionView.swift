//
//  TrackableUICollectionView.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import UIKit

open class TrackableUICollectionView : UICollectionView{
    
    internal var trackData: FrameData?
    internal var isScrollable: Bool = true
    private var wrapperDelegate:WrapperDelegate? = WrapperDelegate()
    weak open var tracker: ScreenLevelTracker?{
        didSet{
            if isScrollable{
                tracker?.registerScrollView(self)
                trackData = FrameData(uId: String(self.tag), frame: CGRect.zero, wigTracking: nil)
            }
            wrapperDelegate?.trackerDelegate = tracker
        }
    }
    
    override weak open var delegate: UICollectionViewDelegate?{
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
        return self.visibleCells.flatMap { (node) in
            return node.subviews.flatMap({ (subnode) in
                subnode as? ContentTrackableEntityProtocol
            })
        }
        
    }
}

fileprivate class WrapperDelegate: NSObject,UICollectionViewDelegate{
    weak var trackerDelegate : ScreenLevelTracker?
    weak var delegate : UICollectionViewDelegate?
    
    override init() {
        super.init()
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let trackableCell = cell as? ContentTrackableEntityProtocol{
            let scrollTag = String(collectionView.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: trackableCell, event: .viewWillDisplay,scrollTag: scrollTag,parentId:scrollTag)
        }
        if self.delegate?.responds(to:#selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:))) ?? false{
            self.delegate?.collectionView!(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let trackableCell = cell as? ContentTrackableEntityProtocol{
            let scrollTag = String(collectionView.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: trackableCell, event: .viewEnded,scrollTag:scrollTag,parentId:scrollTag)
        }
        if self.delegate?.responds(to:#selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:))) ?? false{
            self.delegate?.collectionView!(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.trackerDelegate?.trackScrollEvent(scrollView)
        if let _ = self.delegate?.responds(to: #selector(UIScrollViewDelegate.scrollViewDidScroll(_:))){
            self.delegate?.scrollViewDidScroll!(scrollView)
        }
    }
}
