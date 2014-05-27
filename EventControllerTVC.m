//
//  EventControllerTVC.m
//  tranGOut
//
//  Created by Ryan on 5/23/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Parse/Parse.h>
#import "EventControllerTVC.h"

@interface EventControllerTVC ()
@end

@implementation EventControllerTVC

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.parseClassName = @"Event";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    NSDate *currentDate = [NSDate date];
    [query whereKey:@"startTime" greaterThan:currentDate];
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query orderByDescending:@"starTime"];
    
    return query;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.objects count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
      static NSString *cellIdentifier = @"Current Event";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }

    
    cell.textLabel.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];

    NSString *startTime = [dateFormat stringFromDate:[[self.objects objectAtIndex:indexPath.row] objectForKey:@"startTime"]];
    NSString *endTime = [dateFormat stringFromDate:[[self.objects objectAtIndex:indexPath.row] objectForKey:@"endTime"]];
    
    NSString *newString = [[startTime stringByAppendingString:@" - "] stringByAppendingString:endTime];
    cell.detailTextLabel.text = newString;
    
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
