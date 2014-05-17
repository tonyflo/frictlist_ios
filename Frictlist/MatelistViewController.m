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
#import "version.h"

//mmedia
#import <MillennialMedia/MMAdView.h>
#import "FrictlistAppDelegate.h"
#import "QuartzCore/QuartzCore.h"
#import "AdHelper.h"

@interface MatelistViewController ()

@end

@implementation MatelistViewController

@synthesize tableView;

//ad variables
MMAdView *banner;
float tvHeight; //height of tableview
CGFloat screenWidth; //width of screen

UIAlertView * alertView;
int curRow = -1;
int creator = -1;
BOOL canRefresh = true; //if the refresh is happening
BOOL sentFromAdd = false;
int accepted = 0; //will be 1 if removing an accepted mate, -1 if removing a rejected mate
int viewRequest = 0; //will be 1 if responding to a request, -1 if changing a rejected request


NSMutableArray *huidArray;
NSMutableArray *firstNameArray;
NSMutableArray *lastNameArray;
NSMutableArray *genderArray;
NSMutableArray *acceptedArray;
NSMutableArray *mate_uidArray;

NSMutableArray *incommingRequestIdArray;
NSMutableArray *imcommingFirstNameArray;
NSMutableArray *imcommingLastNameArray;
NSMutableArray *imcommingGenderArray;

NSMutableArray *acceptedMateIdArray; //mate id of the mate in the sender's fl
NSMutableArray *acceptedRequestIdArray;
NSMutableArray *acceptedFirstNameArray;
NSMutableArray *acceptedLastNameArray;
NSMutableArray *acceptedGenderArray;
NSMutableArray *acceptedDeletedArray;

