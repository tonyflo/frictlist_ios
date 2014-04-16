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
BOOL ableToRefresh = true; //if the refresh is happening
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
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init]; refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(updateFrictlist) forControlEvents:UIControlEventValueChanged];
    refresh.tintColor = [UIColor colorWithRed:33.0/255.0f green:255.0/255.0f blue:0.0/255.0f alpha:1.0];
    self.refreshControl = refresh;
    [self stopRefresh];
    ableToRefresh = true;
}

- (void)stopRefresh
{
    [self populateTableData];
    [self.refreshControl endRefreshing];
    [tableView reloadData];
    ableToRefresh = true;
    NSLog(@"Done refres");
}

-(void)updateFrictlist
{
    NSLog(@"Update frictlist");
    
    if(ableToRefresh)
    {
        ableToRefresh = false;
        PlistHelper * plist = [PlistHelper alloc];
        SqlHelper *sql = [SqlHelper alloc];
        
        BOOL success = [sql removeSqliteFile];
        [sql createEditableCopyOfDatabaseIfNeeded];
        if(success)
        {
            [self get_frictlist:[plist getPk]];
        }
    }
    else
    {
        [self.refreshControl endRefreshing];
    }
}

//send data from table view to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue");
    if([segue.identifier isEqualToString:@"showFrictDetail"])
    {
        NSLog(@"segue to frict view");
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
        destViewController.creator = self.creator;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showFrictDetail" sender:indexPath];
}

-(void) populateTableData
{
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

}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    NSLog(@"mate id: %d", self.hu_id);
    
    [self populateTableData];
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
    
    NSString * post = [NSString stringWithFormat:@"&frict_id=%d&creator=%d", frict_id, self.creator];
    
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

