//
//  TrackableObjcScrollView.h
//  Flipkart
//
//  Created by Krati Jain on 20/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScreenLevelTracker;
@class FrameData;


@protocol ContentTrackableEntityProtocol;


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything" // To get rid of 'Cannot find protocol definition'

///Trackable Objective C ScrollView
@interface TrackableObjcScrollView : UIScrollView<ContentTrackableEntityProtocol>

#pragma mark ContentTrackableEntityProtocol property
@property (nonatomic, strong) ScreenLevelTracker * _Nullable tracker;
@property (nonatomic, strong) FrameData * _Nullable trackData;
@property (nonatomic) BOOL isScrollable;
@property (nonatomic,strong) NSMutableArray<id <ContentTrackableEntityProtocol>> * _Nullable trackableChildren;

@property (nonatomic,assign) CGPoint lastTrackedOffset;

@end
