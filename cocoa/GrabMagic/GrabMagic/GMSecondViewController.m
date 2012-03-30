//
//  GMSecondViewController.m
//  GrabMagic
//
//  Created by Aral Balkan on 30/03/2012.
//  Copyright (c) 2012 Naklab. All rights reserved.
//

#import "GMSecondViewController.h"
#import "SRWebSocket.h"

@interface GMSecondViewController () <SRWebSocketDelegate> {
    SRWebSocket *_webSocket;
}

@property (weak, nonatomic) IBOutlet UILabel *frameLabel;

@end


@implementation GMSecondViewController
@synthesize frameLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Create the WebSocket
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://aral.local:8080/p5websocket"]]];
    _webSocket.delegate = self;
    [_webSocket open];
}

- (void)viewDidUnload
{
    [self setFrameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - SRWebSocketDelegate methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
    NSLog(@"Got message: %@", message);
    
    //NSInteger selectedTab = [message intValue];
    //_tabs.selectedIndex = selectedTab;
    
    frameLabel.text = message;
    
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



@end
