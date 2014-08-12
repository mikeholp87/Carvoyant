//
//  RegisterAcct.m
//  Dude Where's My Car
//
//  Created by Mike Holp on 3/24/13.
//  Copyright (c) 2013 Flash Corp. All rights reserved.
//

#import "RegisterAcct.h"

@implementation RegisterAcct
@synthesize emailField, passwdField, cityField, stateField, zipField, countryField, modelField, makeField, yearField, buttonPostStatus;
@synthesize segControl, countryPicker, pickerSheet, popoverController, confirmBtn, cancelBtn, settings;

//Constants for view manipulation during keyboard usage
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3f;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2f;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8f;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

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
	// Do any additional setup after loading the view.
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        confirmBtn = [[GradientButton alloc] initWithFrame:CGRectMake(105, 280, 100, 40)];
        cancelBtn = [[GradientButton alloc] initWithFrame:CGRectMake(110, 340, 90, 35)];
    }else{
        confirmBtn = [[GradientButton alloc] initWithFrame:CGRectMake(260, 420, 134, 58)];
        cancelBtn = [[GradientButton alloc] initWithFrame:CGRectMake(260, 500, 134, 58)];
    }
    
    [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:24.0];
    [confirmBtn addTarget:self action:@selector(createAcct) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn useSimpleOrangeStyle];
    [self.view addSubview:confirmBtn];
    
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [cancelBtn addTarget:self action:@selector(cancelAcct) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn useWhiteActionSheetStyle];
    [self.view addSubview:cancelBtn];
    
    settings = [[NSUserDefaults alloc] init];
    
    countryCodes = [[[NSLocale ISOCountryCodes] reverseObjectEnumerator] allObjects];
}

#pragma mark UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [countryCodes count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [countryCodes objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    countryField.text = [countryCodes objectAtIndex:row];
    
    [countryPicker selectRow:row inComponent:0 animated:NO];
}

- (void)createAcct
{
    if([self validateEmail:emailField.text] && passwdField.text.length > 0 && cityField.text.length > 0 && stateField.text.length > 0 && zipField.text.length > 0 && modelField.text.length > 0 && makeField.text.length > 0 && yearField.text.length > 0){
        [self registerUser];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Dude Alert" message:@"Please fill in all fields before proceeding." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)registerUser{
    //UIViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    //[self.navigationController pushViewController:profile animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)cancelAcct
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)validatePhone:(NSString*)phoneString
{
    NSString *regExPattern = @"^(?:(?:\\+?1\\s*(?:[.-]\\s*)?)?(?:\\(\\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\\s*\\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\\s*(?:[.-]\\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\\s*(?:[.-]\\s*)?([0-9]{4})(?:\\s*(?:#|x\\.?|ext\\.?|extension)\\s*(\\d+))?$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:phoneString options:0 range:NSMakeRange(0, [phoneString length])];
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else
        return YES;
}

-(BOOL)validateEmail:(NSString*)emailString
{
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else
        return YES;
}

-(NSString *)formatPhoneNumber:(NSString*)strippedString{
    NSString *areaCode = [[NSString alloc] init];
    NSString *firstThree = [[NSString alloc] init];
    NSString *lastFour = [[NSString alloc] init];
    
    while (strippedString.length>10) {
        strippedString = [strippedString substringToIndex:10];
    }
    if(strippedString.length<7 && strippedString.length>3){
        areaCode = [strippedString substringToIndex:3];
        firstThree = [strippedString substringFromIndex:3];
        return [NSString stringWithFormat:@"(%@) %@",areaCode,firstThree];
    }
    else if (strippedString.length>=7){
        areaCode = [strippedString substringToIndex:3];
        firstThree = [strippedString substringFromIndex:3];
        lastFour = [firstThree substringFromIndex:3];
        firstThree = [firstThree substringToIndex:3];
        return [NSString stringWithFormat:@"(%@) %@-%@",areaCode,firstThree,lastFour];
    }
    else{
        return strippedString;
    }
}

- (UIToolbar *)keyboardToolBar {
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    segControl = [[UISegmentedControl alloc] initWithItems:@[@"Previous", @"Next"]];
    segControl.momentary = YES;
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
    
    [segControl addTarget:self action:@selector(nextPrevious) forControlEvents:(UIControlEventValueChanged)];
    [segControl setEnabled:NO forSegmentAtIndex:0];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithCustomView:segControl];
    
    NSArray *itemsArray = @[nextButton, flexibleItem, done];
    
    [toolbar setItems:itemsArray];
    
    return toolbar;
}

