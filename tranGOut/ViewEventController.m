//
//  ViewEventController.m
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ViewEventController.h"
#import "DisplayMapAnnotation.h"
#import "EditEventController.h"
#import "EventPostsViewController.h"
#import "AddGuestsControllerTVC.h"
#import "ViewAcceptedGuestsControllerTVC.h"
#import "ViewMaybeGuestsControllerTVC.h"
#import "ViewUndecidedGuestsControllerTVC.h"

@interface ViewEventController () <MKMapViewDelegate>
@property (strong, nonatomic) UILabel *startTimeLabel;
@property (strong, nonatomic) UILabel *endTimeLabel;
@property (strong, nonatomic) UITextView *eventInfoView;
@property (strong, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UIButton *guestAttendingButton;
@property (strong, nonatomic) UIButton *guestMaybeButton;
@property (strong, nonatomic) UIButton *guestUndecidedButton;
@property (strong, nonatomic) NSString* attendingStatusOld;
@property (strong, nonatomic) UIView* topBarView;
@property MKCoordinateRegion savedRegion;
@property (strong, nonatomic) NSString* address;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation ViewEventController

#pragma mark UIViewControllers

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTopBar];
    [self createScrollView];
    [self createScrollViewContents];
    self.editButton.hidden = self.hideEditor;
    self.navigationItem.title = self.eventTitle;
    self.view.backgroundColor = [colorAndFontUtility backgroundColor];
    if(![[PFUser currentUser].objectId isEqual:self.eventCreator.objectId]){
        self.editButton.userInteractionEnabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden=YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"objectId" equalTo:self.eventID];
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *event, NSError *error) {
        self.event = event;
        self.acceptedGuests = self.event[@"acceptedGuests"];
        self.maybeGuests = self.event[@"maybeGuests"];
        self.undecidedGuests = self.event[@"undecidedGuests"];
        [self setGuestInfoButtonTitles];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden=NO;
}

#pragma mark CreateView

