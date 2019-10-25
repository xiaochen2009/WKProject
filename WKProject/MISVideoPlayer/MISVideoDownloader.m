//
//  MISVideoDownloader.m
//  MyCamera
//
//  Created by Mao on 5/9/16.
//  Copyright © 2016 mao. All rights reserved.
//

#import "MISVideoDownloader.h"

static CGFloat MISVideoDownloaderTimeoutInterval  = 15.0f;

@interface MISVideoDownloaderTask : NSObject
@property (nonatomic, copy) MISVideoDownloaderProgressBlock progressBlock;   //进度回调
@property (nonatomic, copy) MISVideoDownloaderCompletedBlock completedBlock; //完成回调
@property (nonatomic, copy) NSURL* URL;                                      //URL
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;        //内部task
@end

@implementation MISVideoDownloaderTask
@end


@interface MISVideoDownloader() <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSURLSession* session; //URL会话
@property (strong, nonatomic) NSMutableSet* taskSet; //task容器
@end

@implementation MISVideoDownloader

/**
 *  共享下载器 (唯一入口)
 *
 *  @return single instance
 */
+ (MISVideoDownloader *)sharedDownloader {
	static dispatch_once_t once;
	static id instance;
	dispatch_once(&once, ^{
		instance = [self new];
	});
	return instance;
}

#pragma mark - Life Cycle

- (instancetype)init {
	if ((self = [super init])) {
		_taskSet = [NSMutableSet set];
	}
	
	return self;
}

/**
 *  创建下载operation
 *
 *  @param url            传入回调
 *  @param progressBlock  进度回调
 *  @param completedBlock 完成回调
 *
 */
- (void )downloadVideoWithURL:(NSURL *)url
						   progress:(MISVideoDownloaderProgressBlock)progressBlock
						  completed:(MISVideoDownloaderCompletedBlock)completedBlock {
	
	MISVideoDownloaderTask* task = [[MISVideoDownloaderTask alloc] init];
	task.URL                     = url;
	task.progressBlock           = progressBlock;
	task.completedBlock          = completedBlock;
	[self addTask:task];
	
	task.downloadTask = [self.session downloadTaskWithURL:url];
	[task.downloadTask resume];	
}

/**
 *  添加task
 *
 *  @param task 传入task
 */
- (void)addTask:(MISVideoDownloaderTask *)task {
	@synchronized (self.taskSet) {
		[self.taskSet addObject:task];
	}	
}

/**
 *  移除task
 *
 *  @param task 传入task
 */
- (void)removeTask:(MISVideoDownloaderTask *)task {
	if (!task)
		return;
	
	@synchronized (self.taskSet) {
		[self.taskSet removeObject:task];
	}
}


/**
 *  取消 task
 *
 *  @param url 传入URL
 */
- (void)cancelTaskForURL:(NSURL *)url {
	@synchronized (self.taskSet) {
		for (MISVideoDownloaderTask* task in self.taskSet) {
			if ([task.URL isEqual:url]) {
				[task.downloadTask cancel];
				
				[self.taskSet removeObject:task];
				break;
			}
		}
	}
}

/**
 *  查到 task
 *
 *  @param downloadTask 传入downloadTask
 */
- (MISVideoDownloaderTask *)findTaskWithDownloadTask:(NSURLSessionTask *)downloadTask {
	@synchronized (self.taskSet) {
		for (MISVideoDownloaderTask* task in self.taskSet) {
			if (task.downloadTask == downloadTask) {
				return task;
			}
		}
		
		return nil;
	}
}




#pragma - NSURLSessionTaskDelegate & NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
	MISVideoDownloaderTask* mTask = [self findTaskWithDownloadTask:task];
	if (mTask.completedBlock) {
		mTask.completedBlock(nil, error);
	}
	
	[self removeTask:mTask];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
	MISVideoDownloaderTask* task = [self findTaskWithDownloadTask:downloadTask];
	if (task.completedBlock) {
		task.completedBlock(location, nil);
	}
	
	[self removeTask:task];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
	  didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
	MISVideoDownloaderTask* task = [self findTaskWithDownloadTask:downloadTask];
	if (task.progressBlock) {
		task.progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
	}
}

#pragma mark - Getter

/**
 *  session
 *
 *  @return NSURLSession
 */
- (NSURLSession *)session {
	if (!_session) {
		NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		//no cache
		configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
		//cell network
		configuration.allowsCellularAccess = YES;
		//timeout
		configuration.timeoutIntervalForRequest = MISVideoDownloaderTimeoutInterval;
		//create session
		_session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
	}
	return _session;
}


@end
