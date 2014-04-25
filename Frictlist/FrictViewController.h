//
//  FrictViewController.h
//  Frictlist
//
//  Created by Tony Flo on 3/22/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrictViewController : UIViewController
{
    
    IBOutlet UIImageView *creatorStatusImage;
    IBOutlet UIImageView *statusImage;
    IBOutlet UILabel *nameText;
    IBOutlet UITextView *notesText;
    IBOutlet UILabel *dateRangeText;
    IBOutlet UIImageView *baseImageView;
    IBOutlet UILabel *scoreText;
    IBOutlet UILabel *ratingText;
    IBOutlet UIView *frictView;
}

@property (readwrite, assign) NSUInteger frict_id;
@property (readwrite, assign) NSUInteger mate_id;
@property (readwrite, assign) NSUInteger request_id;
@property (readwrite, assign) NSUInteger creator;
@property (readwrite, assign) NSUInteger accepted;


@end
