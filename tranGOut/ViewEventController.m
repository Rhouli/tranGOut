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

@interface ViewEventController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (strong, nonatomic) IBOutlet UITextView *eventInfoView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property MKCoordinateRegion savedRegion;
@property (strong, nonatomic) NSString* address;
@end

@implementation ViewEventController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTopBar];
    [self createScrollView];
    
    self.editButton.hidden = self.hideEditor;
    
    self.navigationItem.title = self.eventTitle;
    
   // self.navigationController.navigationBar.tintColor = [colorUtility textColor];
    
    
}
- (void)createTopBar {
    const float maxLabelWidth = (1-2*INPUTBOXWIDTHOFFSETPERCENT)*self.view.frame.size.width;
    const float standardLabelHeight = maxLabelWidth/10.0;
    const float viewHeaderHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    // create control labels
    // attending Button
    CGPoint attendingButtonPoint = CGPointMake(1,viewHeaderHeight+LABELSPACING/2);
    CGSize attendingButtonSize = CGSizeMake(self.view.frame.size.width/3-2,standardLabelHeight);
    CGRect attendingButtonRect = {attendingButtonPoint, attendingButtonSize};
    
    self.attendingButton = [[UIButton alloc] initWithFrame:attendingButtonRect];
    [self.attendingButton setBackgroundColor:[colorUtility buttonColor]];
    self.attendingButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.attendingButton setTitleColor:[colorUtility textMatchingBackgroundColor] forState:UIControlStateNormal];
    [self.attendingButton setTitle:@"Not Going" forState:UIControlStateNormal];
    self.attendingButton.titleLabel.font  = [UIFont fontWithName:@"Futura" size:16];
    [[self.attendingButton layer] setBorderWidth:2.0f];
    [[self.attendingButton layer] setBorderColor:[colorUtility buttonColor].CGColor];
    self.attendingButton.layer.cornerRadius = CORNERRADIUS;
    self.attendingButton.clipsToBounds = YES;
    [self.attendingButton setUserInteractionEnabled:YES];
    [self.attendingButton addTarget:self action:@selector(attendingButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    
    // post button
    CGPoint postButtonPoint = CGPointMake(attendingButtonPoint.x+attendingButtonSize.width+2,attendingButtonPoint.y);
    CGSize postButtonSize = attendingButtonSize;
    CGRect postButtonRect = {postButtonPoint, postButtonSize};
    
    self.postButton = [[UIButton alloc] initWithFrame:postButtonRect];
    [self.postButton setBackgroundColor:[colorUtility buttonColor]];
    self.postButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.postButton setTitleColor:[colorUtility textMatchingBackgroundColor] forState:UIControlStateNormal];
    [self.postButton setTitle:@"Post" forState:UIControlStateNormal];
    self.postButton.titleLabel.font  = [UIFont fontWithName:@"Futura" size:16];
    [[self.postButton layer] setBorderWidth:2.0f];
    [[self.postButton layer] setBorderColor:[colorUtility buttonColor].CGColor];
    self.postButton.layer.cornerRadius = CORNERRADIUS;
    self.postButton.clipsToBounds = YES;
    [self.postButton setUserInteractionEnabled:YES];
    [self.postButton addTarget:self action:@selector(postButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    
    // invite button
    CGPoint inviteButtonPoint = CGPointMake(postButtonPoint.x+postButtonSize.width+2, postButtonPoint.y);
    CGSize inviteButtonSize = postButtonSize;
    CGRect inviteButtonRect = {inviteButtonPoint, inviteButtonSize};
    
    self.inviteButton = [[UIButton alloc] initWithFrame:inviteButtonRect];
    [self.inviteButton setBackgroundColor:[colorUtility buttonColor]];
    self.inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.inviteButton setTitleColor:[colorUtility textMatchingBackgroundColor] forState:UIControlStateNormal];
    [self.inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
    self.inviteButton.titleLabel.font  = [UIFont fontWithName:@"Futura" size:16];
    [[self.inviteButton layer] setBorderWidth:2.0f];
    [[self.inviteButton layer] setBorderColor:[colorUtility buttonColor].CGColor];
    self.inviteButton.layer.cornerRadius = CORNERRADIUS;
    self.inviteButton.clipsToBounds = YES;
    [self.inviteButton setUserInteractionEnabled:YES];
    [self.inviteButton addTarget:self action:@selector(inviteButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview:self.attendingButton];
    [self.view addSubview:self.postButton];
    [self.view addSubview:self.inviteButton];
}
- (void)createScrollView {
    const float maxLabelWidth = (1-2*INPUTBOXWIDTHOFFSETPERCENT)*self.view.frame.size.width;
    const float standardLabelHeight = maxLabelWidth/10.0;
    
    CGPoint scrollViewPoint = CGPointMake(0, LABELSPACING/2+self.inviteButton.frame.size.height+self.inviteButton.frame.origin.y);
    CGSize scrollViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-scrollViewPoint.y-self.inviteButton.frame.size.height);//inviteButtonPoint.y);
    CGRect scrollViewRect = {scrollViewPoint, scrollViewSize};
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.scrollView.scrollEnabled = YES;
    
    [self.view addSubview:self.scrollView];
    
    // add scroll view elements
    CGPoint mapViewPoint = CGPointMake(0, 0);
    CGSize mapViewSize = CGSizeMake(scrollViewSize.width, 200.0);
    CGRect mapViewRect = {mapViewPoint, mapViewSize};
    
    self.mapView = [[MKMapView alloc] initWithFrame:mapViewRect];
    [self setUpMapView];
    
    [self.scrollView addSubview:self.mapView];
    
    // Location Title
    CGPoint locationLabelPoint = CGPointMake(self.scrollView.frame.origin.x+SIDESPACING, mapViewPoint.y + mapViewSize.height + LABELSPACING);
    CGSize locationLabelSize = CGSizeMake(maxLabelWidth, standardLabelHeight);
    CGRect locationLabelRect = {locationLabelPoint, locationLabelSize};
    
    self.locationLabel = [[UILabel alloc] initWithFrame:locationLabelRect];
    [self.locationLabel setBackgroundColor:[colorUtility opaqueLabelColor]];
    self.locationLabel.textAlignment = NSTextAlignmentCenter;
    [self.locationLabel setTextColor:[UIColor whiteColor]];
    self.locationLabel.layer.cornerRadius = CORNERRADIUS;
    self.startTimeLabel.clipsToBounds = YES;
    self.locationLabel.text = self.eventLocation;
    
    // From Text Label
    CGSize fromLabelSize = CGSizeMake(locationLabelSize.width/2.0-SIDESPACING/2, locationLabelSize.height/2.0);
    CGPoint fromLabelPoint = CGPointMake(locationLabelPoint.x, locationLabelPoint.y + locationLabelSize.height + LABELSPACING);
    CGRect fromLabelRect = {fromLabelPoint, fromLabelSize};
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:fromLabelRect];
    [fromLabel setText:@"From"];
    [fromLabel setTextColor:[colorUtility textColor]];
    [fromLabel setTextAlignment:NSTextAlignmentCenter];
    fromLabel.font = [fromLabel.font fontWithSize:12];
    
    // To Text Label
    CGSize toLabelSize = fromLabelSize;
    CGPoint toLabelPoint = CGPointMake(fromLabelPoint.x+fromLabelSize.width+SIDESPACING, fromLabelPoint.y);
    CGRect toLabelRect = {toLabelPoint, toLabelSize};
    
    UILabel *toLabel = [[UILabel alloc] initWithFrame:toLabelRect];
    [toLabel setText:@"To"];
    [toLabel setTextColor:[colorUtility textColor]];
    [toLabel setTextAlignment:NSTextAlignmentCenter];
    toLabel.font = [toLabel.font fontWithSize:12];
    
    // Start time input label
    CGPoint startTimeLabelPoint = CGPointMake(fromLabelPoint.x, fromLabelPoint.y+fromLabelSize.height+1);
    CGSize startTimeLabelSize = CGSizeMake(fromLabelSize.width, standardLabelHeight);
    CGRect startTimeLabelRect = {startTimeLabelPoint, startTimeLabelSize};
    
    self.startTimeLabel = [[UILabel alloc] initWithFrame:startTimeLabelRect];
    self.startTimeLabel.layer.cornerRadius = CORNERRADIUS;
    self.startTimeLabel.clipsToBounds = YES;
    [self.startTimeLabel setBackgroundColor:[colorUtility opaqueLabelColor]];
    self.startTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.startTimeLabel setTextColor:[UIColor whiteColor]];
    self.startTimeLabel.text = self.eventStartTime;
    
    // end time input label
    CGPoint endTimeLabelPoint = CGPointMake(toLabelPoint.x, toLabelPoint.y+toLabelSize.height+1);
    CGSize endTimeLabelSize = startTimeLabelSize;
    CGRect endTimeLabelRect = {endTimeLabelPoint, endTimeLabelSize};
    
    self.endTimeLabel = [[UILabel alloc] initWithFrame:endTimeLabelRect];
    self.endTimeLabel.layer.cornerRadius = CORNERRADIUS;
    self.endTimeLabel.clipsToBounds = YES;
    [self.endTimeLabel setBackgroundColor:[colorUtility opaqueLabelColor]];
    self.endTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.endTimeLabel setTextColor:[UIColor whiteColor]];
    self.endTimeLabel.text = self.eventEndTime;
    
    // add event info
    CGPoint eventInfoViewPoint = CGPointMake(startTimeLabelPoint.x, startTimeLabelPoint.y+startTimeLabelSize.height+LABELSPACING);
    CGSize eventInfoViewSize = CGSizeMake(maxLabelWidth, maxLabelWidth/2.0);
    CGRect eventInfoViewRect = {eventInfoViewPoint, eventInfoViewSize};
    
    self.eventInfoView = [[UITextView alloc] initWithFrame:eventInfoViewRect];
    [self.eventInfoView setBackgroundColor:[colorUtility textFieldColor]];
    self.eventInfoView.textColor = [colorUtility opaqueWhiteColor];
    self.eventInfoView.layer.cornerRadius = CORNERRADIUS;
    [self.eventInfoView setUserInteractionEnabled:NO];
    self.eventInfoView.editable = NO;
    [self.eventInfoView scrollRectToVisible:eventInfoViewRect animated:NO];
    [self.eventInfoView setAttributedText:self.eventInfo];
    
    
    // add views to scroll view
    [self.scrollView addSubview:self.locationLabel];
    [self.scrollView addSubview:fromLabel];
    [self.scrollView addSubview:toLabel];
    [self.scrollView addSubview:self.startTimeLabel];
    [self.scrollView addSubview:self.endTimeLabel];
    [self.scrollView addSubview:self.eventInfoView];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, eventInfoViewPoint.y+eventInfoViewSize.height+LABELSPACING*3);
}
- (IBAction)attendingButtonTap:(id)sender {
    NSLog(@"Attending tap");
}

- (IBAction)postButtonTap:(id)sender {
    NSLog(@"Post tap");
    EventPostsViewController *eventPosts = [[EventPostsViewController alloc] init];
    eventPosts.eventTitle = self.eventTitle;
    [self.navigationController pushViewController:eventPosts animated:NO];
}

- (IBAction)inviteButtonTap:(id)sender {
    NSLog(@"invite tap");
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}

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
    
    NSLog(@"%@", result);
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

@end
