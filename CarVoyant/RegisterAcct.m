//
//  RegisterAcct.m
//  Dude Where's My Car
//
//  Created by Mike Holp on 3/24/13.
//  Copyright (c) 2013 Flash Corp. All rights reserved.
//

#import "RegisterAcct.h"

@implementation RegisterAcct
@synthesize emailField, passwdField, cityField, stateField, zipField, countryField, buttonPostStatus;
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
    if([self validateEmail:emailField.text] && passwdField.text.length > 0 && cityField.text.length > 0 && stateField.text.length > 0 && zipField.text.length > 0){
        [self registerUser];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Dude Alert" message:@"Please fill in all fields before proceeding." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)registerUser{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:DEV_RLSE]];
    if([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        [request setPostValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"udid"];
    else{
        NSString *udid = nil;
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        if (uuid) {
            udid = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
            CFRelease(uuid);
        }
        [request setPostValue:udid forKey:@"udid"];
    }
    [request setPostValue:emailField.text forKey:@"email"];
    [request setPostValue:passwdField.text forKey:@"password"];
    [request setPostValue:cityField.text forKey:@"city"];
    [request setPostValue:stateField.text forKey:@"state"];
    [request setPostValue:zipField.text forKey:@"zipcode"];
    [request setPostValue:@"register_user" forKey:@"cmd"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)cancelAcct
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *jsonString = [request responseString];
    NSLog(@"%@", jsonString);
    
    if([jsonString isEqualToString:@"User exists"]){
        [[[UIAlertView alloc] initWithTitle:@"User Exists" message:@"A user with this email address already exists. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }else{
        UINavigationController *DWMC_NavBar = [self.storyboard instantiateViewControllerWithIdentifier:@"DWMC_NavController"];
        [self presentViewController:DWMC_NavBar animated:YES completion:nil];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dude Alert" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

/****************************************************************************/
/*								Social Networks                             */
/****************************************************************************/

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void)performPublishAction:(void (^)(void)) action {
    if([[FBSession activeSession] isOpen]){
        // we defer request for permission to post to the moment of post, then we check for the permission
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            // if we don't already have the permission, then we request it now
            [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
                if (!error) {
                    action();
                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled){
                    [[[UIAlertView alloc] initWithTitle:@"Permission denied" message:@"Unable to get permission to post" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        }else{
            action();
        }
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Please login before posting." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)postStatusUpdateClick:(UIButton *)sender {
    NSURL *urlToShare = [NSURL URLWithString:@"http://www.dwmcapp.com"];
    
    // If it is available, we will first try to post using the share dialog in the Facebook app
    FBAppCall *appCall = [FBDialogs presentShareDialogWithLink:urlToShare name:@"Dude Where's My Car?" caption:nil description:@"I just created an account! Never Lose Your Car Again... and much more! Download for free on the App Store!" picture:nil clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.description);
        } else {
            NSLog(@"Success!");
            
            [self setNetworkShare:@"facebook"];
        }
    }];
    
    if (!appCall) {
        // Next try to post using Facebook's iOS6 integration
        BOOL displayedNativeDialog = [FBDialogs presentOSIntegratedShareDialogModallyFrom:self initialText:nil image:nil url:urlToShare handler:nil];
        
        if (!displayedNativeDialog) {
            // Lastly, fall back on a request for permissions and a direct post using the Graph API
            [self performPublishAction:^{
                NSString *message = [NSString stringWithFormat:@"I just created an account! Never Lose Your Car Again... and much more! Download for free on the App Store!"];
                
                FBRequestConnection *connection = [[FBRequestConnection alloc] init];
                
                connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession| FBRequestConnectionErrorBehaviorAlertUser|FBRequestConnectionErrorBehaviorRetry;
                
                [connection addRequest:[FBRequest requestForPostStatusUpdate:message] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    [self showAlert:message result:result error:error];
                }];
                [connection start];
            }];
        }
    }
}

// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message result:(id)result error:(NSError *)error {
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertTitle = @"Error";
        // Since we use FBRequestConnectionErrorBehaviorAlertUser,
        // we do not need to surface our own alert view if there is an
        // an fberrorUserMessage unless the session is closed.
        if (error.fberrorUserMessage && FBSession.activeSession.isOpen) {
            alertTitle = nil;
            
        } else {
            // Otherwise, use a general "connection problem" message.
            alertMsg = @"Operation failed due to a connection problem, retry later.";
        }
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.", message];
        NSString *postId = [resultDict valueForKey:@"id"];
        if (!postId) {
            postId = [resultDict valueForKey:@"postId"];
        }
        if (postId) {
            alertMsg = [NSString stringWithFormat:@"%@\nPost ID: %@", alertMsg, postId];
        }
        alertTitle = @"Success";
    }
    
    if (alertTitle) {
        [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)setNetworkShare:(NSString *)network
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:DEV_RLSE]];
    if([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        [request setPostValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"udid"];
    else{
        NSString *udid = nil;
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        if (uuid) {
            udid = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
            CFRelease(uuid);
        }
        [request setPostValue:udid forKey:@"udid"];
    }
    if([network isEqualToString:@"facebook"])
        [request setPostValue:@"Facebook" forKey:@"network"];
    else
        [request setPostValue:@"Twitter" forKey:@"network"];
    [request setPostValue:@"add_sharing" forKey:@"cmd"];
    [request setDelegate:self];
    [request setTag:1];
    [request startAsynchronous];
}

- (IBAction)sendTweet:(id)sender
{
    if([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                if (result == SLComposeViewControllerResultCancelled)
                    NSLog(@"Cancelled");
                else{
                    NSLog(@"Done");
                    
                    [self setNetworkShare:@"twitter"];
                }
                
                [controller dismissViewControllerAnimated:YES completion:Nil];
            };
            controller.completionHandler = myBlock;
            
            [controller setInitialText:@"I just created an account on Dude Where's My Car? Free App! #DWMC"];
            [controller addURL:[NSURL URLWithString:@"www.dwmcapp.com"]];
            [controller addImage:[UIImage imageNamed:@"AppIconLarge_144.png"]];
            [self presentViewController:controller animated:YES completion:nil];
            
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }else{
        if ([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *vc = [[TWTweetComposeViewController alloc] init];
            [vc setInitialText:@"I just created an account on Dude Where's My Car? Free App! #DWMC"];
            UIImage *image = [UIImage imageNamed:@"AppIconLarge_144.png"];
            [vc addImage:image];
            NSURL *url = [NSURL URLWithString:@"http://www.dwmcapp.com"];
            [vc addURL:url];
            [vc setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                [self dismissModalViewControllerAnimated:YES];
            }];
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            NSString *message = @"The application cannot send a tweet at the moment. This is because it cannot reach Twitter or you don't have a Twitter account associated with this device.";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (IBAction)postLinkedIn:(id)sender
{
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.dwmcapp.com" clientId:@"y10xfodl0kgj" clientSecret:@"U2DK2ZoQmCKMtkUB" state:@"DCEEFWF45453sdffef424" grantedAccess:@[@"r_basicprofile", @"r_fullprofile", @"r_emailaddress", @"r_network", @"r_contactinfo", @"r_fullprofile"]];
    LIALinkedInHttpClient *client = [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
    
    [client getAuthorizationCode:^(NSString * code) {
        [client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [client getPath:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation * operation, NSDictionary *result) {
                NSLog(@"current user %@", result);
            } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
                NSLog(@"failed to fetch current user %@", error);
            }];
        } failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    } cancel:^{
        NSLog(@"Authorization was cancelled by user");
    } failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
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
    [segControl setSegmentedControlStyle:UISegmentedControlStyleBar];
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
        }
            break;
        case 1:{
            if(emailField.isEditing) [passwdField becomeFirstResponder];
            else if(passwdField.isEditing) [cityField becomeFirstResponder];
            else if(cityField.isEditing) [stateField becomeFirstResponder];
            else if(stateField.isEditing) [zipField becomeFirstResponder];
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
    }else if (textField == zipField){
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
    if(textField == zipField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 5) ? NO : YES;
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
    if (!countryPicker.hidden) {
        countryField.text = [countryCodes objectAtIndex:[countryPicker selectedRowInComponent:0]];
        [countryPicker setHidden:YES];
    }
}

@end
