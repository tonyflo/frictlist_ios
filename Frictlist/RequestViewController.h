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
    

    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UIImageView *genderImage;
    IBOutlet UILabel *ageText;
    IBOutlet UILabel *nameText;
    IBOutlet UILabel *usernameText;
}

@property (readwrite, assign) NSUInteger request_id;
@property (readwrite, assign) NSUInteger viewRequest; //1 if a new request, -1 if a previously rejected request


- (IBAction)acceptPressed:(id)sender;
- (IBAction)rejectPressed:(id)sender;

@end
