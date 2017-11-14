//
//  MapDetailViewController.m
//  TestProject
//
//  Created by Theen on 23/01/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "MapDetailViewController.h"
#import "Constants.h"

@interface MapDetailViewController ()
{
}
//@property (strong, nonatomic) IBOutlet GMSMapView *googleMapView;

@end

@implementation MapDetailViewController
@synthesize lattitude;
@synthesize longtitude;
@synthesize labelTitle;
@synthesize labelCity;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    
    CLLocationCoordinate2D location;
    location.latitude = [self.lattitude doubleValue];
    location.longitude = [self.longtitude doubleValue];
    
    MKCoordinateSpan span = {.latitudeDelta =  0.2, .longitudeDelta =  0.2};
    MKCoordinateRegion region = {location, span};
    [mapView setRegion:region];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = location;
    [mapView addAnnotation: annotation];
    
    UIView *iv = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,44)];
    [iv setBackgroundColor:[UIColor clearColor]];
    
    self.labelTitle = [[UILabel alloc]init];
    [self.labelTitle setFrame:CGRectMake(iv.frame.origin.x, iv.frame.origin.y, iv.frame.size.width, iv.frame.size.height/2)];
    [self.labelTitle setTextAlignment:NSTextAlignmentCenter];
    [self.labelTitle setTextColor:[UIColor blackColor]];
    [self.labelTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];

    self.labelCity = [[UILabel alloc]init];
    [self.labelCity setFrame:CGRectMake(iv.frame.origin.x, self.labelTitle.frame.size.height-10, iv.frame.size.width, iv.frame.size.height)];
    [self.labelCity setTextAlignment:NSTextAlignmentCenter];
    [self.labelCity setTextColor:[UIColor lightGrayColor]];
    [self.labelCity setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    
    [self.labelTitle setText:@""];
    [self.labelCity setText:@""];

    
    [iv addSubview:self.labelTitle];
    [iv addSubview:self.labelCity];

    self.navigationItem.titleView = iv;
    
    [self getAddress];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)getAddress{
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:[self.lattitude doubleValue] longitude:[self.longtitude doubleValue]];
    
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog(@"placemark %@",placemark);
         //String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         NSLog(@"addressDictionary %@", placemark.addressDictionary);
         
         NSLog(@"placemark %@",placemark.region);
         NSLog(@"placemark %@",placemark.country);  // Give Country Name
         NSLog(@"placemark %@",placemark.locality); // Extract the city name
         NSLog(@"location %@",placemark.name);
         NSLog(@"location %@",placemark.ocean);
         NSLog(@"location %@",placemark.postalCode);
         NSLog(@"location %@",placemark.subLocality);
         
         NSLog(@"location %@",placemark.location);
         //Print the location to console
         NSLog(@"I am currently at %@",locatedAt);
         
         [self.labelCity setText:[placemark.addressDictionary valueForKey:@"SubAdministrativeArea"]];
         [self.labelTitle setText:[placemark.addressDictionary valueForKey:@"Street"]];
     }];
}

- (IBAction)actionvaluechanged:(id)sender{
    
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    switch (segment.selectedSegmentIndex) {
        case 0:
            mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            mapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}


-(MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    NSString *annotationIdentifier = @"PinViewAnnotation";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [mapView
                                                            dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    
    if (!pinView)
    {
        pinView = [[MKPinAnnotationView alloc]
                    initWithAnnotation:annotation
                    reuseIdentifier:annotationIdentifier];
        
        [pinView setPinColor:MKPinAnnotationColorPurple];
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;

    }
    else
    {
        pinView.annotation = annotation;
    }
    
    return pinView; 
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
