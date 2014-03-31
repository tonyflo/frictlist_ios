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
#import "RequestViewController.h"

@interface MatelistViewController ()

@end

@implementation MatelistViewController

@synthesize tableView;

NSString * scripts_url = @"http://frictlist.flooreeda.com/scripts/";
UIAlertView * alertView;
int curRow = -1;
BOOL canRefresh = true; //if the refresh is happening
BOOL sentFromAdd = false;
NSMutableArray *huidArray;
NSMutableArray *firstNameArray;
NSMutableArray *lastNameArray;
NSMutableArray *genderArray;
NSMutableArray *acceptedArray;
NSMutableArray *mate_uidArray;

NSMutableArray *incommingRequestIdArray;
NSMutableArray *incommingStatusdArray;
NSMutableArray *imcommingFirstNameArray;
NSMutableArray *imcommingLastNameArray;
NSMutableArray *imcommingGenderArray;

NSMutableArray *acceptedUidsArray;
NSMutableArray *rejectedUidsArray;

- (void)viewDidLoad
{
    NSLog(@"view did load");
    [super viewDidLoad];
    
    self.title = @"Matelist";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(addORDeleteRows)];
    [self.navigationItem setRightBarButtonItem:addButton];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init]; refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(updateMateList) forControlEvents:UIControlEventValueChanged];
    refresh.tintColor = [UIColor colorWithRed:33.0/255.0f green:255.0/255.0f blue:0.0/255.0f alpha:1.0];
    self.refreshControl = refresh;
    [self stopRefresh];
    canRefresh = true;
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
    [tableView reloadData];
    canRefresh = true;
    NSLog(@"Done refres");
}

