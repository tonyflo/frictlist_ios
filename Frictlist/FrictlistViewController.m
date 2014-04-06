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
#import "SqlHelper.h"

@interface FrictlistViewController ()

@end

@implementation FrictlistViewController

@synthesize tableView;

NSString * scripts_url_frict = @"http://frictlist.flooreeda.com/scripts/";
UIAlertView * alertView;
int curRowFrict = -1;

BOOL sentFromAddFrict = false;
NSMutableArray *matesFrictIds;
NSMutableArray *fromArray;
NSMutableArray *baseArray;

- (void)viewDidLoad
{
    NSLog(@"view did load");
    [super viewDidLoad];
    
    self.title = @"Frictlist";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(addORDeleteRows)];
    [self.navigationItem setRightBarButtonItem:addButton];
}

//send data from table view to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showFrictDetail"])
    {
        NSIndexPath *indexPath;
        if(sentFromAddFrict)
        {
            indexPath = sender;
        }
        else
        {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        
        NSLog(@"index path row %d", indexPath.row);
        
        //todo pass frictid
        int local_frict_id = [indexPath row];
        int remote_frict = [matesFrictIds[local_frict_id] intValue];
        NSLog(@"bye from fl vc local frict %d remote frict %d", local_frict_id, remote_frict);
        
        FrictViewController *destViewController = segue.destinationViewController;
        
        destViewController.frict_id = remote_frict;
        destViewController.mate_id = self.hu_id;
        destViewController.accepted = self.accepted;
        destViewController.request_id = self.request_id;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    NSLog(@"mate id: %d", self.hu_id);
    
    matesFrictIds = [[NSMutableArray alloc] init];
    
    SqlHelper * sql = [SqlHelper alloc];
    NSArray *fl = [sql get_frict_list:self.hu_id];
    if(fl != NULL)
    {
        matesFrictIds = fl[0];
        fromArray = fl[1];
        baseArray = fl[3];
        
    }
    else
    {
        NSLog(@"null");
        matesFrictIds = NULL;
    }
    
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
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    int count = [matesFrictIds count];
    if(self.editing) {
        count++;
    }
    return count;
}

//code for each row
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FrictCell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = YES;
    }
    
    int count = 0;
    if(self.editing && indexPath.row != 0)
        count = 1;
    
    if(indexPath.row == ([matesFrictIds count]) && self.editing){
        cell.textLabel.text = @"Add a Frict";
        cell.imageView.image = [UIImage imageNamed:@"base_0.png"];
        return cell;
    }
    
    int i = indexPath.row;
    
    //display date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, YYYY"];
    NSDateFormatter *converter = [[NSDateFormatter alloc] init];
    [converter setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [formatter stringFromDate: [converter dateFromString:fromArray[i]]];
    
    //set text color
    cell.textLabel.textColor = [UIColor greenColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    
    //set cell icon
    NSString *base = [NSString stringWithFormat:@"base_%d.png", [baseArray[i] intValue] + 1];
    cell.imageView.image = [UIImage imageNamed:base];
    
    //set cell text
    cell.textLabel.text = [NSString stringWithFormat:@"%@", date];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing == NO || !indexPath)
        return UITableViewCellEditingStyleNone;
    
    if (self.editing && indexPath.row == ([matesFrictIds count]))
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
        curRowFrict = indexPath.row;
        
        //get frict_id
        int frict_id = [[matesFrictIds objectAtIndex:curRowFrict] intValue];
        
        //remove frict data from local arrays
        //[huidArray removeObjectAtIndex:curRowFrict];
        //[firstNameArray removeObjectAtIndex:curRowFrict];
        //[lastNameArray removeObjectAtIndex:curRowFrict];
        
        //remove frict from mysql db
        [self remove_frict:frict_id];
        
        //remove from local array
        [matesFrictIds removeObjectAtIndex:curRowFrict];
        [fromArray removeObjectAtIndex:curRowFrict];
        [baseArray removeObjectAtIndex:curRowFrict];
        
        //refresh the table
        [tableV reloadData];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        //go to detail view to add frict
        //todo: what is new hookup?
        [matesFrictIds insertObject:@"New Frict" atIndex:[matesFrictIds count]];
        //[tableV reloadData];;
        sentFromAddFrict = true;
        [self performSegueWithIdentifier:@"showFrictDetail" sender:indexPath];
        sentFromAddFrict = false;
    }
}

//remove frict
-(BOOL) remove_frict:(int)frict_id
{
    BOOL rc = true;
    
    NSString * post = [NSString stringWithFormat:@"&frict_id=%d", frict_id];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //call the remove script
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@remove_frict.php", scripts_url_frict]]];
    
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

//unknown failure
- (void)showUnknownFailureDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Dagnabbit!"];
    [alert setMessage:[NSString stringWithFormat:@"Something went wrong. Sorry about this. Things to try:\n %C Check your internet connection\n %C Check your credentials\nIf the problem persists, email the developer.", (unichar) 0x2022, (unichar) 0x2022]];
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
        
        if(curRowFrict >= 0)
        {
            //remove frict from sqlite
            SqlHelper * sql = [SqlHelper alloc];
            [sql remove_frict:intResult];
            NSLog(@"removed frict");
            
            [tableView reloadData];
        }
        else
        {
            //unknown error
            [self showErrorCodeDialog:-405];
        }
        
    }
    //error code was returned
    else
    {
        //known error codes
        if(intResult == -50 || //removing frict may have failed
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
