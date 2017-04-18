//
//  TrackableUITableView.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//
import UIKit

open class TrackableUITableView : UITableView{
    
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
    
    override weak open var delegate: UITableViewDelegate?{
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
fileprivate class WrapperDelegate: NSObject,UITableViewDelegate{
    weak var trackerDelegate : ScreenLevelTracker?
    weak var delegate : UITableViewDelegate?
    
    override init() {
        super.init()
    }
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let trackableCell = cell as? ContentTrackableEntityProtocol{
            let scrollTag = String(tableView.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: trackableCell, event: .viewWillDisplay,scrollTag: scrollTag,parentId:scrollTag)
        }
        if self.delegate?.responds(to:#selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:))) ?? false{
            self.delegate?.tableView!(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let trackableCell = cell as? ContentTrackableEntityProtocol{
            let scrollTag =  String(tableView.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: trackableCell, event: .viewEnded,scrollTag:scrollTag,parentId:scrollTag)
        }
        if self.delegate?.responds(to:#selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:))) ?? false{
            self.delegate?.tableView!(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.trackerDelegate?.trackScrollEvent(scrollView)
        if let _ = self.delegate?.responds(to: #selector(UIScrollViewDelegate.scrollViewDidScroll(_:))){
            self.delegate?.scrollViewDidScroll!(scrollView)
        }
    }
}