- (void)createTopBar {
    const float maxLabelWidth = (1-2*INPUTBOXWIDTHOFFSETPERCENT)*self.view.frame.size.width;
    const float standardLabelHeight = maxLabelWidth/10.0;
    const float viewHeaderHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;

    CGPoint attendingButtonPoint = CGPointMake(1,LABELSPACING/2);
    CGSize buttonSize = CGSizeMake(self.view.frame.size.width/3-2,standardLabelHeight);
    CGRect attendingButtonRect = {attendingButtonPoint, buttonSize};
    CGPoint postButtonPoint = CGPointMake(attendingButtonPoint.x+buttonSize.width+2,attendingButtonPoint.y);
    CGRect postButtonRect = {postButtonPoint, buttonSize};
    CGPoint inviteButtonPoint = CGPointMake(postButtonPoint.x+buttonSize.width+2, postButtonPoint.y);
    CGRect inviteButtonRect = {inviteButtonPoint, buttonSize};

    self.attendingButton = [[UIButton alloc] initWithFrame:attendingButtonRect];
    self.postButton = [[UIButton alloc] initWithFrame:postButtonRect];
    self.inviteButton = [[UIButton alloc] initWithFrame:inviteButtonRect];
    
    [self getAttendingStatus];
    [self.postButton setTitle:@"Post" forState:UIControlStateNormal];
    [self.inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
    
    [colorAndFontUtility buttonStyleTwo:self.attendingButton withRoundEdges:NO];
    [colorAndFontUtility buttonStyleOne:self.postButton withRoundEdges:NO];
    [colorAndFontUtility buttonStyleTwo:self.inviteButton withRoundEdges:NO];
    
    [self.attendingButton addTarget:self action:@selector(attendingButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    [self.postButton addTarget:self action:@selector(postButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    [self.inviteButton addTarget:self action:@selector(inviteButtonTap:) forControlEvents: UIControlEventTouchUpInside];

    if(![[PFUser currentUser].objectId isEqual:self.eventCreator.objectId] || self.blockInvite){
        self.inviteButton.userInteractionEnabled = NO;
    }
    
    self.topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeaderHeight, self.view.frame.size.width, buttonSize.height+LABELSPACING)];
    [self.topBarView setBackgroundColor:[colorAndFontUtility opaqueWhiteColor]];
    
    [self.topBarView addSubview:self.attendingButton];
    [self.topBarView addSubview:self.postButton];
    [self.topBarView addSubview:self.inviteButton];
    
    [self.view addSubview:self.topBarView];
}

- (void)createScrollView {
    CGPoint scrollViewPoint = CGPointMake(0, self.topBarView.frame.size.height+self.topBarView.frame.origin.y);
    CGSize scrollViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-scrollViewPoint.y);
    CGRect scrollViewRect = {scrollViewPoint, scrollViewSize};
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.scrollView.scrollEnabled = YES;
    
    [self.view addSubview:self.scrollView];
}

- (void)createScrollViewContents {
    const float maxLabelWidth = (1-2*INPUTBOXWIDTHOFFSETPERCENT)*self.view.frame.size.width;
    const float standardLabelHeight = maxLabelWidth/10.0;
    
    // add scroll view elements
    CGPoint mapViewPoint = CGPointMake(0, 0);
    CGSize mapViewSize = CGSizeMake(self.scrollView.frame.size.width, 200.0);
    CGRect mapViewRect = {mapViewPoint, mapViewSize};
    
    self.mapView = [[MKMapView alloc] initWithFrame:mapViewRect];
    [self setUpMapView];
    
    [self.scrollView addSubview:self.mapView];
    
    // Location Title
    CGPoint locationLabelPoint = CGPointMake(self.scrollView.frame.origin.x+SIDESPACING, mapViewPoint.y + mapViewSize.height + LABELSPACING);
    CGSize locationLabelSize = CGSizeMake(maxLabelWidth, standardLabelHeight);
    CGRect locationLabelRect = {locationLabelPoint, locationLabelSize};
    
    self.locationLabel = [[UILabel alloc] initWithFrame:locationLabelRect];
    [colorAndFontUtility buttonStyleThree:self.locationLabel withRoundEdges:YES];
    self.locationLabel.text = self.eventLocation;
    
    // From and To Text Label
    CGSize fromLabelSize = CGSizeMake(locationLabelSize.width/2.0-SIDESPACING/2, locationLabelSize.height/2.0);
    CGPoint fromLabelPoint = CGPointMake(locationLabelPoint.x, locationLabelPoint.y + locationLabelSize.height + LABELSPACING);
    CGRect fromLabelRect = {fromLabelPoint, fromLabelSize};
    CGSize toLabelSize = fromLabelSize;
    CGPoint toLabelPoint = CGPointMake(fromLabelPoint.x+fromLabelSize.width+SIDESPACING, fromLabelPoint.y);
    CGRect toLabelRect = {toLabelPoint, toLabelSize};
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:fromLabelRect];
    UILabel *toLabel = [[UILabel alloc] initWithFrame:toLabelRect];
    
    [fromLabel setText:@"From"];
    [fromLabel setTextColor:[colorAndFontUtility textColor]];
    [fromLabel setTextAlignment:NSTextAlignmentCenter];
    fromLabel.font = FUTURA_SMALL_FONT;
   
    [toLabel setText:@"To"];
    [toLabel setTextColor:[colorAndFontUtility textColor]];
    [toLabel setTextAlignment:NSTextAlignmentCenter];
    toLabel.font = FUTURA_SMALL_FONT;
    
    // Start and end time input label
    CGPoint startTimeLabelPoint = CGPointMake(fromLabelPoint.x, fromLabelPoint.y+fromLabelSize.height+1);
    CGSize timeLabelSize = CGSizeMake(fromLabelSize.width, standardLabelHeight);
    CGRect startTimeLabelRect = {startTimeLabelPoint, timeLabelSize};
    CGPoint endTimeLabelPoint = CGPointMake(toLabelPoint.x, toLabelPoint.y+toLabelSize.height+1);
    CGRect endTimeLabelRect = {endTimeLabelPoint, timeLabelSize};

    self.startTimeLabel = [[UILabel alloc] initWithFrame:startTimeLabelRect];
    self.endTimeLabel = [[UILabel alloc] initWithFrame:endTimeLabelRect];
    
    [colorAndFontUtility buttonStyleThree:self.startTimeLabel withRoundEdges:NO];
    self.startTimeLabel.text = self.eventStartTime;
    [colorAndFontUtility buttonStyleThree:self.endTimeLabel withRoundEdges:NO];
    self.endTimeLabel.text = self.eventEndTime;

    // add event info
    CGPoint eventInfoViewPoint = CGPointMake(startTimeLabelPoint.x, startTimeLabelPoint.y+timeLabelSize.height+LABELSPACING);
    CGSize eventInfoViewSize = CGSizeMake(locationLabelSize.width, maxLabelWidth/2.0);
    CGRect eventInfoViewRect = {eventInfoViewPoint, eventInfoViewSize};
    
    self.eventInfoView = [[UITextView alloc] initWithFrame:eventInfoViewRect];
    [colorAndFontUtility buttonStyleFour:self.eventInfoView withRoundEdges:YES];
    [self.eventInfoView setUserInteractionEnabled:NO];
    self.eventInfoView.editable = NO;
    [self.eventInfoView scrollRectToVisible:eventInfoViewRect animated:NO];
    [self.eventInfoView setAttributedText:self.eventInfo];
    
    // Guest status buttons
    
    CGSize guestButtonSize = CGSizeMake(locationLabelSize.width, standardLabelHeight);
    CGPoint guestAttendingButtonPoint = CGPointMake(eventInfoViewPoint.x, eventInfoViewPoint.y+eventInfoViewSize.height+LABELSPACING*2);
    CGRect guestAttendingButtonRect = {guestAttendingButtonPoint, guestButtonSize};
    CGPoint guestMaybeButtonPoint = CGPointMake(guestAttendingButtonPoint.x, guestAttendingButtonPoint.y+guestButtonSize.height+2);
    CGRect guestMaybeButtonRect = {guestMaybeButtonPoint, guestButtonSize};
    CGPoint guestUndecidedButtonPoint = CGPointMake(guestAttendingButtonPoint.x, guestMaybeButtonPoint.y+guestButtonSize.height+2);
    CGRect guestUndecidedButtonRect = {guestUndecidedButtonPoint, guestButtonSize};

    self.guestAttendingButton = [[UIButton alloc] initWithFrame:guestAttendingButtonRect];
    self.guestMaybeButton = [[UIButton alloc] initWithFrame:guestMaybeButtonRect];
    self.guestUndecidedButton = [[UIButton alloc] initWithFrame:guestUndecidedButtonRect];

    [colorAndFontUtility buttonStyleTwo:self.guestAttendingButton withRoundEdges:YES];
    [colorAndFontUtility buttonStyleOne:self.guestMaybeButton withRoundEdges:YES];
    [colorAndFontUtility buttonStyleTwo:self.guestUndecidedButton withRoundEdges:YES];

    [self.guestAttendingButton addTarget:self action:@selector(guestButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    [self.guestMaybeButton addTarget:self action:@selector(guestButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    [self.guestUndecidedButton addTarget:self action:@selector(guestButtonTap:) forControlEvents: UIControlEventTouchUpInside];

    [self setGuestInfoButtonTitles];
    
    // add views to scroll view
    [self.scrollView addSubview:self.locationLabel];
    [self.scrollView addSubview:fromLabel];
    [self.scrollView addSubview:toLabel];
    [self.scrollView addSubview:self.startTimeLabel];
    [self.scrollView addSubview:self.endTimeLabel];
    [self.scrollView addSubview:self.eventInfoView];
    [self.scrollView addSubview:self.guestAttendingButton];
    [self.scrollView addSubview:self.guestMaybeButton];
    [self.scrollView addSubview:self.guestUndecidedButton];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, guestUndecidedButtonPoint.y+guestButtonSize.height+LABELSPACING);
}

-(void) setGuestInfoButtonTitles {
    if(self.guestAttendingButton && self.guestMaybeButton && self.guestUndecidedButton){
        [self.guestAttendingButton setTitle:[NSString stringWithFormat:@"Guests: %d", [self.acceptedGuests intValue]] forState:UIControlStateNormal];
        [self.guestMaybeButton setTitle:[NSString stringWithFormat:@"Maybe: %d", [self.maybeGuests intValue]] forState:UIControlStateNormal];
        [self.guestUndecidedButton setTitle:[NSString stringWithFormat:@"No Response: %d", [self.undecidedGuests intValue]] forState:UIControlStateNormal];}
}

#pragma mark handleActions

- (IBAction)attendingButtonTap:(id)sender {
    UIView *opaqueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    opaqueView.backgroundColor = [colorAndFontUtility opaqueWhiteColor];
    opaqueView.tag = 2;
    
    [self.view addSubview:opaqueView];
    
    const float maxLabelWidth = (1-2*INPUTBOXWIDTHOFFSETPERCENT)*self.view.frame.size.width;
    const float standardLabelHeight = maxLabelWidth/10.0;

    CGSize buttonSize = CGSizeMake(maxLabelWidth, standardLabelHeight);
    CGPoint cancelButtonPoint = CGPointMake((opaqueView.frame.size.width-buttonSize.width)/2, opaqueView.frame.size.height-buttonSize.height-1);
    CGRect cancelButtonRect = {cancelButtonPoint, buttonSize};
    CGPoint notGoingButtonPoint = CGPointMake(cancelButtonPoint.x, cancelButtonPoint.y-LABELSPACING*2-buttonSize.height);
    CGRect notGoingButtonRect = {notGoingButtonPoint, buttonSize};
    CGPoint maybeButtonPoint = CGPointMake(notGoingButtonPoint.x, notGoingButtonPoint.y-1-buttonSize.height);
    CGRect maybeButtonRect = {maybeButtonPoint, buttonSize};
    CGPoint goingButtonPoint = CGPointMake(maybeButtonPoint.x, maybeButtonPoint.y-1-buttonSize.height);
    CGRect goingButtonRect = {goingButtonPoint, buttonSize};

    
    UIButton* cancelButton = [[UIButton alloc] initWithFrame:cancelButtonRect];
    UIButton* notGoingButton = [[UIButton alloc] initWithFrame:notGoingButtonRect];
    UIButton* maybeButton = [[UIButton alloc] initWithFrame:maybeButtonRect];
    UIButton* goingButton = [[UIButton alloc] initWithFrame:goingButtonRect];
    
    [colorAndFontUtility buttonStyleOneSolid:cancelButton withRoundEdges:YES];
    [colorAndFontUtility buttonStyleTwoSolid:notGoingButton withRoundEdges:YES];
    [colorAndFontUtility buttonStyleTwoSolid:maybeButton withRoundEdges:YES];
    [colorAndFontUtility buttonStyleTwoSolid:goingButton withRoundEdges:YES];
    
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [notGoingButton setTitle:@"Not Going" forState:UIControlStateNormal];
    [maybeButton setTitle:@"Maybe" forState:UIControlStateNormal];
    [goingButton setTitle:@"Going" forState:UIControlStateNormal];
    
    [cancelButton addTarget:self action:@selector(attendingSelection:) forControlEvents: UIControlEventTouchUpInside];
    [notGoingButton addTarget:self action:@selector(attendingSelection:) forControlEvents: UIControlEventTouchUpInside];
    [maybeButton addTarget:self action:@selector(attendingSelection:) forControlEvents: UIControlEventTouchUpInside];
    [goingButton addTarget:self action:@selector(attendingSelection:) forControlEvents: UIControlEventTouchUpInside];
    
    [opaqueView addSubview:cancelButton];
    [opaqueView addSubview:notGoingButton];
    [opaqueView addSubview:maybeButton];
    [opaqueView addSubview:goingButton];
}

- (IBAction) attendingSelection:(id)sender{
    UIButton *button = sender;
    NSString *label = button.titleLabel.text;
    
    if ([label isEqualToString:@"Cancel"]){
        [[self.view viewWithTag:2] removeFromSuperview];
    } else {
        self.attendingStatusOld = self.attendingButton.titleLabel.text;
        if([self.attendingStatusOld isEqualToString:@"Not Going"])
            self.attendingStatusOld = @"NotGoing";

        [self.attendingButton setTitle:label forState:UIControlStateNormal];
        [self updateEventInfo:NO];
        [[self.view viewWithTag:2] removeFromSuperview];
    }
}
- (IBAction)postButtonTap:(id)sender {
    NSLog(@"Post tap");
    EventPostsViewController *eventPosts = [[EventPostsViewController alloc] init];
    eventPosts.eventTitle = self.eventTitle;
    eventPosts.eventID = self.eventID;
    [self.navigationController pushViewController:eventPosts animated:NO];
}

- (IBAction)inviteButtonTap:(id)sender {
    NSLog(@"invite tap");
    AddGuestsControllerTVC *inviteGuests = [[AddGuestsControllerTVC alloc] init];
    inviteGuests.eventTitle = self.eventTitle;
    inviteGuests.eventID = self.eventID;
    [self.navigationController pushViewController:inviteGuests animated:NO];
}

- (IBAction)guestButtonTap:(id)sender {
    if(sender == self.guestAttendingButton){
        ViewAcceptedGuestsControllerTVC *viewGuests = [[ViewAcceptedGuestsControllerTVC alloc] init];
        viewGuests.eventTitle = self.eventTitle;
        viewGuests.eventID = self.eventID;
        viewGuests.event = self.event;
        [self.navigationController pushViewController:viewGuests animated:NO];
    } else if (sender == self.guestMaybeButton){
        ViewMaybeGuestsControllerTVC *viewGuests = [[ViewMaybeGuestsControllerTVC alloc] init];
        viewGuests.eventTitle = self.eventTitle;
        viewGuests.eventID = self.eventID;
        viewGuests.event = self.event;
        [self.navigationController pushViewController:viewGuests animated:NO];
    } else if (sender == self.guestUndecidedButton){
        ViewUndecidedGuestsControllerTVC *viewGuests = [[ViewUndecidedGuestsControllerTVC alloc] init];
        viewGuests.eventTitle = self.eventTitle;
        viewGuests.eventID = self.eventID;
        viewGuests.event = self.event;
        [self.navigationController pushViewController:viewGuests animated:NO];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}

#pragma mark mapSettings

- (void)setUpMapView {
    NSArray* coordinates = [self geoCodeUsingAddress:self.eventLocation];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    
    CLLocationCoordinate2D NEcenter;
    CLLocationCoordinate2D SEcenter;
    [[coordinates objectAtIndex:1] getValue:&NEcenter];
    [[coordinates objectAtIndex:2] getValue:&SEcenter];
    
    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:SEcenter.latitude longitude:SEcenter.longitude];
    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:NEcenter.latitude longitude:NEcenter.longitude];
    
    // This is a diag distance (if you wanted tighter you could do NE-NW or NE-SE)
    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
    
    MKCoordinateRegion region;
    region.center.latitude = (SEcenter.latitude + NEcenter.latitude) / 2.0;
    region.center.longitude = (SEcenter.longitude + NEcenter.longitude) / 2.0;
    region.span.latitudeDelta = meters / 111319.5;
    region.span.longitudeDelta = 0.0;
    
    self.savedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:self.savedRegion animated:YES];
    
    DisplayMapAnnotation *annotationPoint = [[DisplayMapAnnotation alloc] init];
    CLLocationCoordinate2D center;
    [[coordinates objectAtIndex:0] getValue:&center];
    annotationPoint.coordinate = center;
    annotationPoint.title = self.eventTitle;
    annotationPoint.subtitle = self.eventLocation; //self.address
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotation:annotationPoint];
    });
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:
(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    if(annotation != mapView.userLocation)
    {
        static NSString *defaultPinID = @"Eventpin";
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
    }
    else {
        [mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
}

- (NSArray *) geoCodeUsingAddress:(NSString *)address {
    double latitude = 0, longitude = 0;
    double NElat = 0, NElong = 0;
    double SElat = 0, SElong = 0;
    NSString *fullAddress = [[NSString alloc] init];
    
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        //     if ([scanner scanUpToString:@"\"formated_address\" : \"" intoString:nil] && [scanner scanUpToString:@"\"geomerty\" : {" intoString:&fullAddress] ) {
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
                if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
                    [scanner scanDouble:&NElat];
                    if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                        [scanner scanDouble:&NElong];
                        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
                            [scanner scanDouble:&SElat];
                            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                                [scanner scanDouble:&SElong];
                            }
                        }
                    }
                }
            }
        }
        //        }
    }
    CLLocationCoordinate2D center;
    CLLocationCoordinate2D NEcenter;
    CLLocationCoordinate2D SEcenter;
    
    center.latitude = latitude;
    center.longitude = longitude;
    NEcenter.latitude = NElat;
    NEcenter.longitude = NElong;
    SEcenter.latitude = SElat;
    SEcenter.longitude = SElong;
    
    self.address = fullAddress;
    
    return @[[NSValue valueWithMKCoordinate:center], [NSValue valueWithMKCoordinate:NEcenter], [NSValue valueWithMKCoordinate:SEcenter]];
}

