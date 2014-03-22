//
//  FrictlistViewController.m
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "FrictlistViewController.h"
#import "FrictDetailViewController.h" //for segue
#import "Frict.h"
#import "PlistHelper.h"

@interface FrictlistViewController ()

@end

@implementation FrictlistViewController

@synthesize tableView;

NSString * stateName[50] =
{
                       @"Alabama",
                       @"Alaska",
                       @"Arizona",
                       @"Arkansas",
                       @"California",
                       @"Colorado",
                       @"Connecticut",
                       @"Delaware",
                       @"Florida",
                       @"Georgia",
                       @"Hawaii",
                       @"Idaho",
                       @"Illinois",
                       @"Indiana",
                       @"Iowa",
                       @"Kansas",
                       @"Kentucky",
                       @"Louisiana",
                       @"Maine",
                       @"Maryland",
                       @"Massachusetts",
                       @"Michigan",
                       @"Minnesota",
                       @"Mississippi",
                       @"Missouri",
                       @"Montana",
                       @"Nebraska",
                       @"Nevada",
                       @"New Hampshire",
                       @"New Jersey",
                       @"New Mexico",
                       @"New York",
                       @"North Carolina",
                       @"North Dakota",
                       @"Ohio",
                       @"Oklahoma",
                       @"Oregon",
                       @"Pennsylvania",
                       @"Rhode Island",
                       @"South Carolina",
                       @"South Dakota",
                       @"Tennessee",
                       @"Texas",
                       @"Utah",
                       @"Vermont",
                       @"Virginia",
                       @"Washington",
                       @"West Virginia",
                       @"Wisconsin",
                       @"Wyoming"
};

NSMutableArray * states;

- (void)viewDidLoad
{
    NSLog(@"view did load");
    [super viewDidLoad];
}

-(void)populateFrictArray
{
    states = [[NSMutableArray alloc] initWithCapacity:50];
    PlistHelper *plist = [PlistHelper alloc];
    NSString *ivisited = [plist getIvisited];
    for(int i = 0; i < 50; i++)
    {
        char v_c = [ivisited characterAtIndex:i];
        int v_i = v_c == '0' ? 0 : 1;
        Frict *st = [[Frict alloc] initWithName:stateName[i] AndVisited:v_i AndIndex:i];
        [states addObject:st];
        //NSLog(@"%d, %@, %d", st.primaryKey, st.stateName, st.stateVisited);
    }
    NSLog(@"Frict count: %d", [states count]);
}

//return the number of states
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count");
    //return 50;
    return [states count];
}

//code for each row
- (UITableViewCell *)tableView:(UITableView *)tableViewPtr cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"FrictCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
        
    cell.textLabel.text = [[states objectAtIndex:indexPath.row] stateName]; //default cell label
    
    //display check mark if user has visited state at this row
    if([[states objectAtIndex:indexPath.row] stateVisited] == 1)
    {
        cell.imageView.image = [UIImage imageNamed:@"check.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"noCheck.png"];
    }
    
    return cell;
}

//send data from table view to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showFrictDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FrictDetailViewController *destViewController = segue.destinationViewController;

        Frict *state = [[Frict alloc] init];
        destViewController.state = [state initWithName:[[states objectAtIndex:indexPath.row] stateName] AndVisited:[[states objectAtIndex:indexPath.row] stateVisited] AndIndex:[indexPath row]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    // loop to populate state array
    [self populateFrictArray];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
