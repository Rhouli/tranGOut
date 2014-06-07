//
//  GuestsControllerTVC.m
//  tranGOut
//
//  Created by Ryan on 6/6/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

//
//  addGuestsControllerTVC.m
//  tranGOut
//
//  Created by Ryan on 6/5/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "GuestsControllerTVC.h"

@interface GuestsControllerTVC ()
@end

@implementation GuestsControllerTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.userInteractionEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    UIView* bview = [[UIView alloc] init];
    bview.backgroundColor =  [colorAndFontUtility backgroundColor];
    [self.tableView setBackgroundView:bview];
    self.tableView.separatorColor=[UIColor clearColor];
    self.tabBarController.tabBar.hidden=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden=NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0;
}
- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.parseClassName = @"_User";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
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
        //cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    tableView.tintColor = [UIColor blackColor];
    
    cell.textLabel.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"username"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.textLabel setTextColor:[colorAndFontUtility darkLabelColor]];
    cell.textLabel.font = [ UIFont fontWithName: @"Futura" size:18.0];
    [cell.contentView.layer setBorderColor:[colorAndFontUtility lightLabelColor].CGColor];
    [cell.contentView.layer setBorderWidth:3.0f];
}


@end
