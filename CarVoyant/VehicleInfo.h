//
//  VehicleInfo.h
//  CarVoyant
//
//  Created by Michael Holp on 11/9/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleDetails.h"
#import "MBProgressHUD.h"

@interface VehicleInfo : UIViewController<UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSString *vehicleId;
@property (nonatomic, retain) NSString *vehicleName;
@property (nonatomic, strong) NSMutableDictionary *edmunds;
@property (nonatomic, strong) NSMutableDictionary *photoURLs;
@property (nonatomic, strong) NSMutableData *buffer;
@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, retain) IBOutlet UITableView *infoTable;

@end
