//
//  TrackableObjcUICollectionView.m
//  Flipkart
//
//  Created by Krati Jain on 19/04/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import "TrackableObjcUICollectionView.h"
#import <GenericTrackingFramework/GenericTrackingFramework-Swift.h>

@interface TrackableObjcUICollectionView()
@property (nonatomic,strong) TrackableCollectionViewWrapperDelegate *wrapperDelegate;

@end

@implementation TrackableObjcUICollectionView

///either of the below two init should be called to begin tracking the collection View
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _isScrollable = YES;
        _wrapperDelegate = [[TrackableCollectionViewWrapperDelegate alloc]initWithCollectionView:self];
    }
    return self;
}

///Instantiate with frame and collection view layout
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        _isScrollable = YES;
        _wrapperDelegate = [[TrackableCollectionViewWrapperDelegate alloc]initWithCollectionView:self];
    }
    return self;
}

///get all the visible cells as the trackable children of this collection view if cells conform to ContentTrackableEntityProtocol
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

///every time the tracker is set and view is scrollable, register the tableNode and give it a unique tag; create its track data
-(void)setTracker:(ScreenLevelTracker * _Nullable)tracker {
    
    if (_isScrollable) {
        [tracker registerScrollView:self];
        _trackData = [[FrameData alloc]initWithUId:[@(self.tag) stringValue] frame:CGRectZero impressionTracking:nil isWidget:NO tags:nil];
    }
    
    _tracker = tracker;
    
    //this tracker is the trackerDelegate in the wrapperDelegate
    _wrapperDelegate.trackerDelegate = tracker;
}

///returns the wrapper delegate
-(id<UICollectionViewDelegate>)delegate {
    return super.delegate;
}

///set the delegate as wrapper delegate's delegate and then set wrapper delegate as the scrollview's delegate this way we support both the delegates and pass on events to both
-(void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    _wrapperDelegate.delegate = delegate;
    _wrapperDelegate.trackerDelegate = _tracker;
    super.delegate = _wrapperDelegate;
}

///When this view gets attached to window, update its tracking data with absolute frame with respect to window and track view appear event
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
