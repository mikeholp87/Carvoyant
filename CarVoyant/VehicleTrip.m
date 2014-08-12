//
//  VehicleTrip.m
//  CarVoyant
//
//  Created by Michael Holp on 11/9/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import "VehicleTrip.h"

@implementation VehicleTrip
@synthesize mapView, vehicle1Coord, routeName, mileage, vehicle2Coord, startLatitude, startLongitude, endLatitude, endLongitude;

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
    
    self.title = routeName;
    
    [self plotRoute];
}

- (void)plotRoute
{
    vehicle1Coord.latitude = [startLatitude floatValue];
    vehicle1Coord.longitude = [startLongitude floatValue];
    vehicle2Coord.latitude = [endLatitude floatValue];
    vehicle2Coord.longitude = [endLongitude floatValue];
    
    CLLocation *start = [[CLLocation alloc] initWithLatitude:vehicle1Coord.latitude longitude:vehicle1Coord.longitude];
    CLLocation *end = [[CLLocation alloc] initWithLatitude:vehicle2Coord.latitude longitude:vehicle2Coord.longitude];
    CLLocationDistance distance = [start distanceFromLocation:end] * 0.000621371;
    
    MapPoint *annotation = [[MapPoint alloc] initWithName:routeName datetime:mileage distance:distance coordinate:vehicle1Coord];
    [mapView addAnnotation:annotation];
    
    annotation = [[MapPoint alloc] initWithName:routeName datetime:mileage distance:distance coordinate:vehicle2Coord];
    [mapView addAnnotation:annotation];
    
    [self addOverlayForRouteFromCoordinate:vehicle1Coord toCoordinate:vehicle2Coord];
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
    
    [self addOverlayForRouteFromCoordinate:vehicle1Coord toCoordinate:vehicle2Coord];
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

@end