-(void)updateMateList
{
    NSLog(@"Update matelist");
    
    
    if(canRefresh)
    {
        canRefresh = false;
        PlistHelper * plist = [PlistHelper alloc];
        SqlHelper *sql = [SqlHelper alloc];
    
        BOOL success = [sql removeSqliteFile];
        [sql createEditableCopyOfDatabaseIfNeeded];
        if(success)
        {
            huidArray = [[NSMutableArray alloc] init];
            firstNameArray = [[NSMutableArray alloc] init];
            lastNameArray = [[NSMutableArray alloc] init];
            genderArray = [[NSMutableArray alloc] init];
            acceptedArray = [[NSMutableArray alloc] init];
            mate_uidArray = [[NSMutableArray alloc] init];
            
            incommingRequestIdArray = [[NSMutableArray alloc] init];
            incommingStatusdArray = [[NSMutableArray alloc] init];
            imcommingFirstNameArray = [[NSMutableArray alloc] init];
            imcommingLastNameArray = [[NSMutableArray alloc] init];
            imcommingGenderArray = [[NSMutableArray alloc] init];
        
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
    else if([segue.identifier isEqualToString:@"viewRequest"])
    {
        NSLog(@"Going to request view");
        RequestViewController *destViewController = segue.destinationViewController;
        
        destViewController.request_id = [incommingRequestIdArray[[[self.tableView indexPathForSelectedRow] row]] intValue];

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
    acceptedArray = mates[4];
    mate_uidArray = mates[5];
    
    //get notifications from sqlite3
    NSArray * notifs = [sql get_notifications_list];
    incommingRequestIdArray = notifs[0];
    incommingStatusdArray = notifs[1];
    imcommingFirstNameArray = notifs[2];
    imcommingLastNameArray = notifs[3];
    imcommingGenderArray = notifs[4];
    
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
            [self performSegueWithIdentifier:@"showMateDetail" sender:indexPath];
            break;
        case 1:
            [self performSegueWithIdentifier:@"viewRequest" sender:indexPath];
            break;
    }
}

- (void)addORDeleteRows
{
    if(self.editing)
    {
        NSLog(@"done");
        [super setEditing:NO animated:NO];
        [tableView setEditing:NO animated:NO];
        [tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
        //canRefresh = true; //prevent pull down to refresh
    }
    else
    {
        NSLog(@"editing");
        [super setEditing:YES animated:YES];
        [tableView setEditing:YES animated:YES];
        [tableView reloadData];
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
        //canRefresh = false; //allow pull down to refresh
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4; //personal, pending, accepted, rejected
}

//count rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    switch(section)
    {
        case 0:
            //personal matelist
            count = [huidArray count];
            if(self.editing)
            {
                count++;
            }
            break;
        case 1:
            //incomming notifications
            count = incommingRequestIdArray.count;
            break;
        case 2:
            count = acceptedUidsArray.count;
            break;
        case 3:
            count = rejectedUidsArray.count;
            break;
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return [NSString stringWithFormat:@"Personal (%d)", huidArray.count];
    else if (section == 1)
        return [NSString stringWithFormat:@"Pending (%d)", incommingRequestIdArray.count];
    else if (section == 2)
        return [NSString stringWithFormat:@"Accepted (%d)", acceptedUidsArray.count];
    else
        return [NSString stringWithFormat:@"Rejected (%d)", rejectedUidsArray.count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    
//    if(section == 0)
//    {
//        return @"Notifications";
//    }
//    else if (section == 1)
//    {
//        return @"Personal";
//    }
//    else if (section == 2)
//    {
//        return @"Accepted";
//    }
//    else
//    {
//        return @"Rejected";
//    }
//}

//code for each row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MateCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = YES;
    }
    int count;
    switch ([indexPath section]) {
        case 0:
            //personal
            count = 0;
            if(self.editing && indexPath.row != 0)
                count = 1;
            
            if(indexPath.row == ([huidArray count]) && self.editing){
                cell.textLabel.text = @"Add a Mate";
                return cell;
            }
            
            int i = indexPath.row;
            
            if(firstNameArray.count > i)
            {
                NSString *name = [NSString stringWithFormat:@"%@ %@", firstNameArray[i], lastNameArray[i]];
                
                //set text color
                cell.textLabel.textColor = [UIColor greenColor];
                
                //set cell icon
                NSString *base = [NSString stringWithFormat:@"gender_%d.png", [genderArray[i] intValue]];
                cell.imageView.image = [UIImage imageNamed:base];
                
                //set cell text
                cell.textLabel.text = name;
                
                //right image
                if(mate_uidArray[i] != NULL && ![mate_uidArray[i] isEqual: @""] && [mate_uidArray[i] intValue] != 0)
                {
                    if([acceptedArray[i] intValue] == 1)
                    {
                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"request_accepted.png"]];
                    }
                    else if([acceptedArray[i] intValue] == -1)
                    {
                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"request_rejected.png"]];
                    }
                    else
                    {
                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"request_sent.png"]];
                    }
                }
                else
                {
                    cell.accessoryView = NULL;
                }
            }
            break;
        case 1:
            //notifications
   
            if(imcommingFirstNameArray.count > indexPath.row)
            {
                int i = indexPath.row;
                
                NSString *name = [NSString stringWithFormat:@"%@ %@", imcommingFirstNameArray[i], imcommingLastNameArray[i]];
                
                //set text color
                cell.textLabel.textColor = [UIColor greenColor];
                
                //set cell icon
                NSString *gender = [NSString stringWithFormat:@"gender_%d.png", [imcommingGenderArray[i] intValue]];
                cell.imageView.image = [UIImage imageNamed:gender];
                
                //set cell text
                cell.textLabel.text = name;
                cell.accessoryView = NULL;
                            }
            break;
        default:
            break;
    }
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
            return true;
            break;
    }
    return false;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
            if (self.editing == NO || !indexPath)
                return UITableViewCellEditingStyleNone;
            
            if (self.editing && indexPath.row == ([huidArray count]))
                return UITableViewCellEditingStyleInsert;
            else
                return UITableViewCellEditingStyleDelete;
            break;
            
    }

    return UITableViewCellEditingStyleNone;
}

-(void)changeSorting
{
    
}

