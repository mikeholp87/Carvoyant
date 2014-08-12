//
//  VehicleDiagnostics.m
//  CarVoyant
//
//  Created by Michael Holp on 11/9/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import "VehicleDiagnostics.h"

@implementation VehicleDiagnostics
@synthesize vehicleId, vehicleName, buffer, connection, diagnostics, years, carPhoto;
@synthesize voltageLbl, mileageLbl, locationLbl, enginespeedLbl, chargeLbl, chargerateLbl, tempLbl, maxspeedLbl;

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
    
	self.title = [vehicleName substringFromIndex:5];
    
    UIBarButtonItem *more = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStyleDone target:self action:@selector(moreInfo)];
    [self.navigationItem setRightBarButtonItem:more];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.carvoyant.com/v1/api/vehicle/%@/data?sortOrder=desc", vehicleId]]];
    NSString *authHeader = [NSString stringWithFormat:@"Bearer 2jnmuezrt62y8sg2bpfndeq2"];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(self.connection){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.buffer = [NSMutableData data];
        [self.connection start];
    }else{
        NSLog(@"Connection Failed");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)moreInfo
{
    VehicleInfo *info = [self.storyboard instantiateViewControllerWithIdentifier:@"VehicleInfo"];
    info.vehicleName = vehicleName;
    [self.navigationController pushViewController:info animated:YES];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.buffer setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.buffer options:NSJSONReadingMutableLeaves error:&error];
        
        diagnostics = [[NSMutableDictionary alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error){
                NSArray *results = [res objectForKey:@"data"];
                for (NSDictionary *result in results) {
                    [diagnostics setObject:result forKey:[result objectForKey:@"key"]];
                }
                NSLog(@"%@", results);
            }else
                NSLog(@"%@",[error localizedDescription]);
            
            voltageLbl.text = [[diagnostics objectForKey:@"GEN_VOLTAGE"] objectForKey:@"translatedValue"];
            mileageLbl.text = [[diagnostics objectForKey:@"GEN_TRIP_MILEAGE"] objectForKey:@"translatedValue"];
            
            NSArray *array = [[[diagnostics objectForKey:@"GEN_WAYPOINT"] objectForKey:@"translatedValue"] componentsSeparatedByString:@","];
            
            locationLbl.text = [NSString stringWithFormat:@"%.2f, %.2f", [[array objectAtIndex:0] floatValue], [[array objectAtIndex:1] floatValue]];
            enginespeedLbl.text = [[diagnostics objectForKey:@"GEN_RPM"] objectForKey:@"translatedValue"];
            chargeLbl.text = [[diagnostics objectForKey:@"GEN_FUELLEVEL"] objectForKey:@"translatedValue"];
            chargerateLbl.text = [[diagnostics objectForKey:@"GEN_FUELRATE"] objectForKey:@"translatedValue"];
            tempLbl.text = [[diagnostics objectForKey:@"GEN_ENGINE_COOLANT_TEMP"] objectForKey:@"translatedValue"];
            maxspeedLbl.text = [[diagnostics objectForKey:@"GEN_SPEED"] objectForKey:@"translatedValue"];
        });
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",[error localizedDescription]);
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}


@end
