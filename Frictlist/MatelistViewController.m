//
//  MatelistViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/24/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "MatelistViewController.h"
#import "MateViewController.h"
#import "PlistHelper.h"
#import "SqlHelper.h"

@interface MatelistViewController ()

@end

@implementation MatelistViewController

@synthesize tableView;

NSString * scripts_url = @"http://frictlist.flooreeda.com/scripts/";
UIAlertView * alertView;
int curRow = -1;

BOOL sentFromAdd = false;
NSMutableArray *huidArray;
NSMutableArray *firstNameArray;
NSMutableArray *lastNameArray;
NSMutableArray *genderArray;



//send data from table view to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showMateDetail"])
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
        
        NSLog(@"going to show mate detail");
        
        MateViewController *destViewController = segue.destinationViewController;
        
        destViewController.hu_id = remote_hid;
    }
    else
    {
        NSLog(@"Down her");
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    
    SqlHelper * sql = [SqlHelper alloc];
    NSMutableArray * mates = [sql get_mate_list];
    //    int count = ((NSArray *)mates[0]).count;
    //    for(int i = 0; i < count; i++)
    //    {
    //        NSLog(@"%@ %@ %@ %@", mates[0][i], mates[1][i], mates[2][i], mates[3][i]);
    //    }
    huidArray = mates[0];
    firstNameArray = mates[1];
    lastNameArray = mates[2];
    genderArray = mates[3];

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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self performSegueWithIdentifier:@"showMateDetail" sender:indexPath];
//}

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
    int count = [huidArray count];
    if(self.editing) {
        count++;
    }
    return count;
}

//code for each row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MateCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = YES;
    }
    
    int count = 0;
    if(self.editing && indexPath.row != 0)
        count = 1;
    
    if(indexPath.row == ([huidArray count]) && self.editing){
        cell.textLabel.text = @"Add a Mate";
        return cell;
    }
    
    int i = indexPath.row;
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", firstNameArray[i], lastNameArray[i]];
    
    //set text color
    cell.textLabel.textColor = [UIColor greenColor];
    
    //set cell icon
    NSString *base = [NSString stringWithFormat:@"gender_%d.png", [genderArray[i] intValue]];
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
        [self showRemovingMateDialog];
        
        //get row
        curRow = indexPath.row;
        
        //get mate_id
        int mate_id = [[huidArray objectAtIndex:curRow] intValue];
        
        //remove mate from mysql db
        [self remove_mate:mate_id];
        
        //refresh the table
        [tableV reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        //go to detail view to add mate
        [huidArray insertObject:@"New mate" atIndex:[huidArray count]];
        //[tableV reloadData];;
        sentFromAdd = true;
        [self performSegueWithIdentifier:@"showMateDetail" sender:indexPath];
        sentFromAdd = false;
    }
}

//todo
//remove mate
-(BOOL) remove_mate:(int)mate_id
{
    BOOL rc = true;
    
    NSString * post = [NSString stringWithFormat:@"&mate_id=%d",mate_id];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //call the remove script
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@remove_mate.php", scripts_url]]];
    
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

-(void)showRemovingMateDialog
{
    alertView = [[UIAlertView alloc] initWithTitle:@"Removig Mate"
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

//something went wrong, but we have an error code to report
- (void)showErrorCodeDialog:(int)errorCode
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:[NSString stringWithFormat:@"Error Code %d", errorCode]];
    [alert setMessage:[NSString stringWithFormat:@"Something went wrong. Sorry about this. Things to try:\n %C Check your internet connection\n %C Check your credentials\nIf the problem persists, email the developer and mention the %d error code.", (unichar) 0x2022, (unichar) 0x2022, errorCode]];
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
            NSLog(@"removing mate!");
            SqlHelper * sql = [SqlHelper alloc];
            [sql remove_mate:intResult];
            
            //remove mate data from local arrays
            [huidArray removeObjectAtIndex:curRow];
            [firstNameArray removeObjectAtIndex:curRow];
            [lastNameArray removeObjectAtIndex:curRow];
            
            [tableView reloadData];
            NSLog(@"done removing mate");
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
        //known error codes
        if(intResult == -40 || //removing mate may have failed
           intResult == -100 || //id was null or not positive
           intResult == -101) //id doesn't exist or isn't unique
        {
            [self showErrorCodeDialog:intResult];
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
