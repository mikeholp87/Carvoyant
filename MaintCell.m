//
//  MaintCell.m
//  CarVoyant
//
//  Created by Michael Holp on 11/23/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import "MaintCell.h"

@implementation MaintCell
@synthesize actionLbl, frequencyLbl, mileageLbl, monthLbl, itemLbl, description;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
