//
//  MateViewController.h
//  Frictlist
//
//  Created by Tony Flo on 3/24/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MateViewController : UIViewController {
    
    IBOutlet UILabel *frictScore;
    IBOutlet UILabel *frictCount;
    IBOutlet UILabel *homeCount;
    IBOutlet UILabel *homeScore;
    IBOutlet UILabel *thirdCount;
    IBOutlet UILabel *thirdScore;
    IBOutlet UILabel *secondCount;
    IBOutlet UILabel *secondScore;
    IBOutlet UILabel *firstCount;
    IBOutlet UILabel *firstScore;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *editButton;
}

@property (readwrite, assign) NSUInteger request_id; //will be null if accepted is false
@property (readwrite, assign) NSUInteger hu_id; //mate id
@property (readwrite, assign) BOOL accepted; //if this mate is from the personal fl, accepted is false, if the mate is from an incomming shared frictlist that has been accepted, accepted is true

@end
