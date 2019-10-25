
/***********************************************************
 //  MISVideoManager.h
 //  Mao Kebing
 //  Created by Edu on 13-7-25.
 //  Copyright (c) 2013 Eduapp. All rights reserved.
 ***********************************************************/

#import <Foundation/Foundation.h>
#import "MISVideoDownloader.h"

/**
 *  获取完成的回调
 *
 *  @param fileURL 回调文件目录
 *  @param error   error
 */
typedef void(^MISVideoFetchCompletedBlock)(NSURL* fileURL, NSError *error);


@interface MISVideoManager : NSObject


/**
 *  唯一入口 共享
 *
 *  @return 单例
 */
+ (MISVideoManager *)sharedManager;


/**
 *  获取视频
 *
 *  @param url       传入URL
 *  @param progress  进度-(只有没缓存在本地的时候)
 *  @param completed 完成回调
 */
- (void)fetchVideoWithURL:(NSURL *)url
				 progress:(MISVideoDownloaderProgressBlock)progress
				completed:(MISVideoFetchCompletedBlock)completed;

/**
 *  取消 task
 *
 *  @param url 传入URL
 */
- (void)cancelTaskForURL:(NSURL *)url;

@end
