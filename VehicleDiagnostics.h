//
//  VehicleDiagnostics.h
//  CarVoyant
//
//  Created by Michael Holp on 11/9/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "VehicleInfo.h"

@interface VehicleDiagnostics : UIViewController

@property (nonatomic, retain) NSString *vehicleId;
@property (nonatomic, retain) NSString *vehicleName;
@property (nonatomic, strong) NSMutableDictionary *diagnostics;
@property (nonatomic, strong) NSMutableDictionary *years;
@property (nonatomic, strong) NSMutableData *buffer;
@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, retain) IBOutlet UIImageView *carPhoto;
@property (nonatomic, retain) IBOutlet UILabel *voltageLbl;
@property (nonatomic, retain) IBOutlet UILabel *mileageLbl;
@property (nonatomic, retain) IBOutlet UILabel *locationLbl;
@property (nonatomic, retain) IBOutlet UILabel *enginespeedLbl;
@property (nonatomic, retain) IBOutlet UILabel *chargeLbl;
@property (nonatomic, retain) IBOutlet UILabel *chargerateLbl;
@property (nonatomic, retain) IBOutlet UILabel *tempLbl;
@property (nonatomic, retain) IBOutlet UILabel *maxspeedLbl;

@end