#pragma mark - Navigation

- (void)prepareImageViewController:(EditEventController *)ivc {
    ivc.eventTitleString = self.eventTitle;
    ivc.eventLocationString = self.eventLocation;
    ivc.eventInfoString = self.eventInfo;
    ivc.eventStartTimeDate = self.eventStartTime;
    ivc.eventEndTimeDate = self.eventEndTime;
    ivc.eventID = self.eventID;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UIButton class]]) {
        if ([segue.identifier isEqualToString:@"edit_event"]) {
            if ([segue.destinationViewController isKindOfClass:[EditEventController class]]) {
                [self prepareImageViewController:segue.destinationViewController];
            }
        }
    }
}

#pragma mark other

- (void)updateEventInfo:(BOOL)refresh {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];    
    [query whereKey:@"objectId" equalTo:self.eventID];
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *event, NSError *error) {
        PFUser *user = [PFUser currentUser];
        
        // remove old attending status
        if(!([self.attendingStatusOld length]>0)){
            event[@"undecidedGuests"] = [NSNumber numberWithInt:[[event objectForKey:@"undecidedGuests"] intValue]-1];
        } else {
            PFRelation *relationOld = [user relationforKey:self.attendingStatusOld];
            [relationOld removeObject:event];
            
            if([self.attendingStatusOld isEqualToString:@"Maybe"]){
                event[@"maybeGuests"] = [NSNumber numberWithInt:[[event objectForKey:@"maybeGuests"] intValue]-1];
            } else if([self.attendingStatusOld isEqualToString:@"Going"]){
                event[@"acceptedGuests"] = [NSNumber numberWithInt:[[event objectForKey:@"acceptedGuests"] intValue]-1];
            }
        }
        
        NSString *attendingStatus = self.attendingButton.titleLabel.text;
        if([attendingStatus isEqualToString:@"Not Going"])
            attendingStatus = @"NotGoing";
        PFRelation *relation = [user relationforKey:attendingStatus];
        [relation addObject:event];
        if ([attendingStatus isEqualToString:@"Going"]){
            event[@"acceptedGuests"] = [NSNumber numberWithInt:[[event objectForKey:@"acceptedGuests"] intValue]+1];
        } else if ([attendingStatus isEqualToString:@"Maybe"]){
            event[@"maybeGuests"] = [NSNumber numberWithInt:[[event objectForKey:@"maybeGuests"] intValue]+1];
        }
        //reset guess info button titles
        self.acceptedGuests = event[@"acceptedGuests"];
        self.maybeGuests = event[@"maybeGuests"];
        self.undecidedGuests = event[@"undecidedGuests"];
        [self setGuestInfoButtonTitles];

        [event saveInBackground];
        [user saveInBackground];
        self.event = event;
    }];
}

- (void)getAttendingStatus {
    NSArray* attendingType = @[@"Going", @"Maybe", @"NotGoing"];
    
    for (int i = 0; i < [attendingType count]; i++){
        PFRelation *relation = [[PFUser currentUser] relationForKey:[attendingType objectAtIndex:i]];
        PFQuery *query = [relation query];
        [query whereKey:@"title" equalTo:self.eventTitle];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                // There was an error
            } else {
                if([objects count]){
                    if([[attendingType objectAtIndex:i] isEqualToString:@"NotGoing"]) {
                        [self.attendingButton setTitle:@"Not Going" forState:UIControlStateNormal];
                    } else  {
                        [self.attendingButton setTitle:[attendingType objectAtIndex:i] forState:UIControlStateNormal];
                    }
                }
            }
        }];
    }
}

@end
