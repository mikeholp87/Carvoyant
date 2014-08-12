//
//  ViewController.m
//  CarVoyant
//
//  Created by Michael Holp on 11/8/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize buffer, connection, searchDisplayController, searchResults, vehicles, vehicleTable, webView, closeBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(75, 0, 98, 40)];
    UIButton *logo = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, 98, 40)];
    [logo setImage:[UIImage imageNamed:@"Canary.png"] forState:UIControlStateNormal];
    [logo addTarget:self action:@selector(displayWWW) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoView];
    [logoView addSubview:logo];
    self.navigationItem.titleView = logoView;
    
    [self reachabilityCheck];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.carvoyant.com/v1/api/vehicle/"]];
    NSString *authHeader = [NSString stringWithFormat:@"Bearer 2jnmuezrt62y8sg2bpfndeq2"];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(self.connection){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.buffer = [NSMutableData data];
        [self.connection start];
    }else{
        NSLog(@"Connection Failed");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == searchDisplayController.searchResultsTableView)
        return [searchResults count];
    else
        return [[vehicles allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == searchDisplayController.searchResultsTableView)
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
    else{
        cell.imageView.image = [UIImage imageNamed:@"cvimage.png"];
        cell.textLabel.text = [[vehicles objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] objectForKey:@"name"];
        cell.detailTextLabel.text = [[vehicles objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] objectForKey:@"vin"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TripRouteMap *trips = [self.storyboard instantiateViewControllerWithIdentifier:@"TripRouteMap"];
    trips.deviceId = [[vehicles objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] objectForKey:@"deviceId"];
    [self.navigationController pushViewController:trips animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    VehicleDiagnostics *diag = [self.storyboard instantiateViewControllerWithIdentifier:@"VehicleDiagnostics"];
    diag.vehicleName = [[vehicles objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] objectForKey:@"name"];
    diag.vehicleId = [[vehicles objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] objectForKey:@"vehicleId"];
    [self.navigationController pushViewController:diag animated:YES];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.buffer setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.buffer options:NSJSONReadingMutableLeaves error:&error];
        
        vehicles = [[NSMutableDictionary alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error){
                NSArray *results = [res objectForKey:@"vehicle"];
                NSInteger index = 0;
                for (NSDictionary *result in results) {
                    [vehicles setObject:result forKey:[NSString stringWithFormat:@"%ld", (long)index++]];
                    NSLog(@"%@", vehicles);
                }
            }else
                NSLog(@"%@",[error localizedDescription]);
            [vehicleTable reloadData];
        });
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.connection = nil;
    self.buffer = nil;
    
    NSLog(@"%@",[error localizedDescription]);
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)displayWWW {
    self.navigationController.navigationBarHidden = YES;
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.carvoyant.com"]];
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    webView.delegate = self;
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(280, 5, 36, 36)];
    [closeBtn setImage:[UIImage imageNamed:@"close_button.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    
    webView.scalesPageToFit = YES;
    [webView loadRequest:requestObj];
    [vehicleTable addSubview:closeBtn];
    [vehicleTable addSubview:webView];
    [vehicleTable bringSubviewToFront:closeBtn];
}

- (void)closeView {
    self.navigationController.navigationBarHidden = NO;
    closeBtn.hidden = YES;
    webView.hidden = YES;
}

-(void)reachabilityCheck {
    Reachability *wifiReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    switch (netStatus){
        case NotReachable:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wi-fi unreachable" message:@"Internet access is not available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert setTag:2];
            [alert show];
            NSLog(@"Access Not Available");
            break;
        }
        case ReachableViaWWAN:{
            NSLog(@"Reachable WWAN");
            break;
        }
        case ReachableViaWiFi:{
            NSLog(@"Reachable WiFi");
            break;
        }
    }
}

@end
