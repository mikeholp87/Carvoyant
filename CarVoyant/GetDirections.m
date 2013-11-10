//
//  GetDirections.m
//  FindMyCar
//
//  Created by Michael Holp on 11/17/12.
//  Copyright (c) 2012 Flash Corp. All rights reserved.
//

#import "GetDirections.h"

//#define kGeoCodingString @"http://maps.google.com/maps/geo?q=%f,%f&output=csv"
#define kGeoCodingString @"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true&language=us"
#define kRoutesString @"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false"
#define kAppleMapsString @"http://maps.apple.com/maps?daddr=%@&saddr=%@"
#define kGMapsAppString @"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=%@"

@implementation GetDirections

-(id)initWithStartPoint:(NSString *)start endPoint:(NSString *)end mapType:(NSString *)type travelMode:(NSString *)mode
{
    NSLog(@"start: %@, end: %@", start, end);
    
    if([type isEqualToString:@"AppleMaps"]){
        NSString *urlString = [NSString stringWithFormat:kAppleMapsString,start,end];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        
        [[UIApplication sharedApplication] openURL:url];
    }else if([type isEqualToString:@"GoogleMaps"]){
        NSString *urlString = [NSString stringWithFormat:kRoutesString,start,end];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [request setTag:0];
        [request startAsynchronous];
    }else if([type isEqualToString:@"GMapsApp"]){
        NSString *urlString = [NSString stringWithFormat:kGMapsAppString,start,end,mode];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:url];
    }
    
    return self;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *jsonString = [request responseString];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    jsonObject = [parser objectWithString:jsonString error:NULL];
    
    if(request.tag == 0){
        NSMutableDictionary *resultsObject = [[NSMutableDictionary alloc] init];
        resultsObject = [[jsonObject objectForKey:@"routes"] objectAtIndex:0];
        
        NSMutableDictionary *legsResult = [[NSMutableDictionary alloc] init];
        legsResult = [[resultsObject objectForKey:@"legs"] objectAtIndex:0];
        
        NSString *totalDistance = [[legsResult objectForKey:@"distance"] objectForKey:@"text"];
        NSString *totalDuration = [[legsResult objectForKey:@"duration"] objectForKey:@"text"];
        
        NSMutableArray *stepsResult = [[NSMutableArray alloc] init];
        stepsResult = [legsResult objectForKey:@"steps"];
        
        NSMutableArray *routes = [[NSMutableArray alloc] init];
        NSMutableArray *distances = [[NSMutableArray alloc] init];
        NSMutableArray *durations = [[NSMutableArray alloc] init];
        for(int i=0; i<[stepsResult count]; i++) {
            [routes addObject:[[NSString stringWithFormat:@"%@",[[stepsResult objectAtIndex:i] objectForKey:@"html_instructions"]] stripHtml]];
            [distances addObject:[NSString stringWithFormat:@"%@",[[[stepsResult objectAtIndex:i] objectForKey:@"distance"] objectForKey:@"text"]]];
            [durations addObject:[NSString stringWithFormat:@"%@",[[[stepsResult objectAtIndex:i] objectForKey:@"duration"] objectForKey:@"text"]]];
        }
        
        [routes writeToFile:[self saveFilePath:@"routes"] atomically:YES];
        [distances writeToFile:[self saveFilePath:@"distances"] atomically:YES];
        [durations writeToFile:[self saveFilePath:@"durations"] atomically:YES];
        [totalDistance writeToFile:[self saveFilePath:@"totalDistance"] atomically:YES encoding:NSUTF32StringEncoding error:nil];
        [totalDuration writeToFile:[self saveFilePath:@"totalDuration"] atomically:YES encoding:NSUTF32StringEncoding error:nil];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.localizedDescription);
}

- (void)fetchReverseGeocodeAddress:(float)pdblLatitude withLongitude:(float)pdblLongitude withCompletionHanlder:(ReverseGeoCompletionBlock)completion {
    
    geocoder = [[CLGeocoder alloc] init];
    CLGeocodeCompletionHandler completionHandler = ^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        if (placemarks) {
            [placemarks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CLPlacemark *placemark = placemarks[0];
                NSDictionary *info = placemark.addressDictionary;
                NSString *address = [NSString stringWithFormat:@"%@, %@, %@", [info objectForKey:@"Street"], [info objectForKey:@"City"], [info objectForKey:@"State"]];
                if (completion) {
                    completion(address);
                }
                *stop = YES;
            }];
        }
    };
    
    CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:pdblLatitude longitude:pdblLongitude];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:completionHandler];
}

- (void)fetchForwardGeocodeAddress:(NSString *)address withCompletionHanlder:(ForwardGeoCompletionBlock)completion {
    geocoder = [[CLGeocoder alloc] init];
    CLGeocodeCompletionHandler completionHandler = ^(NSArray *placemarks, NSError *error) {
        if (error) {
            //NSLog(@"error finding placemarks: %@", [error localizedDescription]);
        }
        if (placemarks) {
            [placemarks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CLPlacemark *placemark = (CLPlacemark *)obj;
                NSLog(@"PLACEMARK: %@", placemark);
                //NSLog(@"********found coords for zip: %f %f", placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
                if (completion) {
                    completion(placemark.location.coordinate);
                }
                *stop = YES;
            }];
        }
    };
    
    [geocoder geocodeAddressString:address completionHandler:completionHandler];
}

-(NSString *)saveFilePath:(NSString *)pathName{
    NSArray *path =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[path objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",pathName]];
}

@end
