//
//  TrackableObjcUITableView.h
//  Flipkart
//
//  Created by Krati Jain on 19/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScreenLevelTracker;
@class FrameData;

@protocol ContentTrackableEntityProtocol;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything" // To get rid of 'Cannot find protocol definition'

///Trackable objc TableView
@interface TrackableObjcUITableView : UITableView<ContentTrackableEntityProtocol>

#pragma mark ContentTrackableEntityProtocol property
@property (nonatomic, strong) ScreenLevelTracker * _Nullable tracker;
@property (nonatomic, strong) FrameData * _Nullable trackData;
@property (nonatomic) BOOL isScrollable;

///last offset which was tracked by the framework
@property (nonatomic,assign) CGPoint lastTrackedOffset;

@end
