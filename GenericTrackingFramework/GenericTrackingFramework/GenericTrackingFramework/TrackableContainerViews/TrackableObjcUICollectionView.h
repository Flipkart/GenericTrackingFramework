//
//  TrackableObjcUICollectionView.h
//  Flipkart
//
//  Created by Krati Jain on 19/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScreenLevelTracker;
@class FrameData;

@protocol ContentTrackableEntityProtocol;

//Trackable objc Collection View
@interface TrackableObjcUICollectionView : UICollectionView<ContentTrackableEntityProtocol>

#pragma mark ContentTrackableEntityProtocol property
@property (nonatomic, strong) ScreenLevelTracker * _Nullable tracker;
@property (nonatomic, strong) FrameData * _Nullable trackData;
@property (nonatomic) BOOL isScrollable;

//last offset which was tracked by the framework
@property (nonatomic,assign) CGPoint lastTrackedOffset;

@end
