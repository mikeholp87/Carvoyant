//
//  NearbyPlaces.h
//  Dude Where's My Car
//
//  Created by Mike Holp on 2/4/13.
//  Copyright (c) 2013 Flash Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "GADBannerView.h"
#import "MBProgressHUD.h"
#import "MapPoint.h"
#import "defs.h"

#define kGOOGLE_API_KEY @"AIzaSyDqlg5O5Hno1yp4hBSOw9yqYlk1R7HO5jw"

@interface NearbyPlaces : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate>
{
    NSString *placeType;
    
    double lat_delta;
    double lng_delta;
    
    NSMutableArray *test;
}

@property (nonatomic, retain) GADBannerView *bannerView;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic,retain) NSMutableArray *placesArray;
@property (nonatomic,retain) NSMutableDictionary *placeNames;
@property (assign) CLLocationCoordinate2D userCoordinate;
@property (assign) CLLocationCoordinate2D stationCoordinate;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSArray *searchResults;

@property(nonatomic,retain) IBOutlet MKMapView *nearbyMap;
@property(nonatomic,retain) IBOutlet UITableView *nearbyTable;
@property(nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *placesButton;
@property(nonatomic,retain) IBOutlet UISegmentedControl *segControl;

@end
