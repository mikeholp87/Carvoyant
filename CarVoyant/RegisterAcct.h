//
//  RegisterAcct.h
//  Dude Where's My Car
//
//  Created by Mike Holp on 3/24/13.
//  Copyright (c) 2013 Flash Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "GradientButton.h"

@interface RegisterAcct : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverControllerDelegate, UIActionSheetDelegate>
{
    NSArray *countryCodes;
    CGFloat animatedDistance;
}

@property(nonatomic,retain) IBOutlet UITextField *emailField;
@property(nonatomic,retain) IBOutlet UITextField *passwdField;
@property(nonatomic,retain) IBOutlet UITextField *cityField;
@property(nonatomic,retain) IBOutlet UITextField *stateField;
@property(nonatomic,retain) IBOutlet UITextField *zipField;
@property(nonatomic,retain) IBOutlet UITextField *countryField;

@property(nonatomic,retain) IBOutlet UITextField *makeField;
@property(nonatomic,retain) IBOutlet UITextField *modelField;
@property(nonatomic,retain) IBOutlet UITextField *yearField;

@property(nonatomic,retain) IBOutlet UIButton *buttonPostStatus;

@property(nonatomic,retain) UIActionSheet *pickerSheet;
@property(nonatomic,retain) UIPickerView *countryPicker;
@property(nonatomic,retain) UIPopoverController *popoverController;
@property(nonatomic,retain) UISegmentedControl *segControl;
@property(nonatomic,retain) NSUserDefaults *settings;

@property(nonatomic,retain) GradientButton *confirmBtn;
@property(nonatomic,retain) GradientButton *cancelBtn;

@end
