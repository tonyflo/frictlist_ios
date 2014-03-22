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
    IBOutlet UIButton *signinBtn;
    IBOutlet UILabel *emailLabel;
}
@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;

-(IBAction)emailButtonPress;
-(IBAction)resetButtonPress;

@end
