//
//  TrackableRCTScrollView.m
//  Flipkart
//
//  Created by Krati Jain on 11/05/17.
//  Copyright © 2017 flipkart.com. All rights reserved.
//

#import "TrackableRCTScrollView.h"
#import "AdContainerView.h"
#import "Flipkart-Swift.h"

//Custom delegate for the TrackableRCTScrollView ; This has both the tracking Delegate as well as delegate set from its creating view
@interface TrackableRCTScrollViewDelegate : NSObject<UIScrollViewDelegate>

@property (nonatomic,weak) ScreenLevelTracker *trackerDelegate;
@property (nonatomic,weak) id<UIScrollViewDelegate> delegate;

//weak reference to tracked scroll view so that last tracked offset can be fetched
@property (nonatomic,weak) TrackableRCTScrollView *trackedScrollView;

- (instancetype)initWithScrollView:(TrackableRCTScrollView *)rctView;

@end

@implementation TrackableRCTScrollViewDelegate

- (instancetype)initWithScrollView:(TrackableRCTScrollView *)rctView
{
    self = [super init];
    if (self) {
        self.trackedScrollView = rctView;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //track the scroll event with the last tracked offset
    [self.trackerDelegate trackScrollEvent:scrollView lastTrackedOffset:self.trackedScrollView.lastTrackedOffset];
    
    //pass on the event to the delegate set by the parent view
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}
@end



@interface TrackableRCTScrollView()
@property (nonatomic,strong) TrackableRCTScrollViewDelegate *wrapperDelegate;
@end

@implementation TrackableRCTScrollView

//Note: This is the init which will register the scroll view for tracking; this init must be called
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isScrollable = YES;
        _wrapperDelegate = [[TrackableRCTScrollViewDelegate alloc]initWithScrollView:self];
    }
    return self;
}

//every time the tracker is set and view is scrollable, register the scrollview and give it a unique tag; create its track data
-(void)setTracker:(ScreenLevelTracker * _Nullable)tracker {
    
    if (_isScrollable) {
        [tracker registerScrollView:self.scrollView];
        _trackData = [[FrameData alloc]initWithUId:[@(self.scrollView.tag) stringValue] frame:CGRectZero impressionTracking:nil isWidget:NO tags:nil];
    }
    _tracker = tracker;
    
    //this tracker is the trackerDelegate in the wrapperDelegate
    _wrapperDelegate.trackerDelegate = tracker;
}

//returns the wrapper delegate
-(id<UIScrollViewDelegate>)delegate {
    return self.scrollView.delegate;
}

//set the delegate as wrapper delegate's delegate and then set wrapper delegate as the scrollview's delegate
//this way we support both the delegates and pass on events to both
-(void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    
    _wrapperDelegate.delegate = delegate;
    _wrapperDelegate.trackerDelegate = _tracker;
    self.scrollView.delegate = _wrapperDelegate;
}

- (NSArray<id <ContentTrackableEntityProtocol>> * _Nullable)getTrackableChildren {
    return self.trackableChildren;
}

//when view moves to window, update te frame and track view appear event
- (void)didMoveToWindow {
    
    [super didMoveToWindow];
    
    //track view appear
    if(self.window){
        
        //get the absolute frame w.r.t. window
        CGRect frame = [self convertRect:self.bounds toView:nil];
        self.trackData.absoluteFrame = frame;
        [self.tracker trackViewAppearWithTrackData:self.trackData];
    }
}

#pragma mark Subview related tracking
//everytime subView is inserted, track the view appear event of the subview
- (void)insertReactSubview:(UIView *)view atIndex:(NSInteger)atIndex {
    [super insertReactSubview:view atIndex:atIndex];
    
    //for PLA Ads
    if([view isKindOfClass:[AdContainerView class]]){
        
        AdContainerView *adContainerView = (AdContainerView *)view;
        
        //update absolute frame
        CGRect frame = [self convertRect:view.bounds toView:nil];
        adContainerView.trackData.absoluteFrame = frame;
        
        NSString *tag = [@(self.scrollView.tag) stringValue];
        [self.tracker beginTrackingWithEntity:adContainerView parentId:tag];
    }
}

//track view end when react subview is removed
- (void)removeReactSubview:(UIView *)subview{
    [super removeReactSubview:subview];
    
    if([subview isKindOfClass:[AdContainerView class]]){
        AdContainerView *adContainerView = (AdContainerView *)subview;
        [self.tracker trackViewDisappearWithTrackData:adContainerView.trackData];
    }
}
@end
