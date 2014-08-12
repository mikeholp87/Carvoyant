//
//  TripRouteMap.h
//  CarVoyant
//
//  Created by Michael Holp on 11/9/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"
#import "GetDirections.h"
#import "RoutesTableView.h"
#import "MapPoint.h"
#import "VehicleTrip.h"
#import "VehicleDiagnostics.h"

@interface TripRouteMap : UIViewController<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>
{
    GetDirections *myData;
    CGFloat lat_delta, lng_delta;
}

@property (nonatomic, retain) NSString *deviceId;
@property (nonatomic, strong) NSMutableDictionary *trips;
@property (nonatomic, strong) NSMutableData *buffer;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITableView *tripTable;
@property (nonatomic,retain) IBOutlet UISegmentedControl *segControl;
@property (nonatomic) CLLocationCoordinate2D startCoord;
@property (nonatomic) CLLocationCoordinate2D endCoord;

@end
