//
//  ViewController.m
//  WKProject
//
//  Created by xiaochen on 2019/10/22.
//  Copyright © 2019 xiaochen. All rights reserved.
//

#import "ViewController.h"
#import "MISVideoPlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)touch:(id)sender {
	MISVideoPlayerViewController *player = [[MISVideoPlayerViewController alloc] init];
	player.lockHorizontal = YES;
	player.videoURL = [NSURL URLWithString:@"https://devstreaming-cdn.apple.com/videos/wwdc/2019/703yqvyjv9mi5ur6/703/hls_vod_mvp.m3u8"];
	[self presentViewController:player animated:YES completion:nil];
	
}


@end
