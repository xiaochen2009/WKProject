
/***********************************************************
 //  MISVideoManager.m
 //  Mao Kebing
 //  Created by Edu on 13-7-25.
 //  Copyright (c) 2013 Eduapp. All rights reserved.
 ***********************************************************/

#import "MISVideoManager.h"
#import "MISVideoCache.h"
#import "MISVideoDownloader.h"


@implementation MISVideoManager

/**
 *  唯一入口 共享
 *
 *  @return 单例
 */
+ (MISVideoManager *)sharedManager {
	static id instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [self new];
	});
	return instance;
}


/**
 *  获取视频
 *
 *  @param url       传入URL
 *  @param progress  进度-(只有没缓存在本地的时候)
 *  @param completed 完成回调
 */
- (void)fetchVideoWithURL:(NSURL *)url
				 progress:(MISVideoDownloaderProgressBlock)progress
				completed:(MISVideoFetchCompletedBlock)completed {
	//已经缓存
	if ([[MISVideoCache sharedCache] videoExistsForKey:url.absoluteString]) {
		NSURL* fileURL = [[MISVideoCache sharedCache] cacheFileURLForKey:url.absoluteString];
		if (completed) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completed (fileURL, nil);
			});
		}
	}else {
		//开始下载
		[[MISVideoDownloader sharedDownloader] downloadVideoWithURL:url progress:progress completed:^(NSURL *location, NSError *error) {
			
			if (location) {
				//异步写入
				[[MISVideoCache sharedCache] moveVideoFileAtURL:location
														 forKey:url.absoluteString];
				NSURL* fileURL = [[MISVideoCache sharedCache] cacheFileURLForKey:url.absoluteString];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					completed (fileURL, nil);
				});
			}else {
				//返回错误
				if (completed) {
					dispatch_async(dispatch_get_main_queue(), ^{
						completed (nil, error);
					});
				}
			}
		}];
	}
}

/**
 *  取消 task
 *
 *  @param url 传入URL
 */
- (void)cancelTaskForURL:(NSURL *)url {
	[[MISVideoDownloader sharedDownloader] cancelTaskForURL:url];
}

@end
