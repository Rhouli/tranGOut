//
//  ViewUndecidedGuestsControllerTVC.m
//  tranGOut
//
//  Created by Ryan on 6/6/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "ViewUndecidedGuestsControllerTVC.h"

@interface ViewUndecidedGuestsControllerTVC ()

@end

@implementation ViewUndecidedGuestsControllerTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"No Response"];
}

- (PFQuery *)queryForTable {
    PFRelation *relation = [self.event relationForKey:@"Invitations"];
    PFQuery *query = [relation query];
    [query whereKey:@"Going" notEqualTo:self.event];
    [query whereKey:@"Maybe" notEqualTo:self.event];
    [query whereKey:@"NotGoing" notEqualTo:self.event];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query orderByDescending:@"username"];
    
    return query;
}

@end