NSMutableArray *rejectedMateIdArray; //mate id of the mate in the sender's fl
NSMutableArray *rejectedRequestIdArray;
NSMutableArray *rejectedFirstNameArray;
NSMutableArray *rejectedLastNameArray;
NSMutableArray *rejectedGenderArray;

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
    
    //ads
    //to register tableview with scrollview
    self.tableView.delegate = self;
    //set metadata
    AdHelper * ah = [[AdHelper alloc] init];
    [ah getAdMetadata];
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
            imcommingFirstNameArray = [[NSMutableArray alloc] init];
            imcommingLastNameArray = [[NSMutableArray alloc] init];
            imcommingGenderArray = [[NSMutableArray alloc] init];
            
            acceptedMateIdArray = [[NSMutableArray alloc] init];
            acceptedRequestIdArray = [[NSMutableArray alloc] init];
            acceptedFirstNameArray = [[NSMutableArray alloc] init];
            acceptedLastNameArray = [[NSMutableArray alloc] init];
            acceptedGenderArray = [[NSMutableArray alloc] init];
            acceptedDeletedArray = [[NSMutableArray alloc] init];
            
            rejectedMateIdArray = [[NSMutableArray alloc] init];
            rejectedRequestIdArray = [[NSMutableArray alloc] init];
            rejectedFirstNameArray = [[NSMutableArray alloc] init];
            rejectedLastNameArray = [[NSMutableArray alloc] init];
            rejectedGenderArray = [[NSMutableArray alloc] init];
        
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
        int accepted;
        
        //hack
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
        NSLog(@"%@", acceptedArray);
        
        //hack on a hack
        if(sentFromAdd)
        {
            accepted = 0;
        }
        else
        {
            accepted = [acceptedArray[local_hid] intValue];
        }
        
        
        NSLog(@"going to show mate detail from personal fl");
        
        MateViewController *destViewController = segue.destinationViewController;
        
        destViewController.hu_id = remote_hid;
        destViewController.accepted = accepted;
        destViewController.creator = 1; //this user is the creator
    }
    else if([segue.identifier isEqualToString:@"viewRequest"])
    {
        NSLog(@"Going to request view");
        RequestViewController *destViewController = segue.destinationViewController;
        destViewController.viewRequest = viewRequest;
        
        if(viewRequest == 1)
        {
            destViewController.request_id = [incommingRequestIdArray[[[self.tableView indexPathForSelectedRow] row]] intValue];
        }
        else if(viewRequest == -1)
        {
            destViewController.request_id = [rejectedRequestIdArray[[[self.tableView indexPathForSelectedRow] row]] intValue];
        }
        else
        {
            [self showErrorCodeDialog:-420];
        }

    }
    else if([segue.identifier isEqualToString:@"showAcceptedDetail"])
    {
        NSLog(@"Going to show mate detail from accepted fl");
        MateViewController *destViewController = segue.destinationViewController;
        
        destViewController.request_id = [acceptedRequestIdArray[[[self.tableView indexPathForSelectedRow] row]] intValue];
        destViewController.hu_id = [acceptedMateIdArray[[[self.tableView indexPathForSelectedRow] row]] intValue];
        destViewController.accepted = 1;
        destViewController.creator = 0; //this user is not the creator
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
    
    //get personal from sqlite3
    NSMutableArray * mates = [sql get_mate_list];
    huidArray = mates[0];
    firstNameArray = mates[1];
    lastNameArray = mates[2];
    genderArray = mates[3];
    acceptedArray = mates[4];
    mate_uidArray = mates[5];
    
    //get notifications from sqlite3
    NSArray * notifs = [sql get_notifications_list];
    incommingRequestIdArray = notifs[0]; //rid
    imcommingFirstNameArray = notifs[1]; //fn
    imcommingLastNameArray = notifs[2]; //ln
    imcommingGenderArray = notifs[3]; //gender
    
    //get accepted from sqlite3
    NSArray * accepts = [sql get_accepted_list];
    acceptedRequestIdArray = accepts[0]; //rid
    acceptedFirstNameArray = accepts[1]; //fn
    acceptedLastNameArray = accepts[2]; //ln
    acceptedGenderArray = accepts[3]; //gender
    acceptedMateIdArray = accepts[4]; //sender's mate id of this user
    acceptedDeletedArray = accepts[5]; // if the creator of the frictlist deleted the mate
    
    //get rejected from sqlite3
    NSArray * rejects = [sql get_rejected_list];
    rejectedRequestIdArray = rejects[0]; //rid
    rejectedFirstNameArray = rejects[1]; //fn
    rejectedLastNameArray = rejects[2]; //ln
    rejectedGenderArray = rejects[3]; //gender
    rejectedMateIdArray = rejects[4]; //sender's mate id of this user 
    
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
    
    NSLog(@"view has appeared");
    
    [self ad];
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
            viewRequest = 1;
            [self performSegueWithIdentifier:@"viewRequest" sender:indexPath];
            break;
        case 2:
            [self performSegueWithIdentifier:@"showAcceptedDetail" sender:indexPath];
            break;
        case 3:
            viewRequest = -1;
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
    return 6; //personal, pending, accepted, rejected
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
            count = acceptedRequestIdArray.count;
            break;
        case 3:
            count = rejectedRequestIdArray.count;
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
        return [NSString stringWithFormat:@"Accepted (%d)", acceptedRequestIdArray.count];
    else if (section == 3)
        return [NSString stringWithFormat:@"Rejected (%d)", rejectedRequestIdArray.count];
    else
        return @"";
}

