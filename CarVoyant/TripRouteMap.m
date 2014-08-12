//
//  TripRouteMap.m
//  CarVoyant
//
//  Created by Michael Holp on 11/9/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import "TripRouteMap.h"

@implementation TripRouteMap
@synthesize deviceId, trips, buffer, connection, mapView, startCoord, endCoord, segControl, tripTable;

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
    self.title = @"Trip Routes";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.carvoyant.com/v1/api/vehicle/%@/trip?sortOrder=desc", deviceId]]];
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
        
        trips = [[NSMutableDictionary alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error){
                NSArray *results = [res objectForKey:@"trip"];
                NSInteger index = 0;
                for (NSDictionary *result in results) {
                    [trips setObject:result forKey:[NSString stringWithFormat:@"%ld", (long)index++]];
                }
            }else
                NSLog(@"%@",[error localizedDescription]);
            
            //NSLog(@"%@", trips);
            
            [self plotTrips];
        });
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.connection = nil;
    self.buffer = nil;
    
    NSLog(@"%@",[error localizedDescription]);
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[trips allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"cvimage.png"];
    cell.textLabel.text = [NSString stringWithFormat:@"Route #%ld", (long)indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ miles",[[trips objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] objectForKey:@"mileage"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VehicleTrip *vehicle = [self.storyboard instantiateViewControllerWithIdentifier:@"VehicleTrip"];
    vehicle.routeName = [NSString stringWithFormat:@"Route #%ld", (long)indexPath.row];
    vehicle.mileage = [NSString stringWithFormat:@"%@ miles",[[trips objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] objectForKey:@"mileage"]];
    vehicle.startLatitude = [[[trips objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] objectForKey:@"startWaypoint"] objectForKey:@"latitude"];
    vehicle.startLongitude = [[[trips objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] objectForKey:@"startWaypoint"] objectForKey:@"longitude"];
    vehicle.endLatitude = [[[trips objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] objectForKey:@"endWaypoint"] objectForKey:@"latitude"];
    vehicle.endLongitude = [[[trips objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] objectForKey:@"endWaypoint"] objectForKey:@"longitude"];
    [self.navigationController pushViewController:vehicle animated:YES];
}

- (void)plotTrips {
    for(int i=0; i<[[trips allKeys] count]; i++){
        NSDictionary *startWaypoint = [[trips objectForKey:[NSString stringWithFormat:@"%d", i]] objectForKey:@"startWaypoint"];
        NSDictionary *endWaypoint = [[trips objectForKey:[NSString stringWithFormat:@"%d", i]] objectForKey:@"endWaypoint"];
        
        if(![startWaypoint isKindOfClass:[NSNull class]]){
            startCoord.latitude = [[startWaypoint objectForKey:@"latitude"] floatValue];
            startCoord.longitude = [[startWaypoint objectForKey:@"longitude"] floatValue];
        }
        
        if(![endWaypoint isKindOfClass:[NSNull class]]){
            endCoord.latitude = [[endWaypoint objectForKey:@"latitude"] floatValue];
            endCoord.longitude = [[endWaypoint objectForKey:@"longitude"] floatValue];
        }
        
        CLLocation *start = [[CLLocation alloc] initWithLatitude:startCoord.latitude longitude:startCoord.longitude];
        CLLocation *end = [[CLLocation alloc] initWithLatitude:endCoord.latitude longitude:endCoord.longitude];
        CLLocationDistance distance = [start distanceFromLocation:end] * 0.000621371;
        
        NSString *startTime = [[trips objectForKey:[NSString stringWithFormat:@"%d", i]] objectForKey:@"startTime"];
        NSString *endTime = [[trips objectForKey:[NSString stringWithFormat:@"%d", i]] objectForKey:@"endTime"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd'T'hhmmss+0000"];
        NSDate *startDate = [dateFormat dateFromString:startTime];
        [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
        startTime = [dateFormat stringFromDate:startDate];
        NSLog(@"%@", startTime);
        
        NSDate *endDate = [dateFormat dateFromString:endTime];
        endTime = [dateFormat stringFromDate:endDate];
        
        MapPoint *annotation = [[MapPoint alloc] initWithName:[NSString stringWithFormat:@"Waypoint #%d",i] datetime:startTime distance:distance coordinate:startCoord];
        [mapView addAnnotation:annotation];
        
        if(i==0) [self addOverlayForRouteFromCoordinate:startCoord toCoordinate:endCoord];
        else [self addOverlayForRouteFromCoordinate:endCoord toCoordinate:startCoord];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
	}
    
    static NSString *identifier = @"MapPoint";
    if([annotation isKindOfClass:[MapPoint class]]){
        MKAnnotationView *annotationView = (MKAnnotationView *) [mv dequeueReusableAnnotationViewWithIdentifier:identifier];
        if(annotationView == nil){
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"cvimage.png"];
            
            UIButton *leftAccessory = [UIButton buttonWithType:UIButtonTypeCustom];
            leftAccessory.frame = CGRectMake(0, 0, 25, 25);
            [leftAccessory setBackgroundImage:[UIImage imageNamed:@"mapicon.png"] forState:UIControlStateNormal];
            annotationView.leftCalloutAccessoryView = leftAccessory;
        }else{
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mv didSelectAnnotationView:(MKAnnotationView *)view
{
    [mapView setCenterCoordinate:view.annotation.coordinate];
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *ulv = [mv viewForAnnotation:mv.userLocation];
    ulv.canShowCallout = NO;
    
    id <MKAnnotation> mp = [mv.annotations objectAtIndex:0];
    [mv setRegion:[self regionFromLocations:mapView.annotations] animated:NO];
    [mv selectAnnotation:mp animated:YES];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 3.0;
        return renderer;
    }
    return nil;
}

-(void)addOverlayForRouteFromCoordinate:(CLLocationCoordinate2D)startCoordinate toCoordinate:(CLLocationCoordinate2D)stopCoordinate {
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:startCoordinate addressDictionary:nil];
    MKPlacemark *stopPlacemark = [[MKPlacemark alloc] initWithCoordinate:stopCoordinate addressDictionary:nil];
    MKDirectionsRequest *directionsRequest = MKDirectionsRequest.new;
    directionsRequest.source = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    directionsRequest.destination = [[MKMapItem alloc] initWithPlacemark:stopPlacemark];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    directionsRequest.requestsAlternateRoutes = NO;
    MKDirections *mkdirections = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    [mkdirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            MKRoute *route = response.routes[0];
            [mapView addOverlay:route.polyline];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if(control == view.leftCalloutAccessoryView){
        [self useGoogleMaps];
    }
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

- (void)useGoogleMaps
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        myData = [[GetDirections alloc] initWithStartPoint:@"San Francisco, CA" endPoint:@"Austin, TX" mapType:@"GoogleMaps" travelMode:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            RoutesTableView *RoutesCTRL = [self.storyboard instantiateViewControllerWithIdentifier:@"RoutesTableView"];
            RoutesCTRL.startPoint = @"San Francisco, CA";
            RoutesCTRL.endPoint = @"Austin, TX";
            [self.navigationController pushViewController:RoutesCTRL animated:YES];
        });
    });
}

- (IBAction)selectView:(id)sender
{
    switch ([segControl selectedSegmentIndex]) {
        case 0:
            tripTable.hidden = YES;
            mapView.hidden = NO;
            [self plotTrips];
            break;
        case 1:
            mapView.hidden = YES;
            tripTable.hidden = NO;
            [tripTable reloadData];
        default:
            break;
    }
}

@end
