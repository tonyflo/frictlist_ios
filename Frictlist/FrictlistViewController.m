//
//  FrictlistViewController.m
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "FrictlistViewController.h"
#import "FrictDetailViewController.h" //for segue
#import "PlistHelper.h"

@interface FrictlistViewController ()

@end

@implementation FrictlistViewController

@synthesize tableView;

NSMutableArray * hookups;
BOOL sentFromAdd = false;
NSMutableArray *huidArray;
NSMutableArray *firstNameArray;
NSMutableArray *lastNameArray;

- (void)viewDidLoad
{
    NSLog(@"view did load");
    [super viewDidLoad];
    
    self.title = @"Frictlist";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(addORDeleteRows)];
    [self.navigationItem setLeftBarButtonItem:addButton];
}

////return the number of states
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSLog(@"count");
//    //return 50;
//    return [hookups count];
//}

////code for each row
//- (UITableViewCell *)tableView:(UITableView *)tableViewPtr cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *simpleTableIdentifier = @"FrictCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
//    
//    if(cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
//    }
//        
//    //cell.textLabel.text = [[hookups objectAtIndex:indexPath.row] stateName]; //default cell label
//    
//    //display check mark if user has visited state at this row
////    if([[hookups objectAtIndex:indexPath.row] stateVisited] == 1)
////    {
////        cell.imageView.image = [UIImage imageNamed:@"check.png"];
////    }
////    else
////    {
////        cell.imageView.image = [UIImage imageNamed:@"noCheck.png"];
////    }
//    
//    return cell;
//}

//send data from table view to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showFrictDetail"])
    {
        NSIndexPath *indexPath;
        if(sentFromAdd)
        {
            indexPath = sender;
        }
        else
        {
            indexPath = [self.tableView indexPathForSelectedRow];    
        }
        
        
        FrictDetailViewController *destViewController = segue.destinationViewController;

        destViewController.hu_id = [indexPath row];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    
    PlistHelper *plist = [PlistHelper alloc];
    huidArray = [plist getHuIdArray];
    firstNameArray = [plist getFirstNameArray];
    lastNameArray = [plist getLastNameArray];
    NSLog(@"huids: %@", huidArray);
    NSLog(@"firstNameArray: %@", firstNameArray);
    NSLog(@"lastNameArray: %@", lastNameArray);
    
    hookups = huidArray;
    
    
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addORDeleteRows
{
    if(self.editing)
    {
        [super setEditing:NO animated:NO];
        [tableView setEditing:NO animated:NO];
        [tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    }
    else
    {
        [super setEditing:YES animated:YES];
        [tableView setEditing:YES animated:YES];
        [tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
    }
}

//count rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [hookups count];
    if(self.editing) count++;
    return count;
}

//code for each row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FrictCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = YES;
    }
    int count = 0;
    if(self.editing && indexPath.row != 0)
        count = 1;
    
    if(indexPath.row == ([hookups count]) && self.editing){
        cell.textLabel.text = @"Add a Frict";
        return cell;
    }
    
    int i = indexPath.row;
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", firstNameArray[i], lastNameArray[i]];
    
    cell.textLabel.text = name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing == NO || !indexPath)
        return UITableViewCellEditingStyleNone;
    
    if (self.editing && indexPath.row == ([hookups count]))
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableV commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [hookups removeObjectAtIndex:indexPath.row];
        [tableV reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        //TODO: go to detail view to add frict
        [hookups insertObject:@"New hookup" atIndex:[hookups count]];
        [tableV reloadData];;
        sentFromAdd = true;
        [self performSegueWithIdentifier:@"showFrictDetail" sender:indexPath];
        sentFromAdd = false;
    }
}

@end
