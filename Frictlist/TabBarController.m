//
//  TabBarController.m
//  Frictlist
//
//  Created by Tony Flo on 12/23/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /*
    //tab bar titles
    [[self.parentViewController.tabBarController.tabBar.items objectAtIndex:0] setTitle:@"Fricts"];
    [[self.parentViewController.tabBarController.tabBar.items objectAtIndex:1] setTitle:@"Settings"];
    [[self.parentViewController.tabBarController.tabBar.items objectAtIndex:2] setTitle:@"Map"];
    
    //tab bar icons
    [[self.parentViewController.tabBarController.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"list_icon.png"]];
    [[self.parentViewController.tabBarController.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"gear_icon.png"]];
    [[self.parentViewController.tabBarController.tabBar.items objectAtIndex:2] setImage:[UIImage imageNamed:@"map_icon.png"]];
    */
    
    [self setSelectedIndex:1];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    //if([tabBar.selectedItem.title isEqual: @"Map"])
    //{
    //    NSLog(@"Map");
        
        /*
         UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(160, 240);
        spinner.hidesWhenStopped = YES;
        [self.view addSubview:spinner];
        [spinner startAnimating];
         */
    //}
}


@end
