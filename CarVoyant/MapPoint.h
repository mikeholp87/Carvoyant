//
//  MapPoint.h
//  Dude Where's My Car?
//
//  Created by Michael Holp on 11/20/12.
//  Copyright (c) 2012 Holp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>

@interface MapPoint : NSObject <MKAnnotation>
{
    NSString *_name;
    NSString *_datetime;
    CLLocationCoordinate2D _coordinate;
}

@property (copy) NSString *name;
@property (copy) NSString *datetime;
@property (nonatomic, readonly) CLLocationDistance distance;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id)initWithName:(NSString*)name datetime:(NSString*)dt distance:(CLLocationDistance)distance coordinate:(CLLocationCoordinate2D)coordinate;
-(MKMapItem*)mapItem;

@end
