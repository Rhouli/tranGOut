//
//  FutureEventControllerTVC.m
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "FutureEventControllerTVC.h"

@interface FutureEventControllerTVC ()

@end

@implementation FutureEventControllerTVC

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    NSDate *currentDate = [NSDate date];
    [query whereKey:@"startTime" greaterThan:currentDate];
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query orderByDescending:@"startTime"];
    
    return query;
}

#pragma mark - Navigation

- (void)prepareImageViewController:(ViewEventController *)ivc toDisplayEvent:(PFObject *)event{
    [super prepareImageViewController:ivc toDisplayEvent:(PFObject *)event];
    ivc.hideEditor = NO;
}
@end
