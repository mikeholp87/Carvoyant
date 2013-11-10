//
//  RouteCell.h
//  FindMyCar
//
//  Created by Michael Holp on 11/17/12.
//  Copyright (c) 2012 Flash Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UITextView *routeDetail;
@property (nonatomic, retain) IBOutlet UITextView *durationDetail;
@property (nonatomic, retain) IBOutlet UILabel *distanceDetail;
@property (nonatomic, retain) IBOutlet UIImageView *cardinal;
@end