- (void)tableView:(UITableView *)tableV commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
            if (editingStyle == UITableViewCellEditingStyleDelete)
            {
                [self showRemovingMateDialog];
                
                //get row
                curRow = indexPath.row;
                
                //get mate_id
                int mate_id = [[huidArray objectAtIndex:curRow] intValue];
                
                //remove mate from mysql db
                [self remove_mate:mate_id];
                
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

            break;
    }
}

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
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_frictlist.php", scripts_url]]];
    
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
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_notifications.php", scripts_url]]];
    
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
    NSArray *query_result = [strResult componentsSeparatedByString:@"\n"];
    NSString *searchFlag = query_result[0];
    
    if([searchFlag isEqual:@"frictlist"])
    {
        //we have received the frictlist because the user has just signed in. now loop over it and save it to the sqlite db
        SqlHelper *sql = [SqlHelper alloc];
        
        //store the mate_ids to avoid adding the same mate more than once
        NSMutableArray *mateIds = [[NSMutableArray alloc] init];
        
        //for each row in the frictlist table
        //start at 2 to skip over frictlist line and user data array
        for(int i = 2; i < query_result.count - 1; i++)
        {
            //split the row into columns
            NSArray *frict = [query_result[i] componentsSeparatedByString:@"\t"];
            
            if(frict.count == 12)
            {
                //check if mate has already been added to sqlite
                if(![mateIds containsObject:frict[0]])
                {
                    [sql add_mate:[frict[0] intValue] fn:frict[3] ln:frict[4] gender:[frict[5] intValue] accepted:[frict[1] intValue] mates_uid:[frict[2] intValue]];
                    [mateIds addObject:frict[0]];
                    [huidArray addObject:frict[0]];
                    [firstNameArray addObject:frict[3]];
                    [lastNameArray addObject:frict[4]];
                    [genderArray addObject:frict[5]];
                    [acceptedArray addObject:frict[1]];
                    [mate_uidArray addObject:frict[2]];
                }
                
                //check for frict data
                if(frict[6] != NULL && frict[6] != nil && ![frict[6] isEqual:@""] && [frict[11] intValue] != 1)
                {
                    NSLog(@"FOUND FRICT DATA");
                    [sql add_frict:[frict[6] intValue] mate_id:[frict[0] intValue] from:frict[7] rating:[frict[8] intValue] base:[frict[9] intValue] notes:frict[10]];
                }
                
            }
        }
        
        //now, get notifications
        PlistHelper *plist = [PlistHelper alloc];
        [self get_notifications:[plist getPk]];
        
        //get user data
        //NSArray *user_data = [frictlist[1] componentsSeparatedByString:@"\t"];
        //PlistHelper *plist = [PlistHelper alloc];
        
        //set users birthday
        //NSString *bdayStr = user_data[2];
        //[plist setBirthday:bdayStr];
        //NSLog(@"user fn: %@ ln: %@ bday: %@", user_data[0], user_data[1], bdayStr);
        
        //set user's first and last name
        //[plist setFirstName:user_data[0]];
        //[plist setLastName:user_data[1]];
    }
    //notifications
    else if([searchFlag isEqual:@"notifications"])
    {
        //we have received the frictlist because the user has just signed in. now loop over it and save it to the sqlite db
        SqlHelper *sql = [SqlHelper alloc];
        
        //store the mate_ids to avoid adding the same mate more than once
        //NSMutableArray *mateIds = [[NSMutableArray alloc] init];
        
        //for each row in the notification table
        //start at 1 to skip over notification flag line
        for(int i = 1; i < query_result.count - 1; i++)
        {
            //split the row into columns
            NSArray *notification = [query_result[i] componentsSeparatedByString:@"\t"];
            
            if(notification.count == 8)
            {
                //todo fix
                //insert into sqlite
                [sql add_notification:[notification[0] intValue] mate_id:[notification[1] intValue] status:[notification[2] intValue] first:notification[3] last:notification[4] un:notification[5] gender:[notification[6] intValue] birthdate:notification[7]];
                [incommingRequestIdArray addObject:notification[0]];
                [incommingStatusdArray addObject:notification[2]];
                [imcommingFirstNameArray addObject:notification[3]];
                [imcommingLastNameArray addObject:notification[4]];
                [imcommingGenderArray addObject:notification[6]];
            }
        }
        
        //stop animating
        [self stopRefresh];

    }
    //delete mate
    else if(intResult > 0)
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
            
            //refresh the table
            [self updateMateList];
            NSLog(@"done removing mate");
        }
        else
        {
            //unknown error
            [self showUnknownFailureDialog];
            //stop the pull down to refresh in case of error
            [self stopRefresh];
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
        //stop the pull down to refresh in case of error
        [self stopRefresh];
        
    }
    NSLog(@"Result: %@", strResult);
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

//This method , you can use to receive the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopRefresh];
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
