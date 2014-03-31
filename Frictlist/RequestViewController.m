//
//  RequestViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/30/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "RequestViewController.h"
#import "SqlHelper.h"

@interface RequestViewController ()

@end

@implementation RequestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    SqlHelper *sql = [SqlHelper alloc];
    
    NSMutableArray * requst = [sql get_notification:self.request_id];
    
    int status = [requst[0] intValue];
    NSString *fn = requst[1];
    NSString *ln = requst[2];
    NSString *un = requst[3];
    int gender = [requst[4] intValue];
    NSString *bday = requst[5];
    
    nameText.text = [NSString stringWithFormat:@"%@ %@", fn, ln];
    usernameText.text = un;
    
    // gender
    NSString *genderStr = [NSString stringWithFormat:@"gender_%d.png", gender];
    genderImage.image = [UIImage imageNamed:genderStr];
    
    //age
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * birthday = [formatter dateFromString:bday];
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    ageText.text = [NSString stringWithFormat:@"%d", age];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"request id %d", self.request_id);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
