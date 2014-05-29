//
//  ViewEventController.m
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ViewEventController.h"
#import "DisplayMapAnnotation.h"

@interface ViewEventController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *infoScrollView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property MKCoordinateRegion savedRegion;
@property (strong, nonatomic) NSString* address;
@end

@implementation ViewEventController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.eventTitle;
    self.locationLabel.text = self.eventLocation;
    self.startTimeLabel.text = self.eventStartTime;
    self.endTimeLabel.text = self.eventEndTime;

    self.infoScrollView.text = self.eventInfo;
    self.infoScrollView.editable = NO;
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
    annotationPoint.subtitle = self.address;
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

@end
