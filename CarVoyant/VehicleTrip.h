//
//  VehicleTrip.h
//  CarVoyant
//
//  Created by Michael Holp on 11/9/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPoint.h"
#import "RoutesTableView.h"
#import "MBProgressHUD.h"
#import "GetDirections.h"

@interface VehicleTrip : UIViewController<MKMapViewDelegate>
{
    GetDirections *myData;
    CGFloat lat_delta, lng_delta;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSString *routeName;
@property (nonatomic, retain) NSString *mileage;
@property (nonatomic, retain) NSString *startLatitude;
@property (nonatomic, retain) NSString *startLongitude;
@property (nonatomic, retain) NSString *endLatitude;
@property (nonatomic, retain) NSString *endLongitude;
@property (assign) CLLocationCoordinate2D vehicle1Coord;
@property (assign) CLLocationCoordinate2D vehicle2Coord;

@end
