//
//  TrackableObjCollectionViewCell.m
//  Flipkart
//
//  Created by Krati Jain on 02/06/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import "TrackableObjCollectionViewCell.h"

@implementation TrackableObjCollectionViewCell

#pragma mark ContentTrackableEntity Protocol methods
-(void)setTracker:(ScreenLevelTracker *)tracker{
    _tracker = tracker;
}
- (NSArray<id <ContentTrackableEntityProtocol>> * _Nullable)getTrackableChildren{
    return nil;
}

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
