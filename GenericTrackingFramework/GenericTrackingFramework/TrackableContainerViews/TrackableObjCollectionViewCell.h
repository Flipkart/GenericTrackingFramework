//
//  TrackableObjCollectionViewCell.h
//  Flipkart
//
//  Created by Krati Jain on 02/06/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScreenLevelTracker;
@class FrameData;
@protocol ContentTrackableEntityProtocol;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything" // To get rid of 'Cannot find protocol definition'

///Trackable UICollectionViewCell
@interface TrackableObjCollectionViewCell : UICollectionViewCell<ContentTrackableEntityProtocol>

#pragma mark ContentTrackableEntityProtocol property
@property (nonatomic, strong , readwrite) ScreenLevelTracker * _Nullable tracker;
@property (nonatomic, strong) FrameData * _Nullable trackData;
@property (nonatomic) BOOL isScrollable;
@property (nonatomic,strong) NSString * _Nullable navigationContextId;

@end
