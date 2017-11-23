//
//  TrackableObjCollectionViewCell.m
//  Flipkart
//
//  Created by Krati Jain on 02/06/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import "TrackableObjCollectionViewCell.h"
#import <GenericTrackingFramework/GenericTrackingFramework-Swift.h>

@implementation TrackableObjCollectionViewCell

#pragma mark ContentTrackableEntity Protocol methods
///Sets the ScreenLevelTracker so that events can be tracked and processed
-(void)setTracker:(ScreenLevelTracker *)tracker{
    _tracker = tracker;
}
///get array of trackable children for this collection view cell
- (NSArray<id <ContentTrackableEntityProtocol>> * _Nullable)getTrackableChildren{
    return nil;
}

///when this collection view cell gets attached to the window, find its absolute frame with respect to window and update its tracking data & track view appear event 
- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    //track view appear
    if(self.window){
        //get the absolute frame
        CGRect frame = [self convertRect:self.bounds toView:nil];
        self.trackData.absoluteFrame = frame;
        [self.tracker trackViewAppearWithTrackData:self.trackData];
    }
}
@end
