//
//  RequestViewController.h
//  Frictlist
//
//  Created by Tony Flo on 3/30/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestViewController : UIViewController
{
    
    IBOutlet UIButton *rejectButton;
    IBOutlet UIButton *acceptButton;
    IBOutlet UIImageView *genderImage;
    IBOutlet UILabel *ageText;
    IBOutlet UILabel *nameText;
    IBOutlet UILabel *usernameText;

}

@property (readwrite, assign) NSUInteger request_id;

- (IBAction)acceptPressed:(id)sender;
- (IBAction)rejectPressed:(id)sender;

@end
