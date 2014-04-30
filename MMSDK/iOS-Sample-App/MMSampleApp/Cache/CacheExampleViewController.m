//
//  CacheExampleViewController.m
//  MMSampleApp
//
//
//  Copyright (c) 2010-2013 Millennial Media. All rights reserved.
//

#import "CacheExampleViewController.h"
#import "AppDelegate.h"

@implementation CacheExampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Cache", @"Cache");
        self.tabBarItem.image = [UIImage imageNamed:@"TabBarIconCache.png"];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load our patterned image background (courtesy of SubtlePatterns.com)
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"broken_noise.png"]];
    
    // Notification will fire when an ad is tapped.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adWasTapped:)
                                                 name:MillennialMediaAdWasTapped
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MillennialMediaAdWasTapped
                                                  object:nil];
    
    self.statusLabel = nil; // Release our status label
}

#pragma mark - IBActions

- (IBAction)fetch:(id)sender
{
    // Request an Ad to cache
    self.statusLabel.text = NSLocalizedString(@"Fetching", @"Fetching");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MMRequest *request = [MMRequest requestWithLocation:appDelegate.locationManager.location];
    [MMInterstitial fetchWithRequest:request
                                apid:INTERSTITIAL_APID
                        onCompletion:^(BOOL success, NSError *error) {
                            if (success) {
                                self.statusLabel.text = NSLocalizedString(@"Ad available", @"Ad available");
                            }
                            else {
                                self.statusLabel.text = NSLocalizedString(@"Error", @"Error");
                            }
                        }];
}

- (IBAction)check:(id)sender
{
    // Check if a cached ad is available
    self.statusLabel.text = NSLocalizedString(@"Checking", @"Checking");
    BOOL adAvailable = [MMInterstitial isAdAvailableForApid:INTERSTITIAL_APID];
    
    if (!adAvailable) {
        self.statusLabel.text = NSLocalizedString(@"No ad available", @"No ad available");
    }
    else {
        self.statusLabel.text = NSLocalizedString(@"Ad available", @"Ad available");
    }
}

- (IBAction)display:(id)sender
{
    // Display cached ad
    self.statusLabel.text = NSLocalizedString(@"Displaying", @"Displaying");
    [MMInterstitial displayForApid:INTERSTITIAL_APID fromViewController:self withOrientation:0 onCompletion:^(BOOL success, NSError *error) {
        if (success) {
            self.statusLabel.text = NSLocalizedString(@"Interstitial displayed", @"Interstitial displayed");
        }
        else {
            NSLog(@"Error displaying interstitial: %@", error);
            self.statusLabel.text = NSLocalizedString(@"Error", @"Error");
        }
    }];
}
#pragma mark - Millennial Media Notification Methods

// All other notifications are supported for Interstitials as well
- (void)adWasTapped:(NSNotification *)notification
{
    NSLog(@"AD WAS TAPPED");
    NSLog(@"TAPPED AD IS TYPE %@", [[notification userInfo] objectForKey:MillennialMediaAdTypeKey]);
    NSLog(@"TAPPED AD APID IS %@", [[notification userInfo] objectForKey:MillennialMediaAPIDKey]);
    NSLog(@"TAPPED AD IS OBJECT %@", [[notification userInfo] objectForKey:MillennialMediaAdObjectKey]);
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