- (void)showCountryPicker
{
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:@"Countries" style:UIBarButtonItemStylePlain target:self action:nil];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissActionSheet)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"SET" style:UIBarButtonItemStyleDone target:self action:@selector(dismissActionSheet)];
    
    NSArray *itemsArray = @[cancel, flexibleItem, title, flexibleItem, done];
    
    countryPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 250.0)];
    countryPicker.delegate = self;
    countryPicker.dataSource = self;
    countryPicker.showsSelectionIndicator = YES;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        pickerSheet = [[UIActionSheet alloc] initWithTitle:@"Title" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Dismiss" otherButtonTitles:@"OK",nil];
        [pickerSheet setBounds:CGRectMake(0,0,320,200)];
        [pickerSheet showInView:self.view];
        pickerSheet.clipsToBounds = YES;
        
        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        pickerToolbar.barStyle = UIBarStyleBlackOpaque;
        [pickerToolbar sizeToFit];
        [pickerToolbar setItems:itemsArray];
        [pickerSheet addSubview:pickerToolbar];
        [pickerSheet addSubview:countryPicker];
        countryPicker.hidden = NO;
    }else{
        UINavigationBar *navigation = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        
        UIViewController *popoverContent = [[UIViewController alloc] init];
        UIView *popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];
        popoverView.backgroundColor = [UIColor grayColor];
        
        [popoverView addSubview:navigation];
        [popoverView addSubview:countryPicker];
        popoverContent.view = popoverView;
        
        popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 220);
        popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        popoverController.delegate = self;
        [popoverController presentPopoverFromRect:[self.view bounds] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)dismissActionSheet
{
    [self dismissKeyboard];
    [pickerSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)nextPrevious
{
    switch([segControl selectedSegmentIndex]) {
        case 0:{
            if(passwdField.isEditing) [emailField becomeFirstResponder];
            else if(cityField.isEditing) [passwdField becomeFirstResponder];
            else if(stateField.isEditing) [cityField becomeFirstResponder];
            else if(zipField.isEditing) [stateField becomeFirstResponder];
            else if(makeField.isEditing) [zipField becomeFirstResponder];
            else if(modelField.isEditing) [makeField becomeFirstResponder];
            else if(yearField.isEditing) [modelField becomeFirstResponder];
        }
            break;
        case 1:{
            if(emailField.isEditing) [passwdField becomeFirstResponder];
            else if(passwdField.isEditing) [cityField becomeFirstResponder];
            else if(cityField.isEditing) [stateField becomeFirstResponder];
            else if(stateField.isEditing) [zipField becomeFirstResponder];
            else if(zipField.isEditing) [makeField becomeFirstResponder];
            else if(makeField.isEditing) [modelField becomeFirstResponder];
            else if(modelField.isEditing) [yearField becomeFirstResponder];
        }
            break;
    }
}

#pragma mark UItextField Handling
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect  = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5f * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0f;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0f;
    }
    UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floorf(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floorf(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self keyboardToolBar];
    if (textField == emailField){
        [segControl setEnabled:NO forSegmentAtIndex:0];
        [segControl setEnabled:YES forSegmentAtIndex:1];
    }else if (textField == yearField){
        [segControl setEnabled:YES forSegmentAtIndex:0];
        [segControl setEnabled:NO forSegmentAtIndex:1];
    }else if (textField == countryField){
        [self dismissKeyboard];
        [self showCountryPicker];
        [segControl setEnabled:YES forSegmentAtIndex:0];
        [segControl setEnabled:NO forSegmentAtIndex:1];
        countryPicker.hidden = NO;
        return NO;
    }else{
        [segControl setEnabled:YES forSegmentAtIndex:0];
        [segControl setEnabled:YES forSegmentAtIndex:1];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == stateField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 2) ? NO : YES;
    }
    else if(textField == zipField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 5) ? NO : YES;
    }
    else if(textField == yearField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 4) ? NO : YES;
    }
    /*
     if(textField == emailField) {
     NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
     newString = [[newString componentsSeparatedByCharactersInSet:
     [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
     newString = [self formatPhoneNumber:newString];
     
     textField.text = newString;
     return NO;
     }
     */
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self dismissKeyboard];
    
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)dismissKeyboard
{
    [emailField resignFirstResponder];
    [passwdField resignFirstResponder];
    [cityField resignFirstResponder];
    [stateField resignFirstResponder];
    [zipField resignFirstResponder];
    [modelField resignFirstResponder];
    [makeField resignFirstResponder];
    [yearField resignFirstResponder];
    if (!countryPicker.hidden) {
        countryField.text = [countryCodes objectAtIndex:[countryPicker selectedRowInComponent:0]];
        [countryPicker setHidden:YES];
    }
}

@end
