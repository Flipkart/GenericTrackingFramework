//
//  TrackableUITableView.swift
//  Flipkart
//
//  Created by Krati Jain on 04/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

import UIKit

//Trackable swift Table View
open class TrackableUITableView: UITableView, ContentTrackableEntityProtocol {

    public var trackData: FrameData?
    public var isScrollable: Bool = true
    
    //last offset which was tracked by the framework
    var lastTrackedOffset: CGPoint = CGPoint.zero

    fileprivate lazy var wrapperDelegate: TrackableTableViewWrapperDelegate? = self.initializeWrapperDelegate()

    fileprivate func initializeWrapperDelegate() -> TrackableTableViewWrapperDelegate {

        let tempWrapperDelegate = TrackableTableViewWrapperDelegate(tableView: self)
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

    override weak open var delegate: UITableViewDelegate? {

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

@objc public class TrackableTableViewWrapperDelegate: NSObject, UITableViewDelegate {

    @objc public weak var trackerDelegate: ScreenLevelTracker?
    @objc public weak var delegate: UITableViewDelegate?
    weak var tableView: UITableView?

    @objc public init(tableView: TrackableUITableView) {

        self.tableView = tableView
        super.init()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if let trackableCell = cell.contentView.subviews.first as? ContentTrackableEntityProtocol {
            let scrollTag = String(tableView.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: trackableCell, event: EventNames.viewWillDisplay, scrollTag: scrollTag, parentId: scrollTag)
        }

        if self.delegate?.responds(to: #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:))) ?? false {
            self.delegate?.tableView!(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if let trackableCell = cell.contentView.subviews.first as? ContentTrackableEntityProtocol {
            let scrollTag = String(tableView.tag)
            self.trackerDelegate?.trackViewHierarchyFor(view: trackableCell, event: EventNames.viewEnded, scrollTag: scrollTag, parentId: scrollTag)
        }

        if self.delegate?.responds(to: #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:))) ?? false {
            self.delegate?.tableView!(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let newContentOffset = scrollView.contentOffset
/*
        if let trackableObjTableView = tableView as? TrackableObjcUITableView {
            if self.trackerDelegate?.trackScrollEvent(scrollView, lastTrackedOffset: trackableObjTableView.lastTrackedOffset) ?? false {
                trackableObjTableView.lastTrackedOffset = newContentOffset
            }
        }
*/
        if let trackableUITableView = tableView as? TrackableUITableView {
            if self.trackerDelegate?.trackScrollEvent(scrollView, lastTrackedOffset: trackableUITableView.lastTrackedOffset) ?? false {
                trackableUITableView.lastTrackedOffset = newContentOffset
            }
        }

        self.delegate?.scrollViewDidScroll?(scrollView)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.delegate?.tableView?(tableView, heightForRowAt: indexPath) ?? 0
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.delegate?.tableView?(tableView, heightForHeaderInSection: section) ?? 0
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.delegate?.tableView?(tableView, viewForHeaderInSection: section) ?? nil
    }
}
