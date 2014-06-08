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
    PFQuery *query = [[self.event relationForKey:@"Undecided"] query];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query orderByDescending:@"username"];
    
    return query;
}

@end