- (UIView *)tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont systemFontOfSize:17];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [view addSubview:label];
    
    return view;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.backgroundColor = [UIColor blueColor];
    
    // if you have index/header text in your tableview change your index text color
    UITableViewHeaderFooterView *headerIndexText = (UITableViewHeaderFooterView *)view;
    [headerIndexText.textLabel setTextColor:[UIColor blackColor]];
    
}
 */

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
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MateCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = YES;
    }
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    cell.editingAccessoryType = UITableViewCellAccessoryNone;
    int count;
    switch ([indexPath section]) {
        case 0:
            //personal
            count = 0;
            if(self.editing && indexPath.row != 0)
                count = 1;
            
            if(indexPath.row == ([huidArray count]) && self.editing){
                cell.textLabel.text = @"Add a Mate";
                cell.imageView.image = [UIImage imageNamed:@"gender_.png"];
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
                    else if([acceptedArray[i] intValue] == -2)
                    {
                        //accepted then deleted
                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"request_deleted.png"]];
                    }
                    else
                    {
                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"request_sent.png"]];
                    }
                }
                else
                {
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            break;
        case 1://pending
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
                cell.accessoryView = UITableViewCellAccessoryNone;
            }
            break;
        case 2://accepted
            if(acceptedFirstNameArray.count > indexPath.row)
            {
                int i = indexPath.row;
                
                NSString *name = [NSString stringWithFormat:@"%@ %@", acceptedFirstNameArray[i], acceptedLastNameArray[i]];
                
                //set text color
                cell.textLabel.textColor = [UIColor greenColor];
                
                //set cell icon
                NSString *gender = [NSString stringWithFormat:@"gender_%d.png", [acceptedGenderArray[i] intValue]];
                cell.imageView.image = [UIImage imageNamed:gender];
                
                //set cell text
                cell.textLabel.text = name;
                cell.accessoryView = UITableViewCellAccessoryNone;
                

                //show trash icon if the creator of this frictlist deleted it
                if([acceptedDeletedArray[i] intValue] == 1)
                {
                    //creator of the frictlist deleted the mate
                    //so now there will be a trash icon next to this user in the accepted section
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"request_deleted.png"]];
                }
                else
                {
                    cell.accessoryView = UITableViewCellAccessoryNone;
                }
            }
            break;
        case 3://rejected
            if(rejectedFirstNameArray.count > indexPath.row)
            {
                int i = indexPath.row;
                
                NSString *name = [NSString stringWithFormat:@"%@ %@", rejectedFirstNameArray[i], rejectedLastNameArray[i]];
                
                //set text color
                cell.textLabel.textColor = [UIColor greenColor];
                
                //set cell icon
                NSString *gender = [NSString stringWithFormat:@"gender_%d.png", [rejectedGenderArray[i] intValue]];
                cell.imageView.image = [UIImage imageNamed:gender];
                
                //set cell text
                cell.textLabel.text = name;
                cell.accessoryView = UITableViewCellAccessoryNone;
            }
            break;
        default:
            cell.accessoryView = UITableViewCellAccessoryNone;
            break;
    }
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
        case 2:
        case 3: //todo implement and test this
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
            
        case 2:
            if (self.editing == NO || !indexPath)
                return UITableViewCellEditingStyleNone;
            
            if (self.editing && indexPath.row == ([acceptedMateIdArray count]))
                return UITableViewCellEditingStyleInsert;
            else
                return UITableViewCellEditingStyleDelete;
            break;
            
        case 3:
            if (self.editing == NO || !indexPath)
                return UITableViewCellEditingStyleNone;
            
            if (self.editing && indexPath.row == ([rejectedMateIdArray count]))
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
                creator = 1;
                [self remove_mate:mate_id];
                
            }
            else if (editingStyle == UITableViewCellEditingStyleInsert)
            {
                //go to detail view to add mate
                [huidArray insertObject:@"New mate" atIndex:[huidArray count]];
                //[tableV reloadData];;
                sentFromAdd = true;
                [self performSegueWithIdentifier:@"editMate" sender:indexPath];
                sentFromAdd = false;
            }

            break;
        case 2:
            if (editingStyle == UITableViewCellEditingStyleDelete)
            {
                [self showRemovingMateDialog];
                
                //get row
                curRow = indexPath.row;
                
                //get mate_id
                int mate_id = [[acceptedMateIdArray objectAtIndex:curRow] intValue];
                accepted = 1;
                
                //remove mate from mysql db
                creator = 0;
                [self remove_mate:mate_id];
                
            }
            break;
        case 3:
            if (editingStyle == UITableViewCellEditingStyleDelete)
            {
                [self showRemovingMateDialog];
                
                //get row
                curRow = indexPath.row;
                
                //get mate_id
                int mate_id = [[rejectedMateIdArray objectAtIndex:curRow] intValue];
                
                accepted = -1;
                
                //remove mate from mysql db
                creator = 0;
                [self remove_mate:mate_id];
                
            }
            break;
    }
}

