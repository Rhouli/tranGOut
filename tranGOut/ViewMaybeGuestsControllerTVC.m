//
//  ViewMaybeGuestsControllerTVC.m
//  tranGOut
//
//  Created by Ryan on 6/6/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "ViewMaybeGuestsControllerTVC.h"

@interface ViewMaybeGuestsControllerTVC ()

@end

@implementation ViewMaybeGuestsControllerTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Maybe"];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"Maybe" equalTo:self.event];
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query orderByDescending:@"username"];
    
    return query;
}
@end
