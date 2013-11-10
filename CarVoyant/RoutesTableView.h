//
//  RoutesTableView.h
//  FindMyCar
//
//  Created by Michael Holp on 11/21/12.
//  Copyright (c) 2012 Flash Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "GetDirections.h"
#import "RouteCell.h"

@interface RoutesTableView : UITableViewController<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    GetDirections *myData;
}

@property(nonatomic,retain) NSString *startPoint;
@property(nonatomic,retain) NSString *endPoint;
@property(nonatomic) CLLocationCoordinate2D userCoordinate;
@property(nonatomic,retain) NSMutableArray *Routes;
@property(nonatomic,retain) NSMutableArray *Distances;
@property(nonatomic,retain) NSMutableArray *Durations;
@property(nonatomic,retain) IBOutlet UILabel *distanceHeader;
@property(nonatomic,retain) NSString *totalDistance;
@property(nonatomic,retain) NSString *totalDuration;

@end
