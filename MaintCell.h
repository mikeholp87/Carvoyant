//
//  MaintCell.h
//  CarVoyant
//
//  Created by Michael Holp on 11/23/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel *actionLbl;
@property (nonatomic, retain) IBOutlet UILabel *frequencyLbl;
@property (nonatomic, retain) IBOutlet UILabel *mileageLbl;
@property (nonatomic, retain) IBOutlet UILabel *itemLbl;
@property (nonatomic, retain) IBOutlet UILabel *monthLbl;
@property (nonatomic, retain) IBOutlet UITextView *description;

@end
