//
//  CurrentEventControllerTVC.m
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "CurrentEventControllerTVC.h"

@interface CurrentEventControllerTVC ()

@end

@implementation CurrentEventControllerTVC

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    NSDate *currentDate = [NSDate date];
    [query whereKey:@"startTime" lessThan:currentDate];
    [query whereKey:@"endTime" greaterThan:currentDate];
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query orderByDescending:@"startTime"];
    
    return query;
}

#pragma mark - Navigation

- (void)prepareImageViewController:(ViewEventController *)ivc toDisplayEvent:(PFObject *)event {
    [super prepareImageViewController:ivc toDisplayEvent:(PFObject *)event];
    ivc.hideEditor = YES;
}
@end
