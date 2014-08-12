//
//  NearbyPlaces.m
//  Dude Where's My Car
//
//  Created by Mike Holp on 2/4/13.
//  Copyright (c) 2013 Flash Corp. All rights reserved.
//

#import "NearbyPlaces.h"

#define kNavTintColor [UIColor colorWithRed:26/255.0 green:152/255.0 blue:217/255.0 alpha:1.000]
#define kTabTintColor [UIColor colorWithRed:26/255.0 green:152/255.0 blue:217/255.0 alpha:1.000]

@implementation NearbyPlaces
@synthesize nearbyMap, locationManager, userCoordinate, stationCoordinate, placesArray, placeNames, toolbar, placesButton, searchBar, searchDisplayController, searchResults, segControl, nearbyTable;

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
    
    self.title = @"Repair Shops";
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }else{
        [self.navigationController.navigationBar setTintColor:kNavTintColor];
        [self.navigationItem.rightBarButtonItem setTintColor:kNavTintColor];
        [[UIToolbar appearance] setTintColor:kTabTintColor];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(retrievePlaces)];
    [self.navigationItem setRightBarButtonItem:refresh];
    
    placeType = @"car_repair";
    
    [self setUserLocation];
    [self retrievePlaces];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbar.hidden = NO;
}

-(void)setUserLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if([CLLocationManager locationServicesEnabled]){
        switch([CLLocationManager authorizationStatus]){
            case kCLAuthorizationStatusAuthorized:
                if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
                    [locationManager requestWhenInUseAuthorization];
                    [locationManager requestAlwaysAuthorization];
                }
                [locationManager startUpdatingLocation];
                break;
            case kCLAuthorizationStatusDenied:
                [[[UIAlertView alloc] initWithTitle:@"Location Services" message:@"Denied" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                break;
            case kCLAuthorizationStatusRestricted:
                [[[UIAlertView alloc] initWithTitle:@"Location Services" message:@"Restricted by Parental Controls" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [[[UIAlertView alloc] initWithTitle:@"Location Services" message:@"Restricted by Parental Controls" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                break;
            case kCLAuthorizationStatusNotDetermined:
                [[[UIAlertView alloc] initWithTitle:@"Location Services" message:@"Location Services Disabled" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                break;
        }
    }
    
    userCoordinate = locationManager.location.coordinate;
    [nearbyMap showsUserLocation];
    [nearbyMap setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [nearbyMap setCenterCoordinate:userCoordinate];
    
    MKCoordinateRegion region;
    region.center.latitude = userCoordinate.latitude;
    region.center.longitude = userCoordinate.longitude;
    region.span.latitudeDelta = 0.5;
    region.span.longitudeDelta = 0.5;
    region = [nearbyMap regionThatFits:region];
    [nearbyMap setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations objectAtIndex:0];
    userCoordinate = location.coordinate;
}

- (void)retrievePlaces
{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", userCoordinate.latitude, userCoordinate.longitude, [NSString stringWithFormat:@"%i", 5000], placeType, kGOOGLE_API_KEY];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL = [NSURL URLWithString:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:googleRequestURL];
    [request setDelegate:self];
    [request setTag:1];
    [request startAsynchronous];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *identifier = @"MapPoint";
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *) [nearbyMap dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.draggable = NO;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", placeType]];
        
        return annotationView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *ulv = [mv viewForAnnotation:mv.userLocation];
    ulv.canShowCallout = NO;
    
    id <MKAnnotation> mp = [mv.annotations objectAtIndex:0];
    [mv setRegion:[self regionFromLocations:nearbyMap.annotations] animated:YES];
    [mv selectAnnotation:mp animated:YES];
}

- (MKCoordinateRegion)regionFromLocations:(NSArray *)annotations {
    id <MKAnnotation> mp = [annotations objectAtIndex:0];
    
    CLLocationCoordinate2D upper = [mp coordinate];
    CLLocationCoordinate2D lower = [mp coordinate];
    
    // FIND LIMITS
    for(MapPoint *eachLocation in annotations) {
        if([eachLocation coordinate].latitude > upper.latitude) upper.latitude = [eachLocation coordinate].latitude;
        if([eachLocation coordinate].latitude < lower.latitude) lower.latitude = [eachLocation coordinate].latitude;
        if([eachLocation coordinate].longitude > upper.longitude) upper.longitude = [eachLocation coordinate].longitude;
        if([eachLocation coordinate].longitude < lower.longitude) lower.longitude = [eachLocation coordinate].longitude;
    }
    
    // FIND REGION
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta = 1.5*(upper.latitude - lower.latitude);
    locationSpan.longitudeDelta = 1.5*(upper.longitude - lower.longitude);
    CLLocationCoordinate2D locationCenter;
    locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
    locationCenter.longitude = (upper.longitude + lower.longitude) / 2;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    lat_delta = region.span.latitudeDelta;
    lng_delta = region.span.latitudeDelta;
    
    return region;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location: %@", [newLocation description]);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}

-(void)plotPositions
{
    [nearbyMap removeAnnotations:nearbyMap.annotations];
    
    userCoordinate = locationManager.location.coordinate;
    [nearbyMap setCenterCoordinate:userCoordinate animated:YES];
    
    NSLog(@"%@", placesArray);
    
    // 2 - Loop through the array of places returned from the Google API.
    for (int i=0; i<[placesArray count]; i++) {
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary *place = [placesArray objectAtIndex:i];
        // 3 - There is a specific NSDictionary object that gives us the location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        // Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        // 4 - Get your name and address info for adding to a pin.
        NSString *name = [place objectForKey:@"name"];
        NSString *vicinity = [place objectForKey:@"vicinity"];
        // Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        // Set the lat and long.
        placeCoord.latitude = [[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude = [[loc objectForKey:@"lng"] doubleValue];
        
        CLLocation *stationCoord = [[CLLocation alloc] initWithLatitude:placeCoord.latitude longitude:placeCoord.longitude];
        CLLocation *userCoord = [[CLLocation alloc] initWithLatitude:userCoordinate.latitude longitude:userCoordinate.longitude];
        CLLocationDistance distance = [stationCoord distanceFromLocation:userCoord];
        
        // 5 - Create a new annotation.
        MapPoint *placeObject = [[MapPoint alloc] initWithName:name datetime:vicinity distance:distance coordinate:placeCoord];
        [nearbyMap addAnnotation:placeObject];
    }
}

/****************************************************************************/
/*								Table  Display                              */
/****************************************************************************/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[placeNames allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [[placeNames objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]] objectAtIndex:1];
    cell.detailTextLabel.text = [[placeNames objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] objectAtIndex:0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%@", [placeNames objectForKey:[searchResults objectAtIndex:indexPath.row]]);
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    //NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    
    //searchResults = [placeNames filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *jsonString = [request responseString];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSLog(@"%@", jsonString);
    
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    jsonObject = [parser objectWithString:jsonString error:NULL];
    placesArray = [[NSMutableArray alloc] init];
    placeNames = [[NSMutableDictionary alloc] init];
    
    if(request.tag == 1){
        placesArray = [jsonObject objectForKey:@"results"];
        for(int i=0; i<[placesArray count]; i++){
            [placeNames setObject:[NSArray arrayWithObjects:[[placesArray objectAtIndex:i] objectForKey:@"vicinity"], [[placesArray objectAtIndex:i] objectForKey:@"name"], nil] forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    [self selectView:self];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dude Where's My Car?" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)choosePlaces:(id)sender
{
    placesButton.enabled = NO;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Search Places" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Fuel", @"Restaurants", @"Lodging", @"Café", @"Bar", @"Bank", @"Car Rental", nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [actionSheet showInView:self.view];
    }else{
        [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet showFromBarButtonItem:placesButton animated:YES];
    }
}

-(IBAction)showMap:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:YES];
    [self.navigationController popViewControllerAnimated:NO];
    [UIView commitAnimations];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    placesButton.enabled = YES;
    
    if([buttonTitle isEqualToString:@"Fuel"]){
        placeType = @"gas_station";
        self.title = @"Fuel";
    }else if([buttonTitle isEqualToString:@"Restaurants"]){
        placeType = @"food";
        self.title = @"Restaurants";
    }else if([buttonTitle isEqualToString:@"Lodging"]){
        placeType = @"lodging";
        self.title = @"Lodging";
    }else if([buttonTitle isEqualToString:@"Café"]){
        placeType = @"cafe";
        self.title = @"Cafés";
    }else if([buttonTitle isEqualToString:@"Bar"]){
        placeType = @"bar";
        self.title = @"Bars";
    }else if([buttonTitle isEqualToString:@"Bank"]){
        placeType = @"bank";
        self.title = @"Banks";
    }else if([buttonTitle isEqualToString:@"Car Rental"]){
        placeType = @"car_rental";
        self.title = @"Car Rentals";
    }else if([buttonTitle isEqualToString:@"Cancel"]){
        NSLog(@"Cancel");
    }
    
    [self retrievePlaces];
}

- (IBAction)selectView:(id)sender
{
    switch ([segControl selectedSegmentIndex]) {
        case 0:
            nearbyTable.hidden = YES;
            nearbyMap.hidden = NO;
            [self plotPositions];
            break;
        case 1:
            nearbyMap.hidden = YES;
            nearbyTable.hidden = NO;
            [nearbyTable reloadData];
        default:
            break;
    }
}

@end
