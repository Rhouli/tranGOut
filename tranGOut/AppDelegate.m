//
//  AppDelegate.m
//  tranGOut
//
//  Created by Ryan on 5/22/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "colorAndFontUtility.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"PkHWAiWIaPrt5WzRb0yPrs08NDOBuXfzuzDWTHJ6"
                  clientKey:@"GheIhCcPZaXGcum5wGB9Pt7QEi9fmo9WMWs080g0"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[colorAndFontUtility textColor],
       NSFontAttributeName:[UIFont fontWithName:@"Futura" size:16]}
                                                                                            forState:UIControlStateNormal];
    
    [[UINavigationBar appearanceWhenContainedIn:[UINavigationController class], nil] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [colorAndFontUtility textColor], NSForegroundColorAttributeName,
                                                                      [UIFont fontWithName:@"Futura" size:18.0], NSFontAttributeName, nil]];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // facebook single sign on
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// facebook single sign on
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

@end
