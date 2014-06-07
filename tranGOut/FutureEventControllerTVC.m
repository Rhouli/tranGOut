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
    
    NSDate *currentDate = [NSDate date];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"Event"];
    [query2 whereKey:@"Invitations" equalTo:[PFUser currentUser]];
    [query2 whereKey:@"startTime" greaterThan:currentDate];
    
    PFQuery *query3 = [PFQuery queryWithClassName:@"Event"];
    [query3 whereKey:@"creator" equalTo:[PFUser currentUser]];
    [query3 whereKey:@"startTime" greaterThan:currentDate];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query2, query3]];

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
