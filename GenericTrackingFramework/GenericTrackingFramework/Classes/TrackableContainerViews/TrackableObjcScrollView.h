//
//  TrackableObjcScrollView.h
//  Flipkart
//
//  Created by Krati Jain on 20/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContentTrackableEntityProtocol;

//Trackable Objective C ScrollView
@interface TrackableObjcScrollView : UIScrollView<ContentTrackableEntityProtocol>

#pragma mark ContentTrackableEntityProtocol property
@property (nonatomic, strong) ScreenLevelTracker * _Nullable tracker;
@property (nonatomic, strong) FrameData * _Nullable trackData;
@property (nonatomic) BOOL isScrollable;
@property (nonatomic,strong) NSMutableArray<id <ContentTrackableEntityProtocol>> * _Nullable trackableChildren;

@property (nonatomic,assign) CGPoint lastTrackedOffset;

@end
