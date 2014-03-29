//
//  StatisticsViewController.h
//  Frictlist
//
//  Created by Tony Flo on 12/17/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticsViewController : UIViewController
{
    IBOutlet UILabel *totalScore;
    IBOutlet UILabel *totalCount;
    IBOutlet UILabel *thirdCount;
    IBOutlet UILabel *thirdScore;
    IBOutlet UILabel *homeCount;
    IBOutlet UILabel *homeScore;
    IBOutlet UILabel *secondCount;
    IBOutlet UILabel *secondScore;
    IBOutlet UILabel *firstScore;
    IBOutlet UILabel *firstCount;
    IBOutlet UIButton *signinBtn;
    IBOutlet UILabel *emailLabel;
}
@property (strong, nonatomic) IBOutlet UIButton *emailButton;

-(IBAction)emailButtonPress;

@end
