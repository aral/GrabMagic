//
//  CCAppDelegate.m
//  ContinuousClient
//
//  Created by Aral Balkan on 28/02/2012.
//  Copyright (c) 2012 Naklab. All rights reserved.
//

#import "CCAppDelegate.h"
#import "SRWebSocket.h"

#define kSelectedTab    @"selectedTab"

@interface CCAppDelegate () <SRWebSocketDelegate> {
    UITabBarController *_tabs;
    SRWebSocket *_webSocket;
}
@end

@implementation CCAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    _tabs = (UITabBarController *)self.window.rootViewController;
    _tabs.delegate = self;
    
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    long long selectedTab = [cloudStore longLongForKey:kSelectedTab];
    _tabs.selectedIndex = selectedTab;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ubiquitousKeyValueStoreDidChangeExternally:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:cloudStore];
    
    // Create the WebSocket
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://aral.local:8080/p5websocket"]]];
    _webSocket.delegate = self;
    [_webSocket open];
    
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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - SRWebSocketDelegate methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
    NSLog(@"Got message: %@", message);
    
    //NSInteger selectedTab = [message intValue];
    //_tabs.selectedIndex = selectedTab;
    
}
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Socket open.");
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Socket failed: %@", [error localizedDescription]);
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"Socket closed because %@", reason);
}

#pragma mark - Notification handlers

- (void)ubiquitousKeyValueStoreDidChangeExternally:(NSNotification *)notification
{
    NSUbiquitousKeyValueStore *store = notification.object;
    long long selectedTab = [store longLongForKey:kSelectedTab];
    _tabs.selectedIndex = selectedTab;
}

#pragma mark - UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    // Save the current tab
    long long selectedTab = [tabBarController selectedIndex];
    NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
    [cloudStore setLongLong:selectedTab forKey:kSelectedTab];
    [cloudStore synchronize];
    
    [_webSocket send:[NSString stringWithFormat:@"%lld", selectedTab]];
    
}


@end
