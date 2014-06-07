//
//  ViewAcceptedGuestsControllerTVC.m
//  tranGOut
//
//  Created by Ryan on 6/6/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "ViewAcceptedGuestsControllerTVC.h"

@interface ViewAcceptedGuestsControllerTVC ()
@end

@implementation ViewAcceptedGuestsControllerTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Going"];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"Going" equalTo:self.event];
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query orderByDescending:@"username"];
    
    return query;
}
@end
