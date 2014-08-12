//
//  VehicleDetails.h
//  CarVoyant
//
//  Created by Michael Holp on 11/10/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MaintCell.h"

@interface VehicleDetails : UIViewController

@property (nonatomic, retain) NSString *styleId;
@property (nonatomic, retain) NSString *vehicleName;
@property (nonatomic, strong) NSMutableData *buffer;
@property (nonatomic, strong) NSURLConnection *connection1;
@property (nonatomic, strong) NSURLConnection *connection2;
@property (nonatomic, strong) NSMutableDictionary *photoURLs;

@property (nonatomic, strong) NSMutableDictionary *edmunds;

@property (nonatomic,retain) IBOutlet UITableView *maintTable;
@property (nonatomic, retain) IBOutlet UILabel *vehicleLbl;
@property (nonatomic, retain) IBOutlet UIImageView *carPhoto;

@end
