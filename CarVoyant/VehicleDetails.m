//
//  VehicleDetails.m
//  CarVoyant
//
//  Created by Michael Holp on 11/10/13.
//  Copyright (c) 2013 Flash. All rights reserved.
//

#import "VehicleDetails.h"

@implementation VehicleDetails
@synthesize buffer, connection1, connection2, styleId, carPhoto, photoURLs, vehicleName, vehicleLbl, edmunds, maintTable;

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
    
    vehicleLbl.text = vehicleName;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.edmunds.com/v1/api/vehiclephoto/service/findphotosbystyleid?styleId=%@&fmt=json&api_key=uyvz6sp2rrtap6s5qh2jb4kj", styleId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    self.connection1 = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(self.connection1){
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.buffer = [NSMutableData data];
        [self.connection1 start];
    }else{
        NSLog(@"Connection Failed");
    }
    
    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.edmunds.com/v1/api/maintenance/actionrepository/findbymodelyearid?modelyearid=100535729&fmt=json&api_key=uyvz6sp2rrtap6s5qh2jb4kj"]];
    request = [NSMutableURLRequest requestWithURL:url];
    
    self.connection2 = [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(self.connection2){
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.buffer = [NSMutableData data];
        [self.connection2 start];
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
    static NSString *CellIdentifier = @"MaintCell";
    MaintCell *cell = (MaintCell *)[maintTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"Maintenance" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (MaintCell *)currentObject;
                break;
            }
        }
    }
    
    cell.actionLbl.text = [[edmunds objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] objectForKey:@"action"];
    cell.itemLbl.text = [[edmunds objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] objectForKey:@"item"];
    cell.mileageLbl.text = [NSString stringWithFormat:@"Mileage: %@",[[edmunds objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] objectForKey:@"intervalMileage"]];
    cell.monthLbl.text = [cell.monthLbl.text isKindOfClass:[NSNull class]] ? @"N/A" : [NSString stringWithFormat:@"Month: %@",[[edmunds objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] objectForKey:@"intervalMonth"]];
    cell.frequencyLbl.text = [NSString stringWithFormat:@"Frequency: %@",[[edmunds objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] objectForKey:@"frequency"]];
    cell.description.text = [[edmunds objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] objectForKey:@"itemDescription"];
    
    
    //cell.imageView.image = [UIImage imageNamed:@"cvimage.png"];
    //cell.textLabel.text = [[edmunds objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] objectForKey:@"item"];
    //cell.detailTextLabel.text = [[edmunds objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] objectForKey:@"engineCode"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.buffer setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection == connection1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            NSArray *res = [NSJSONSerialization JSONObjectWithData:self.buffer options:NSJSONReadingMutableLeaves error:&error];
            photoURLs = [[NSMutableDictionary alloc] init];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!error){
                    NSInteger index = 0;
                    for (NSArray *result in res) {
                        NSArray *images = [[res objectAtIndex:index] objectForKey:@"photoSrcs"];
                        [photoURLs setObject:images forKey:[NSString stringWithFormat:@"%ld",(long)index]];
                        index++;
                    }
                    
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://media.ed.edmunds-media.com%@",[[photoURLs objectForKey:[NSString stringWithFormat:@"%lu",[[photoURLs allKeys] count]-2]] objectAtIndex:4]]]];
                    [carPhoto setImage:[UIImage imageWithData:data]];
                }else
                    NSLog(@"%@",[error localizedDescription]);
            });
        });
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.buffer options:NSJSONReadingMutableLeaves error:&error];
            
            edmunds = [[NSMutableDictionary alloc] init];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!error){
                    NSArray *results = [res objectForKey:@"actionHolder"];
                    NSInteger index = 0;
                    for (NSDictionary *result in results) {
                        [edmunds setObject:result forKey:[NSString stringWithFormat:@"%ld", (long)index++]];
                    }
                    
                    NSLog(@"%@", edmunds);
                    [maintTable reloadData];
                }else
                    NSLog(@"%@",[error localizedDescription]);
            });
        });
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",[error localizedDescription]);
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

@end
