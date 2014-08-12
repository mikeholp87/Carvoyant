//
//  ViewController.m
//  CarVoyant
//
//  Created by Michael Holp on 11/8/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize buffer, connection, spinner, searchDisplayController, searchResults, vehicles, vehicleTable;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reachabilityCheck];
	
    [self.spinner startAnimating];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@:%@@dash.carvoyant.com/api/vehicle/", @"https://7c8ede30-36b3-428d-9da4-24f348fbed5d", @"f81c8cb4-c380-445c-9db4-bb1236c3ee2b"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(self.connection){
        self.buffer = [NSMutableData data];
        [self.connection start];
    }else{
        NSLog(@"Connection Failed");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == searchDisplayController.searchResultsTableView)
        return [searchResults count];
    else
        return [[vehicles  allKeys] count];
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
        cell.imageView.image = [UIImage imageNamed:@"cellimage.jpg"];
        cell.textLabel.text = [[vehicles objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ miles", [[vehicles objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] objectForKey:@"mileage"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CarvoyantMap *map = [self.storyboard instantiateViewControllerWithIdentifier:@"CarvoyantMap"];
    
    NSDictionary *lastWaypoint = [[vehicles objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] objectForKey:@"lastWaypoint"];
    
    map.latitude = [lastWaypoint objectForKey:@"latitude"];
    map.longitude = [lastWaypoint objectForKey:@"longitude"];
    map.timestamp = [lastWaypoint objectForKey:@"timestamp"];
    
    [self.navigationController pushViewController:map animated:YES];
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
            if (!error){
                NSArray *results = [res objectForKey:@"vehicle"];
                NSInteger index = 0;
                for (NSDictionary *result in results) {
                    [vehicles setObject:result forKey:[NSString stringWithFormat:@"%d", index]];
                    index++;
                }
            }else
                NSLog(@"%@",[error localizedDescription]);
            
            [self.spinner stopAnimating];
            [self.spinner setHidden:YES];
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
