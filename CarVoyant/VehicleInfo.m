//
//  VehicleInfo.m
//  CarVoyant
//
//  Created by Michael Holp on 11/9/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import "VehicleInfo.h"

@implementation VehicleInfo
@synthesize connection, buffer, vehicleName, vehicleId, edmunds, photoURLs, infoTable;

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
	
    NSArray *array = [vehicleName componentsSeparatedByString:@" "];
    NSString *year = [array objectAtIndex:0];
    NSString *make = [array objectAtIndex:1];
    NSString *model = [array objectAtIndex:2];
    
    self.title = [vehicleName substringFromIndex:5];
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"https://api.edmunds.com/api/vehicle/v2/%@/%@/%@?fmt=json&api_key=uyvz6sp2rrtap6s5qh2jb4kj", make, model, year]];
    NSLog(@"%@", url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(self.connection){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.buffer = [NSMutableData data];
        [self.connection start];
    }else{
        NSLog(@"Connection Failed");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[edmunds allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"cvimage.png"];
    cell.textLabel.text = [[edmunds objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] objectForKey:@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VehicleDetails *details = [self.storyboard instantiateViewControllerWithIdentifier:@"VehicleDetails"];
    details.title = [vehicleName substringFromIndex:5];
    details.vehicleName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    details.styleId = [[edmunds objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] objectForKey:@"id"];
    [self.navigationController pushViewController:details animated:YES];
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
        
        edmunds = [[NSMutableDictionary alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error){
                NSArray *results = [res objectForKey:@"styles"];
                NSInteger index = 0;
                for (NSDictionary *result in results) {
                    [edmunds setObject:result forKey:[NSString stringWithFormat:@"%d", index++]];
                }
                
                NSLog(@"%@", edmunds);
                [infoTable reloadData];
            }else
                NSLog(@"%@",[error localizedDescription]);
        });
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",[error localizedDescription]);
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

@end
