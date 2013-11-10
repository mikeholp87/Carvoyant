//
//  GetDirections.h
//  FindMyCar
//
//  Created by Michael Holp on 11/17/12.
//  Copyright (c) 2012 Flash Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "NSString_stripHtml.h"

typedef void (^ForwardGeoCompletionBlock)(CLLocationCoordinate2D coords);
typedef void (^ReverseGeoCompletionBlock)(NSString *address);

@interface GetDirections : NSObject<CLLocationManagerDelegate>
{
    CLGeocoder *geocoder;
    CLLocation *currentLocation;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D userCoordinate;
    CLLocationCoordinate2D coordinate;
    NSMutableDictionary *dirData;
    NSString *currentAddress;
}

-(id)initWithStartPoint:(NSString *)start endPoint:(NSString *)end mapType:(NSString *)type travelMode:(NSString *)mode;
- (void)fetchForwardGeocodeAddress:(NSString *)address withCompletionHanlder:(ForwardGeoCompletionBlock)completion;
- (void)fetchReverseGeocodeAddress:(float)pdblLatitude withLongitude:(float)pdblLongitude withCompletionHanlder:(ReverseGeoCompletionBlock)completion;

@end
