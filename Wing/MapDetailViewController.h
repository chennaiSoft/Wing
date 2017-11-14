//
//  MapDetailViewController.h
//  TestProject
//
//  Created by Theen on 23/01/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapDetailViewController : UIViewController<MKMapViewDelegate>{
    
    MKMapView *mapView;    
    NSString *lattitude;
    NSString *longtitude;
    
    UILabel *labelTitle;
    UILabel *labelCity;
}

@property (nonatomic,retain) UILabel *labelTitle;
@property (nonatomic,retain) UILabel *labelCity;

@property (nonatomic,retain) NSString *lattitude;
@property (nonatomic,retain) NSString *longtitude;

- (IBAction)actionvaluechanged:(id)sender;


@end
