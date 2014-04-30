//
//  CacheExampleViewController.h
//  MMSampleApp
//
//
//  Copyright (c) 2010-2013 Millennial Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MillennialMedia/MMInterstitial.h>

@interface CacheExampleViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

- (IBAction)fetch:(id)sender;
- (IBAction)check:(id)sender;
- (IBAction)display:(id)sender;

@end