//remove mate
-(BOOL) remove_mate:(int)mate_id
{
    BOOL rc = true;
    
    NSString * post = [NSString stringWithFormat:@"&mate_id=%d&creator=%d",mate_id, creator];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //call the remove script
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@remove_mate.php", SCRIPTS_URL]]];
    
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
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_frictlist.php", SCRIPTS_URL]]];
    
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
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_notifications.php", SCRIPTS_URL]]];
    
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
                    [sql add_frict:[frict[6] intValue] mate_id:[frict[0] intValue] from:frict[7] rating:[frict[8] intValue] base:[frict[9] intValue] notes:frict[10] mate_rating:[frict[12] intValue] mate_notes:frict[13] mate_deleted:[frict[14] intValue] creator:[frict[15] intValue] deleted:[frict[11] intValue] lat:[frict[16] doubleValue] lon:[frict[17] doubleValue]];
                }
            }
            else
            {
                //number of columns in frictlist is not correct
                [self showErrorCodeDialog:-407];
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
        
        //for each row in the notification table
        //start at 1 to skip over notification flag line
        for(int i = 1; i < query_result.count - 1; i++)
        {
            //split the row into columns
            NSArray *notification = [query_result[i] componentsSeparatedByString:@"\t"];
            
            if(notification.count == 21)
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
                        [imcommingFirstNameArray addObject:notification[3]];
                        [imcommingLastNameArray addObject:notification[4]];
                        [imcommingGenderArray addObject:notification[6]];
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
                        [sql add_accepted:[notification[0] intValue] mate_id:[notification[1] intValue] first:notification[3] last:notification[4] un:notification[5] gender:[notification[6] intValue] birthdate:notification[7] deleted:[notification[20] intValue]];
                        [acceptedRequestIdArray addObject:notification[0]];
                        [acceptedMateIdArray addObject:notification[1]];
                        [acceptedFirstNameArray addObject:notification[3]];
                        [acceptedLastNameArray addObject:notification[4]];
                        [acceptedGenderArray addObject:notification[6]];
                        [acceptedDeletedArray addObject:notification[20]];
                        NSLog(@"Deleted=====%d", [notification[20] intValue]);
                    }
                    
                    //check for frict data. make sure frict_id is not null and that the recipient hasn't already deleted this frict
                    if(notification[8] != NULL && notification[8] != nil && ![notification[8] isEqual:@""] && [notification[16] intValue] != 1)
                    {
                        NSLog(@"FOUND FRICT DATA");
                        [sql add_frict:[notification[8] intValue] mate_id:[notification[1] intValue] from:notification[9] rating:[notification[10] intValue] base:[notification[11] intValue] notes:notification[12] mate_rating:[notification[14] intValue] mate_notes:notification[15] mate_deleted:[notification[16] intValue] creator:[notification[17] intValue] deleted:[notification[13] intValue] lat:[notification[18] doubleValue] lon:[notification[19] doubleValue]];
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
                        [rejectedMateIdArray addObject:notification[1]];
                        [rejectedFirstNameArray addObject:notification[3]];
                        [rejectedLastNameArray addObject:notification[4]];
                        [rejectedGenderArray addObject:notification[6]];
                    }
                }
                else
                {
                    //status is not -1, 0, or 1
                    [self showErrorCodeDialog:-409];
                    break;
                }
                
            }
            else
            {
                //number of columns in notification is not correct
                [self showErrorCodeDialog:-408];
                break;
            }
        }
        
        //stop animating
        [self stopRefresh];
    }
    //delete mate
    else if(intResult > 0)
    {
        NSLog(@"Success");
        
        if(creator == 1)
        {
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
                [self showErrorCodeDialog:-410];
                //stop the pull down to refresh in case of error
                [self stopRefresh];
            }
        }
        else if(creator == 0)
        {
            if(curRow >= 0)
            {
                if(accepted == 1)
                {
                    NSLog(@"removing accepted!");
                    SqlHelper * sql = [SqlHelper alloc];
                    [sql remove_accepted:intResult];
                    
                    //remove mate data from local arrays
                    [acceptedRequestIdArray removeObjectAtIndex:curRow];
                    [acceptedMateIdArray removeObjectAtIndex:curRow];
                    [acceptedFirstNameArray removeObjectAtIndex:curRow];
                    [acceptedLastNameArray removeObjectAtIndex:curRow];
                    [acceptedDeletedArray removeObjectAtIndex:curRow];
                    
                    //refresh the table
                    [self updateMateList];
                    NSLog(@"done removing accepted mate");
                }
                else if(accepted == -1)
                {
                    NSLog(@"removing rejected!");
                    SqlHelper * sql = [SqlHelper alloc];
                    [sql remove_rejected:intResult];
                    
                    //remove mate data from local arrays
                    [rejectedRequestIdArray removeObjectAtIndex:curRow];
                    [rejectedMateIdArray removeObjectAtIndex:curRow];
                    [rejectedFirstNameArray removeObjectAtIndex:curRow];
                    [rejectedLastNameArray removeObjectAtIndex:curRow];
                    
                    //refresh the table
                    [self updateMateList];
                    NSLog(@"done removing rejected mate");
                }
                else
                {
                    //unknown error
                    [self showErrorCodeDialog:-419];
                    //stop the pull down to refresh in case of error
                    [self stopRefresh];
                }
                //reset accepted var
                accepted = 0;
            }
            else
            {
                //unknown error
                [self showErrorCodeDialog:-410];
                //stop the pull down to refresh in case of error
                [self stopRefresh];
            }
        }
        else
        {
            //unknown error
            [self showErrorCodeDialog:-418];
            //stop the pull down to refresh in case of error
            [self stopRefresh];
        }

    }
    //error code was returned
    else
    {
        //known error codes
        if(intResult == -40 || //removing mate may have failed
           intResult == -41 || //creator flag wasn not 0 or 1
           intResult == -100 || //id was null or not positive
           intResult == -101) //id doesn't exist or isn't unique
        {
            [self showErrorCodeDialog:intResult];
        }
        else
        {
            //unknown error
            [self showErrorCodeDialog:-411];
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

//ad stuff
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //anchor ad above tabbar
    banner.frame = CGRectMake(0, tvHeight + scrollView.contentOffset.y, screenWidth, AD_BANNER_HEIGHT);
    banner.layer.zPosition = TOP_LAYER;
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"view did disappear");
    [banner removeFromSuperview];
}

-(void)ad
{
    //Location Object
    FrictlistAppDelegate *appDelegate = (FrictlistAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //MMRequest Object
    MMRequest *request = [MMRequest requestWithLocation:appDelegate.locationManager.location];
    
    //set metadata
    AdHelper * ah = [AdHelper alloc];
    request.gender = [ah getGender];
    request.age = [ah getAge];
    
    // Replace YOUR_APID with the APID provided to you by Millennial Media
    
    CGRect tbBounds = [tableView bounds];
    tvHeight = tbBounds.size.height - AD_BANNER_HEIGHT;
    
    //CGSize tabBarSize = [[[self tabBarController] tabBar] bounds].size;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
    
    banner = [[MMAdView alloc] initWithFrame:CGRectMake(0, tvHeight + tableView.contentOffset.y, screenWidth, AD_BANNER_HEIGHT)
                                                  apid:APID_BANNER_MATELIST
                                    rootViewController:self];
    [self.view addSubview:banner];
    [banner getAdWithRequest:request onCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"BANNER AD REQUEST SUCCEEDED");
        }
        else {
            NSLog(@"BANNER AD REQUEST FAILED WITH ERROR: %@", error); }
    }];
}

@end
