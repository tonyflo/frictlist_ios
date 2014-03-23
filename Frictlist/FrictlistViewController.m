//
//  FrictlistViewController.m
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "FrictlistViewController.h"
#import "FrictViewController.h" //for segue
#import "PlistHelper.h"

@interface FrictlistViewController ()

@end

@implementation FrictlistViewController

@synthesize tableView;

NSString * scripts_url = @"http://frictlist.flooreeda.com/scripts/";
UIAlertView * alertView;
int curRow = -1;

BOOL sentFromAdd = false;
NSMutableArray *huidArray;
NSMutableArray *firstNameArray;
NSMutableArray *lastNameArray;
NSMutableArray *baseArray;

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
        
        int local_hid = [indexPath row];
        int remote_hid = [huidArray[local_hid] intValue];
        
        NSLog(@"Index path %d", remote_hid);
        
        FrictViewController *destViewController = segue.destinationViewController;

        destViewController.hu_id = remote_hid;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    
    PlistHelper *plist = [PlistHelper alloc];
    huidArray = [plist getHuIdArray];
    firstNameArray = [plist getFirstNameArray];
    lastNameArray = [plist getLastNameArray];
    baseArray = [plist getBaseArray];
    NSLog(@"huids: %@", huidArray);
    NSLog(@"firstNameArray: %@", firstNameArray);
    NSLog(@"lastNameArray: %@", lastNameArray);
    
    
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
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
    NSLog(@"Counting. editing? %d. count: %d", self.editing, [huidArray count]);
    int count = [huidArray count];
    if(self.editing) {
        count++;
        NSLog(@"Actual count: %d", count);
    }
    return count;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    UIImage *pattern = [UIImage imageNamed:@"cell.png"];
//    [cell setBackgroundColor:[UIColor colorWithPatternImage:pattern]];
//}

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
    
    if(indexPath.row == ([huidArray count]) && self.editing){
        cell.textLabel.text = @"Add a Frict";
        return cell;
    }
    
    int i = indexPath.row;
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", firstNameArray[i], lastNameArray[i]];
    
    //set text color
    cell.textLabel.textColor = [UIColor greenColor];
    
    //set cell icon
    NSString *base = [NSString stringWithFormat:@"base_%d.png", [baseArray[i] intValue] + 1];
    cell.imageView.image = [UIImage imageNamed:base];
    
    //set cell text
    cell.textLabel.text = name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing == NO || !indexPath)
        return UITableViewCellEditingStyleNone;
    
    if (self.editing && indexPath.row == ([huidArray count]))
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableV commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self showRemovingFrictDialog];
        
        //remove frict from plist
        curRow = indexPath.row;
        
        //get uid
        PlistHelper *plist = [PlistHelper alloc];
        int uid = [plist getPk];
        
        //get frict_id
        int frict_id = [[huidArray objectAtIndex:curRow] intValue];
        
        //remove frict data from local arrays
        [huidArray removeObjectAtIndex:curRow];
        [firstNameArray removeObjectAtIndex:curRow];
        [lastNameArray removeObjectAtIndex:curRow];
        [baseArray removeObjectAtIndex:curRow];
        
        //remove frict from mysql db
        [self remove_frict:uid frict_id:frict_id];
        
        //refresh the table
        [tableV reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        //go to detail view to add frict
        [huidArray insertObject:@"New hookup" atIndex:[huidArray count]];
        //[tableV reloadData];;
        sentFromAdd = true;
        [self performSegueWithIdentifier:@"showFrictDetail" sender:indexPath];
        sentFromAdd = false;
    }
}

//remove frict
-(BOOL) remove_frict:(int) uid frict_id:(int)frict_id
{
    BOOL rc = true;
    
    NSString * post = [NSString stringWithFormat:@"&uid=%d&frict_id=%d",uid, frict_id];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //call the remove script
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@remove_frict.php", scripts_url]]];
    
    //Now, set HTTP method (POST or GET). Write this lines as it is in your code
    [request setHTTPMethod:@"POST"];
    
    //Set HTTP header field with length of the post data.
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    //Also set the Encoded value for HTTP header Field.
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    
    //Set the HTTPBody of the urlrequest with postData.
    [request setHTTPBody:postData];
    
    //4. Now, create URLConnection object. Initialize it with the URLRequest.
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    //It returns the initialized url connection and begins to load the data for the url request. You can check that whether you URL connection is done properly or not using just if/else statement as below.
    if(conn)
    {
        NSLog(@"Connection Successful");
    }
    else
    {
        NSLog(@"Connection could not be made");
        rc = false;
    }
    
    //5. To receive the data from the HTTP request , you can use the delegate methods provided by the URLConnection Class Reference. Delegate methods are as below
    return rc;
}

-(void)showRemovingFrictDialog
{
    alertView = [[UIAlertView alloc] initWithTitle:@"Removig Frict"
                                           message:@"\n"
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    [alertView addSubview:spinner];
    [spinner startAnimating];
    [alertView show];
}

//if sign is connection was not successful
- (void)showUnknownFailureDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Something Went Wrong"];
    [alert setMessage:[NSString stringWithFormat:@"Sorry about this. Things to try:\n %C Check your internet connection\n %C Check your credentials\nIf the problem persists, email the developer.", (unichar) 0x2022, (unichar) 0x2022]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
    
    NSArray *subViewArray = alert.subviews;
    for(int x = 0; x < [subViewArray count]; x++){
        
        //If the current subview is a UILabel...
        if([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]]) {
            UILabel *label = [subViewArray objectAtIndex:x];
            label.textAlignment = NSTextAlignmentLeft;
        }
    }
}

//Below method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)rsp
{
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:rsp encoding:NSUTF8StringEncoding];
    
    NSInteger intResult = [strResult integerValue];
    
    NSLog(@"Did receive data int: %d str %@ strlen %d", intResult, strResult, strResult.length);
    if(intResult > 0)
    {
        NSLog(@"Success");
        
        if(curRow >= 0)
        {
            //remove frict from plist
            PlistHelper *plist = [PlistHelper alloc];
            [plist removeFrict:curRow];
        }
        else
        {
            //unknown error
            [self showUnknownFailureDialog];
        }
        
    }
    //error code was returned
    else
    {
        //TODO handle errors
        if(intResult == -40)
        {
            //null data
            //[self showEmailNotFoundDialog];
        }
        else if(intResult == -41)
        {
            //uid not found
            //[self showWrongPasswordDialog];
        }
        else if(intResult == -42)
        {
            //frict_id not found
            //[self showWrongPasswordDialog];
        }
        else if(intResult == -43)
        {
            //something when wrong when deleting
            //[self showWrongPasswordDialog];
        }
        else
        {
            //unknown error
            [self showUnknownFailureDialog];
        }
        
    }
    NSLog(@"Result: %@", strResult);
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

//This method , you can use to receive the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"Did fail with error");
    NSLog(@"%@", error);
    
    //most likely a network error
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Error"];
    [alert setMessage:[error localizedDescription]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}


@end
