//
//  TrackableRCTScrollView.h
//  Flipkart
//
//  Created by Krati Jain on 11/05/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTScrollView.h>


//Trackable RCTScrollView for react native
@interface TrackableRCTScrollView : RCTScrollView<ContentTrackableEntityProtocol>

#pragma mark ContentTrackableEntityProtocol property
@property (nonatomic, strong) ScreenLevelTracker * _Nullable tracker;
@property (nonatomic, strong) FrameData * _Nullable trackData;
@property (nonatomic) BOOL isScrollable;
@property (nonatomic,strong) NSMutableArray<id <ContentTrackableEntityProtocol>> * _Nullable trackableChildren;

//last offset which was tracked by the framework
@property (nonatomic,assign) CGPoint lastTrackedOffset;

@end