//get frictlist
-(BOOL) get_frictlist:(int) uid
{
    BOOL rc = true;
    
    NSString *post = [NSString stringWithFormat:@"&uid=%d",uid];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_frictlist.php", scripts_url_frict]]];
    
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

//get notifications
-(BOOL) get_notifications:(int) uid
{
    BOOL rc = true;
    
    NSString *post = [NSString stringWithFormat:@"&uid=%d",uid];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_notifications.php", scripts_url_frict]]];
    
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
    
    NSArray *query_result = [strResult componentsSeparatedByString:@"\n"];
    NSString *searchFlag = query_result[0];
    
    if([searchFlag isEqual:@"frictlist"])
    {
        //not sure why this goes here as opposed to in the updateFrictlist function. if it's in the updateFrictlist function, I get an array out-of-bounds exception (which I don't get in the matelistviewcontroller which has a similar architecture)
//        matesFrictIds = [[NSMutableArray alloc] init];
//        fromArray = [[NSMutableArray alloc] init];
//        baseArray = [[NSMutableArray alloc] init];
        
        //we have received the frictlist because the user has just pulled down to refresh. now loop over it and save it to the sqlite db
        SqlHelper *sql = [SqlHelper alloc];
        
        //store the mate_ids to avoid adding the same mate more than once
        NSMutableArray *mateIds = [[NSMutableArray alloc] init];
        
        //for each row in the frictlist table
        //start at 2 to skip over frictlist line and user data array
        for(int i = 2; i < query_result.count - 1; i++)
        {
            //split the row into columns
            NSArray *frict = [query_result[i] componentsSeparatedByString:@"\t"];
            NSLog(@"Frict count = %d", frict.count);
            if(frict.count == 18)
            {
                //check if mate has already been added to sqlite
                if(![mateIds containsObject:frict[0]])
                {
                    [sql add_mate:[frict[0] intValue] fn:frict[3] ln:frict[4] gender:[frict[5] intValue] accepted:[frict[1] intValue] mates_uid:[frict[2] intValue]];
                    [mateIds addObject:frict[0]];
                }
                
                //check for frict data
                if(frict[6] != NULL && frict[6] != nil && ![frict[6] isEqual:@""] && [frict[11] intValue] != 1)
                {
                    NSLog(@"FOUND FRICT DATA");
                    [sql add_frict:[frict[6] intValue] mate_id:[frict[0] intValue] from:frict[7] rating:[frict[8] intValue] base:[frict[9] intValue] notes:frict[10] mate_rating:[frict[12] intValue] mate_notes:frict[13] mate_deleted:[frict[14] intValue] creator:[frict[15] intValue] deleted:[frict[11] intValue] lat:[frict[16] doubleValue] lon:[frict[17] doubleValue]];
                    
                    //if this frict is associated with the current mate_id
                    //if([frict[0] intValue] == self.hu_id)
                    //{
                        //add it to the local arrays which control what's showed in the frict table
                        //[matesFrictIds addObject:frict[6]];
                        //[fromArray addObject:frict[7]];
                        //[baseArray addObject:frict[9]];
                    //}
                }
            }
            else
            {
                //number of columns in frictlist is not correct
                [self showErrorCodeDialog:-415];
                break;
            }
        }
        
        //now, get notifications
        PlistHelper *plist = [PlistHelper alloc];
        [self get_notifications:[plist getPk]];
    }
    //notifications
    else if([searchFlag isEqual:@"notifications"])
    {
        //we have received the notification list because the user has just pulled down to refresh. now loop over it and save it to the sqlite db
        SqlHelper *sql = [SqlHelper alloc];
        
        NSMutableArray *incommingRequestIdArray = [[NSMutableArray alloc] init];
        NSMutableArray *acceptedRequestIdArray = [[NSMutableArray alloc] init];
        NSMutableArray *rejectedRequestIdArray = [[NSMutableArray alloc] init];
        
        //for each row in the notification table
        //start at 1 to skip over notification flag line
        for(int i = 1; i < query_result.count - 1; i++)
        {
            //split the row into columns
            NSArray *notification = [query_result[i] componentsSeparatedByString:@"\t"];
            
            if(notification.count == 20)
            {
                int status = [notification[2] intValue];
                //pending
                if(status == 0)
                {
                    //check if pending mate has already been added to sqlite
                    if(![incommingRequestIdArray containsObject:notification[0]])
                    {
                        NSLog(@"heres a pending: %@", notification[3]);
                        //this is a new or untouched notification that hasn't been accepted or rejected
                        [sql add_notification:[notification[0] intValue] mate_id:[notification[1] intValue] first:notification[3] last:notification[4] un:notification[5] gender:[notification[6] intValue] birthdate:notification[7]];
                        [incommingRequestIdArray addObject:notification[0]];
                    }
                }
                //accepted
                else if(status == 1)
                {
                    //check if accepted mate has already been added to sqlite
                    if(![acceptedRequestIdArray containsObject:notification[0]])
                    {
                        NSLog(@"heres a new accepted: %@", notification[3]);
                        //this is an incomming request that has already been accepted
                        [sql add_accepted:[notification[0] intValue] mate_id:[notification[1] intValue] first:notification[3] last:notification[4] un:notification[5] gender:[notification[6] intValue] birthdate:notification[7]];
                        [acceptedRequestIdArray addObject:notification[0]];
                    }
                    
                    //check for frict data. make sure frict_id is not null and that the recipient hasn't already deleted this frict
                    if(notification[8] != NULL && notification[8] != nil && ![notification[8] isEqual:@""] && [notification[16] intValue] != 1)
                    {
                        NSLog(@"FOUND FRICT DATA");
                        [sql add_frict:[notification[8] intValue] mate_id:[notification[1] intValue] from:notification[9] rating:[notification[10] intValue] base:[notification[11] intValue] notes:notification[12] mate_rating:[notification[14] intValue] mate_notes:notification[15] mate_deleted:[notification[16] intValue] creator:[notification[17] intValue] deleted:[notification[13] intValue] lat:[notification[18] doubleValue] lon:[notification[19] doubleValue]];
                        
                        //if this frict is associated with the current mate_id
                        if([notification[1] intValue] == self.hu_id)
                        {
                            //add it to the local arrays which control what's showed in the frict table
                            [matesFrictIds addObject:notification[8]];
                            [fromArray addObject:notification[9]];
                            [baseArray addObject:notification[11]];
                        }
                    }
                }
                //rejected
                else if(status == -1)
                {
                    //check if pending mate has already been added to sqlite
                    if(![rejectedRequestIdArray containsObject:notification[0]])
                    {
                        NSLog(@"heres a rejected: %@", notification[3]);
                        //this is an incomming request that has already been accepted
                        [sql add_rejected:[notification[0] intValue] mate_id:[notification[1] intValue] first:notification[3] last:notification[4] un:notification[5] gender:[notification[6] intValue] birthdate:notification[7]];
                        [rejectedRequestIdArray addObject:notification[0]];
                    }
                }
                else
                {
                    //status is not -1, 0, or 1
                    [self showErrorCodeDialog:-417];
                    break;
                }
                
            }
            else
            {
                //number of columns in notification is not correct
                [self showErrorCodeDialog:-416];
                break;
            }
        }
        
        //stop animating
        [self stopRefresh];
    }
    //remove frict
    else if(intResult > 0)
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
