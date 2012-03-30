//
//  GMSecondViewController.m
//  GrabMagic
//
//  Created by Aral Balkan on 30/03/2012.
//  Copyright (c) 2012 Naklab. All rights reserved.
//

#import "GMSecondViewController.h"
#import "SRWebSocket.h"
#import <MediaPlayer/MediaPlayer.h>

@interface GMSecondViewController () <SRWebSocketDelegate> {
    SRWebSocket *_webSocket;
    MPMoviePlayerController *_player;
}

@property (weak, nonatomic) IBOutlet UILabel *frameLabel;

@property (strong, nonatomic) UIImage *latestFrame;

@end


@implementation GMSecondViewController
@synthesize frameLabel;
@synthesize latestFrame;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.latestFrame = [[UIImage alloc] init];
    
    // Media player
    NSString *path = [[NSBundle mainBundle] pathForResource:@"trailer_720p" ofType:@"mov"];
    NSURL *myURL = [[NSURL alloc] initFileURLWithPath:path];
    _player =
    [[MPMoviePlayerController alloc] initWithContentURL: myURL];
    //[_player prepareToPlay];
    [_player.view setFrame: self.view.bounds];  // player's frame must match parent's
    //[self.view addSubview: _player.view];
    //[_player play];
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - SRWebSocketDelegate methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
    NSLog(@"Got message: %@", message);
    
    //NSInteger selectedTab = [message intValue];
    //_tabs.selectedIndex = selectedTab;
    
    float movieTime = [message floatValue];
    
    
    //frameLabel.text = message;
    
    self.latestFrame = [_player thumbnailImageAtTime:movieTime timeOption:MPMovieTimeOptionExact];
    
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

#pragma mark - Touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIImageView *latestFrameImageView = [[UIImageView alloc] initWithImage:self.latestFrame];
    [self.view addSubview:latestFrameImageView];
}


@end
