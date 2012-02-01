//
//  AppDelegate.m
//  CS193P-3
//
//  Created by Ed Sibbald on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CalculatorViewController.h"
#import "GraphViewController.h"

@interface AppDelegate()
@property (readonly) BOOL iPad;
@end


@implementation AppDelegate

@synthesize window = _window;


- (BOOL)iPad
{
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

	CalculatorViewController *calcVC = [[CalculatorViewController alloc] init];
	GraphViewController *graphVC = [[GraphViewController alloc] init];

	// connect the expression receiver
	calcVC.expressionRecvVC = graphVC;

	UINavigationController *calcNavCon = [[UINavigationController alloc] init];
	[calcNavCon pushViewController:calcVC animated:NO];
	[calcVC release];
	
	if (self.iPad) {
		UINavigationController *graphNavCon = [[UINavigationController alloc] init];
		[graphNavCon pushViewController:graphVC animated:NO];

		UISplitViewController *splitVC = [[UISplitViewController alloc] init];
		splitVC.delegate = graphVC;
		splitVC.viewControllers = [NSArray arrayWithObjects:calcNavCon, graphNavCon, nil];
		[calcNavCon release];
		[graphNavCon release];
		[graphVC release];

		[self.window addSubview:splitVC.view];
	}
	else {
		[self.window addSubview:calcNavCon.view];
	}
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}


- (void)dealloc
{
	[_window release];
    [super dealloc];
}

@end
