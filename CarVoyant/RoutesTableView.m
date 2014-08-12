//
//  RoutesTableView.m
//  FindMyCar
//
//  Created by Michael Holp on 11/21/12.
//  Copyright (c) 2012 Flash Corp. All rights reserved.
//

#import "RoutesTableView.h"

@interface RoutesTableView ()

@end

@implementation RoutesTableView
@synthesize Routes, Distances, Durations, distanceHeader;
@synthesize startPoint, endPoint, userCoordinate, totalDistance, totalDuration;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    userCoordinate = newLocation.coordinate;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    NSUserDefaults *settings = [[NSUserDefaults alloc] init];
    [settings setBool:FALSE forKey:@"mainView"];
    [settings synchronize];
    
    self.title = @"Directions";
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    userCoordinate = locationManager.location.coordinate;
    
    UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshRoutes)];
    [self.navigationItem setRightBarButtonItem:refreshBtn];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(Routes == nil || Distances == nil || Durations == nil){
        Routes = [[NSMutableArray alloc] init];
        Distances = [[NSMutableArray alloc] init];
        Durations = [[NSMutableArray alloc] init];
    }
    Routes = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath:@"routes"]];
    Distances = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath:@"distances"]];
    Durations = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath:@"durations"]];
    totalDistance = [NSString stringWithContentsOfFile:[self saveFilePath:@"totalDistance"] encoding:NSUTF32StringEncoding error:nil];
    totalDuration = [NSString stringWithContentsOfFile:[self saveFilePath:@"totalDuration"] encoding:NSUTF32StringEncoding error:nil];
    
    [self.tableView reloadData];
    
    [distanceHeader setText:[NSString stringWithFormat:@"Trip: %@ - Length: %@", totalDistance, totalDuration]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)refreshRoutes
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        myData = [[GetDirections alloc] initWithStartPoint:startPoint endPoint:endPoint mapType:@"GoogleMaps" travelMode:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            Routes = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath:@"routes"]];
            Distances = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath:@"distances"]];
            Durations = [[NSMutableArray alloc] initWithContentsOfFile:[self saveFilePath:@"durations"]];
            totalDistance = [NSString stringWithContentsOfFile:[self saveFilePath:@"totalDistance"] encoding:NSUTF32StringEncoding error:nil];
            totalDuration = [NSString stringWithContentsOfFile:[self saveFilePath:@"totalDuration"] encoding:NSUTF32StringEncoding error:nil];
            
            [self.tableView reloadData];
            
            [distanceHeader setText:[NSString stringWithFormat:@"Trip: %@ - Length: %@", totalDistance, totalDuration]];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Routes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RouteCell";
    RouteCell *cell = (RouteCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"Routes" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (RouteCell *)currentObject;
                break;
            }
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *currentRoute = [Routes objectAtIndex:indexPath.row];
    
    [cell.routeDetail setText:currentRoute];
    [cell.distanceDetail setText: [Distances objectAtIndex:indexPath.row]];
    [cell.durationDetail setText: [Durations objectAtIndex:indexPath.row]];
    
    if([currentRoute rangeOfString:@"northwest" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"northwest.png"];
    }else if([currentRoute rangeOfString:@"southwest" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"southwest.png"];
    }else if([currentRoute rangeOfString:@"southeast" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"southeast.png"];
    }else if([currentRoute rangeOfString:@"northeast" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"northeast.png"];
    }else if([currentRoute rangeOfString:@"northwest" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"northwest.png"];
    }else if([currentRoute rangeOfString:@"north" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"north.png"];
    }else if([currentRoute rangeOfString:@"south" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"south.png"];
    }else if([currentRoute rangeOfString:@"right" options:NSCaseInsensitiveSearch].length || [currentRoute rangeOfString:@"east" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"east.png"];
    }else if([currentRoute rangeOfString:@"left" options:NSCaseInsensitiveSearch].length || [currentRoute rangeOfString:@"west" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"west.png"];
    }else if([currentRoute rangeOfString:@"merge" options:NSCaseInsensitiveSearch].length || [currentRoute rangeOfString:@"take" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"northeast.png"];
    }else if([currentRoute rangeOfString:@"u-turn" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"uturn.png"];
    }else if([currentRoute rangeOfString:@"exit" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"northeast.png"];
    }else if([currentRoute rangeOfString:@"continue" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"north.png"];
    }else if([currentRoute rangeOfString:@"sail" options:NSCaseInsensitiveSearch].length){
        cell.cardinal.image = [UIImage imageNamed:@"sail.png"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 100;
}

-(NSString *)saveFilePath:(NSString *)pathName{
    NSArray *path =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[path objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",pathName]];
}

@end