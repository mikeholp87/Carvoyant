//
//  ViewController.h
//  CarVoyant
//
//  Created by Michael Holp on 11/8/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "VehicleDiagnostics.h"
#import "TripRouteMap.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate, UIWebViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *vehicles;
@property (nonatomic, strong) NSMutableData *buffer;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSArray *searchResults;
@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,retain) UIButton *closeBtn;

@property (nonatomic, retain) IBOutlet UITableView *vehicleTable;

@end
