//
//  MapPoint.m
//  Dude Where's My Car?
//
//  Created by Michael Holp on 11/20/12.
//  Copyright (c) 2012 Holp. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint
@synthesize name = _name;
@synthesize datetime = _datetime;
@synthesize distance = _distance;
@synthesize coordinate = _coordinate;

-(id)initWithName:(NSString*)name datetime:(NSString*)dt distance:(CLLocationDistance)distance coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _name = [name copy];
        _datetime = [dt copy];
        _distance = distance;
        _coordinate = coordinate;
    }
    return self;
}

-(NSString *)title {
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else
        return _name;
}

-(NSString *)subtitle {
    return _datetime;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _datetime};
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end
