//
//  TrackableObjcUITableView.m
//  Flipkart
//
//  Created by Krati Jain on 19/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import "TrackableObjcUITableView.h"
#import <GenericTrackingFramework/GenericTrackingFramework-Swift.h>

@interface TrackableObjcUITableView()
@property (nonatomic,strong) TrackableTableViewWrapperDelegate *wrapperDelegate;
@end

@implementation TrackableObjcUITableView

//This init should be called to begin tracking the table view
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isScrollable = YES;
        _wrapperDelegate = [[TrackableTableViewWrapperDelegate alloc]initWithTableView:(TrackableUITableView *)self];
    }
    return self;
}

- (NSArray<id <ContentTrackableEntityProtocol>> * _Nullable)getTrackableChildren {
    
    NSMutableArray<id<ContentTrackableEntityProtocol>> *trackableChildren = [@[] mutableCopy];
    
    for(UITableViewCell *cell in self.visibleCells){
        for(UIView * view in cell.contentView.subviews){
            if([view conformsToProtocol:@protocol(ContentTrackableEntityProtocol)]){
                [trackableChildren addObject:(id<ContentTrackableEntityProtocol>)view];
            }
        }
    }
    return trackableChildren;
}

//every time the tracker is set and view is scrollable, register the tableNode and give it a unique tag; create its track data
-(void)setTracker:(ScreenLevelTracker * _Nullable)tracker {
    
    if (_isScrollable) {
        [tracker registerScrollView:self];
        _trackData = [[FrameData alloc]initWithUId:[@(self.tag) stringValue] frame:CGRectZero impressionTracking:nil isWidget:NO tags:nil];
    }
    
    _tracker = tracker;
    
    //this tracker is the trackerDelegate in the wrapperDelegate
    _wrapperDelegate.trackerDelegate = tracker;
}

//returns the wrapper delegate
-(id<UITableViewDelegate>)delegate {
    return super.delegate;
}

//set the delegate as wrapper delegate's delegate and then set wrapper delegate as the scrollview's delegate
//this way we support both the delegates and pass on events to both
-(void)setDelegate:(id<UITableViewDelegate>)delegate {
    
    _wrapperDelegate.delegate = delegate;
    _wrapperDelegate.trackerDelegate = _tracker;
    super.delegate = _wrapperDelegate;
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
