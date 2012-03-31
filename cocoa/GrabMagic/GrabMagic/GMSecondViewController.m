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
#import <Twitter/Twitter.h>
#import "UIButton+Glossy.h"

@interface GMSecondViewController () <SRWebSocketDelegate> {
    SRWebSocket *_webSocket;
    MPMoviePlayerController *_player;
    
    UISwipeGestureRecognizer *_swipeRecognizer;
    UIImageView *_latestFrameImageView;
}

@property (weak, nonatomic) IBOutlet UITextField *tweetTextField;
@property (weak, nonatomic) IBOutlet UILabel *frameLabel;

@property (strong, nonatomic) UIImage *latestFrame;



@end


@implementation GMSecondViewController
@synthesize tweetTextField;
@synthesize frameLabel;
@synthesize latestFrame;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f); // scaled from 1280 x 720
    _latestFrameImageView = [[UIImageView alloc] initWithFrame:frame];
    _latestFrameImageView.contentMode = UIViewContentModeScaleAspectFill;
    //latestFrameImageView.frame = self.view.bounds;
    
    [self.view addSubview:_latestFrameImageView];

    
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
    
    // Listen for swipes
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidSwipe)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeRecognizer];
        
}

- (void)userDidSwipe
{
    NSLog(@"USER SWIPED!!!!");

    // Create the view controller
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
    // Optional: set an image, url and initial text
    [twitter addImage:self.latestFrame];
    //[twitter addURL:[NSURL URLWithString:[NSString stringWithString:@"http://iOSDeveloperTips.com/"]]];
    [twitter setInitialText:@"Just grabbed this from TV with my hand and transferred it to my phone… "];
    
    // Show the controller
    [self presentModalViewController:twitter animated:YES];
    
    // Called when the tweet dialog has been closed
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) 
    {
        
        /*
         NSString *title = @"Tweet Status";
         NSString *msg; 
         
         if (result == TWTweetComposeViewControllerResultCancelled)
         msg = @"Tweet compostion was canceled.";
         else if (result == TWTweetComposeViewControllerResultDone)
         msg = @"Tweet composition completed.";
         
         // Show alert to see how things went...
         UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
         [alertView show];
         
         // Dismiss the controller
         [self dismissModalViewControllerAnimated:YES];
         */
    };
    
}

- (void)viewDidUnload
{
    [self setFrameLabel:nil];
    [self setTweetTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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
    _latestFrameImageView.image = self.latestFrame;
}

@end
