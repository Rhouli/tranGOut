//
//  addGuestsControllerTVC.m
//  tranGOut
//
//  Created by Ryan on 6/5/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "AddGuestsControllerTVC.h"

@interface AddGuestsControllerTVC ()
@property (strong, nonatomic) NSMutableArray *selectedObjects;
@property (strong, nonatomic) UIToolbar *actionToolbar;
@property (strong, nonatomic) UIBarButtonItem *actionButton;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation AddGuestsControllerTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Invite Guests"];
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    self.spinner.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.spinner.color = [colorAndFontUtility textColor];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];

    [self createActionBar];
    [self loadInvites];
}

- (void)createActionBar {
    self.actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-22, self.view.frame.size.width, 44)];
    UIBarButtonItem *flexibleSpace1 =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil action:nil];
    UIBarButtonItem *flexibleSpace2 =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil action:nil];
    
    self.actionButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStyleBordered
                                                        target:self action:@selector(saveInvites:)];
    
    [self.actionButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura" size:18],
                                                NSForegroundColorAttributeName:[colorAndFontUtility textColor]}
                                     forState:UIControlStateNormal];
    NSArray* toolbarItems = [NSArray arrayWithObjects:flexibleSpace1,self.actionButton,flexibleSpace2, nil];
    [self.actionToolbar setItems:toolbarItems];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.selectedObjects = [[NSMutableArray array] init];
    [self.view.superview addSubview:self.actionToolbar];
}

- (IBAction)saveInvites:(id)sender {
    [self.spinner startAnimating];
    self.tableView.userInteractionEnabled = NO;

    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"eventId" equalTo:self.eventID];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *event, NSError *error) {
        PFRelation *relation = [event relationforKey:@"Invitations"];
        
        for(int i = 0; i < [self.objects count]; i++){
            PFUser *user = [self.objects objectAtIndex:i];
            if([self.selectedObjects containsObject:[self.objects objectAtIndex:i]]){
                [relation addObject:user];
                [[event relationForKey:@"Undecided"] addObject:user];
            } else {
                [relation removeObject:user];
                [[event relationForKey:@"Undecided"] removeObject:user];
            }
        }
        NSLog(@"%lu", (unsigned long)[self.selectedObjects count]);
        event[@"undecidedGuests"] = [NSNumber numberWithInteger:([self.selectedObjects count])];
        [event saveInBackground];
        [self resetGuestStatusCounts:event];
    }];
}

- (void)resetGuestStatusCounts:(PFObject*)event {
    PFQuery *goingQuery = [PFQuery queryWithClassName:@"_User"];
    [goingQuery whereKey:@"Going" equalTo:event];
    
    [goingQuery findObjectsInBackgroundWithBlock:^(NSArray *goingUsers, NSError *error){
        if (error){
            
        } else {
            event[@"acceptedGuests"] = [NSNumber numberWithInteger:[goingUsers count]];
            PFQuery *maybeQuery = [PFQuery queryWithClassName:@"_User"];
            [maybeQuery whereKey:@"Maybe" equalTo:event];
            [goingQuery findObjectsInBackgroundWithBlock:^(NSArray *maybeUsers, NSError *error){
                if (error){
                    
                } else {
                    event[@"maybeGuests"] = [NSNumber numberWithInteger:[maybeUsers count]];
                    event[@"undecidedGuests"] = [NSNumber numberWithInteger:([self.selectedObjects count]-[goingUsers count]-[maybeUsers count])];
                    
                    [self.spinner stopAnimating];
                    self.tableView.userInteractionEnabled = YES;
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            
        }
    }];
    
}

- (void) loadInvites {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"eventId" equalTo:self.eventID];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *event, NSError *error) {
        PFRelation *relation = [event relationForKey:@"Invitations"];
        PFQuery *query = [relation query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *invitedUsers, NSError *error) {
            if (error) {
                // There was an error
            } else {
                for(int i = 0; i < [invitedUsers count]; i++){
                    for(int j = 0; j< [self.objects count]; j++){
                        if ([[[invitedUsers objectAtIndex:i] objectId] isEqualToString:[[self.objects objectAtIndex:j] objectId]]){
                            [self.selectedObjects addObject:[self.objects objectAtIndex:j]];
                        }
                    }
                }
                [self.tableView reloadData];
                [self.spinner stopAnimating];
                self.tableView.userInteractionEnabled = YES;
            }
        }];
    }];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query orderByDescending:@"username"];
    
    return query;
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Current Event";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    tableView.tintColor = [UIColor blackColor];
    
    PFObject *user = [self.objects objectAtIndex:indexPath.row];
    
    if ([self.selectedObjects containsObject:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"username"];
    
    return cell;
}

-  (void) tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *user = [self.objects objectAtIndex:indexPath.row]; //This assumes that your table has only one section and all cells are populated directly into that section from sourceArray.
    if ([self.selectedObjects containsObject:user]) {
        [self.selectedObjects removeObject:user];
    }
    else {
        [self.selectedObjects addObject:user];
    }
    [atableView reloadData];
}

@end
