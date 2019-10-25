
/***********************************************************
 //  MISVideoPlayerViewController.m
 //  Mao Kebing
 //  Created by Edu on 13-7-25.
 //  Copyright (c) 2013 Eduapp. All rights reserved.
 ***********************************************************/

#import "MISVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>


#pragma mark - MISVideoPlayerControlView

@interface MISVideoPlayerControlView : UIView

/**
 *  当前播发时间
 */
@property (nonatomic) NSTimeInterval currentPlaybackTime;

/**
 *  总时间
 */
@property (nonatomic) NSTimeInterval totalPlaybackTime;


/**
 *  已缓充时间
 */
@property (nonatomic) NSTimeInterval currentBufferTime;

/**
 *  控制播放显示
 */
@property (nonatomic) BOOL isPlaying;


/**
 *  进度将要变化时
 */
@property (nonatomic, copy) void(^sliderValueWillChangeBlock)(void);


/**
 *  进度变化时
 */
@property (nonatomic, copy) void(^sliderValueChangingBlock)(NSTimeInterval playTime);


/**
 *  进度变化完成时
 */
@property (nonatomic, copy) void(^sliderValueDidChangedBlock)(void);


/**
 *  播放控制回调
 */
@property (nonatomic, copy) void(^playBlock)(void);

@end

static CGFloat MISVideoPlayerControlViewLableWidth = 60.0f;
static CGFloat MISVideoPlayerControlViewLableFontSize = 13.0f;
static CGFloat MISVideoPlayerControlViewHeight = 44.0f;
static CGFloat MISVideoPlayerControlViewLRIndent = 10.0f;


@interface MISVideoPlayerControlView()
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel  *startLabel;
@property (nonatomic, strong) UILabel  *endLabel;
@end

@implementation MISVideoPlayerControlView

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
		[self addSubview:self.playBtn];
		[self addSubview:self.startLabel];
		[self addSubview:self.progressView];
		[self addSubview:self.slider];
		[self addSubview:self.endLabel];
	}
	return self;
}


- (void)layoutSubviews{
	[super layoutSubviews];
	
    self.playBtn.frame       = CGRectMake(MISVideoPlayerControlViewLRIndent, 0, MISVideoPlayerControlViewHeight, MISVideoPlayerControlViewHeight);
    self.startLabel.frame    = CGRectMake(CGRectGetMaxX(self.playBtn.frame), 0, MISVideoPlayerControlViewLableWidth, MISVideoPlayerControlViewHeight);
    self.endLabel.frame      = CGRectMake(CGRectGetWidth(self.frame) - MISVideoPlayerControlViewLableWidth, 0, MISVideoPlayerControlViewLableWidth, MISVideoPlayerControlViewHeight);
    CGFloat xPoint           = CGRectGetMaxX(self.startLabel.frame) + MISVideoPlayerControlViewLRIndent;
    CGFloat width            = CGRectGetMinX(self.endLabel.frame) - xPoint - MISVideoPlayerControlViewLRIndent * 2;
    self.slider.frame        = CGRectMake(xPoint, 0, width, MISVideoPlayerControlViewHeight);
    self.progressView.frame  = CGRectMake(xPoint + 3.0, 0, width - 6.0f, MISVideoPlayerControlViewHeight);
	self.progressView.center = self.slider.center;
}

#pragma mark - Private Methods

/**
 *  更新时间标签
 *
 *  @param currentTime 当前时间
 */
- (void)updateTimeLabelInfoWithCurrentTime:(NSTimeInterval)currentTime {
	self.startLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int) currentTime / 60, (int )currentTime % 60];
	self.endLabel.text   = [NSString stringWithFormat:@"%02d:%02d", (int) (self.totalPlaybackTime - currentTime) / 60, (int )(self.totalPlaybackTime - currentTime) % 60];
}

#pragma mark - Getter & Setter

- (UIButton *)playBtn {
	if (!_playBtn) {
		_playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[_playBtn setImage:[UIImage imageNamed:@"MISVideoPlayer.bundle/MISVideoPlayBtn"] forState:UIControlStateNormal];
		[_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _playBtn;
}

- (UILabel *)startLabel {
	if (!_startLabel) {
		_startLabel = [[UILabel alloc] init];
		_startLabel.font = [UIFont systemFontOfSize:MISVideoPlayerControlViewLableFontSize];
		_startLabel.textColor = [UIColor whiteColor];
		_startLabel.textAlignment = NSTextAlignmentRight;
	}
	return _startLabel;
}

- (UILabel *)endLabel {
	if (!_endLabel) {
		_endLabel = [[UILabel alloc] init];
		_endLabel.font = [UIFont systemFontOfSize:MISVideoPlayerControlViewLableFontSize];
		_endLabel.textColor = [UIColor whiteColor];
		_endLabel.textAlignment = NSTextAlignmentLeft;
	}
	return _endLabel;
}

- (UISlider *)slider {
	if (!_slider) {
		_slider = [[UISlider alloc] init];
		_slider.minimumTrackTintColor = [UIColor redColor]; //253,111,72
		_slider.maximumTrackTintColor = [UIColor clearColor];
		[_slider setThumbImage:[UIImage imageNamed:@"MISVideoPlayer.bundle/MISVideoProgressBtn"] forState:UIControlStateNormal];
		[_slider addTarget:self action:@selector(progressValueChanged:) forControlEvents:UIControlEventValueChanged];
		[_slider addTarget:self action:@selector(progressEndChanged:) forControlEvents:UIControlEventTouchUpInside];
		[_slider addTarget:self action:@selector(progressWillChange:) forControlEvents:UIControlEventTouchDown];
	}
	return _slider;
}

- (UIProgressView *)progressView {
	if (!_progressView) {
		_progressView = [[UIProgressView alloc] init];
		_progressView.trackTintColor = [UIColor whiteColor];
		_progressView.progressTintColor = [UIColor grayColor];
	}
	return _progressView;
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
	_currentPlaybackTime = currentPlaybackTime;
	
	//更新时间
	[self updateTimeLabelInfoWithCurrentTime:currentPlaybackTime];
	
	//更新进度条
	self.slider.value = currentPlaybackTime;
}

- (void)setTotalPlaybackTime:(NSTimeInterval)totalPlaybackTime {
	_totalPlaybackTime = totalPlaybackTime;
	
	self.slider.value = 0;
	self.slider.maximumValue = totalPlaybackTime;
}

- (void)setCurrentBufferTime:(NSTimeInterval)currentBufferTime {
	_currentBufferTime = currentBufferTime;
	if (self.totalPlaybackTime) {
		self.progressView.progress = currentBufferTime / self.totalPlaybackTime;
	}
}

- (void)setIsPlaying:(BOOL)isPlaying {
	_isPlaying = isPlaying;
	
	if (_isPlaying) {
		[self.playBtn setImage:[UIImage imageNamed:@"MISVideoPlayer.bundle/MISVideoPauseBtn"] forState:UIControlStateNormal];
	}else {
		[self.playBtn setImage:[UIImage imageNamed:@"MISVideoPlayer.bundle/MISVideoPlayBtn"] forState:UIControlStateNormal];
	}
}



#pragma mark - Event

- (void)progressEndChanged:(UISlider *)slider {
	if (self.sliderValueDidChangedBlock) {
		self.sliderValueDidChangedBlock();
	}
}

- (void)progressValueChanged:(UISlider *)slider {
	if (self.sliderValueChangingBlock) {
		self.sliderValueChangingBlock(slider.value);
	}
	
	/**
	 *  更新时间标签
	 */
	[self updateTimeLabelInfoWithCurrentTime:slider.value];
}

- (void)progressWillChange:(UISlider *)slider {
	if (self.sliderValueWillChangeBlock) {
		self.sliderValueWillChangeBlock();
	}
}

- (void)play:(UIButton *)btn {
	if (self.playBlock) {
		self.playBlock();
	}
}

@end


#pragma mark - MISVideoPlayerViewController

typedef enum : NSUInteger {
	MISPlayVideoPlayStatePrepare,
	MISPlayVideoPlayStatePlaying,
	MISPlayVideoPlayStatePause,
	MISPlayVideoPlayStateEnd,
} MISPlayVideoPlayState;


@interface MISVideoPlayerViewController()

@property (nonatomic, strong) AVPlayer *player;                       //播放器
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@property (nonatomic) NSUInteger playState;
@property (nonatomic, strong) dispatch_source_t timerSource;          //刷新timer

@property (nonatomic, strong) UIView *contentView;                    //容器view
@property (nonatomic, strong) UIView *tapView;                        //手势view
@property (nonatomic, strong) MISVideoPlayerControlView *controlView; //控件view
@property (nonatomic, strong) UIView *headerView;                     //顶栏
@property (nonatomic, strong) NSTimer *hideTimer;                     //渐隐timer
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;   //loading
@property (nonatomic) BOOL isBarsHiden;                               //上下栏是否已隐藏

@end

@implementation MISVideoPlayerViewController

#pragma mark - Life

- (instancetype)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didPlayToEndTimeNotification:)
													 name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
		
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(orientationdidChangeNotification:)
													 name:UIDeviceOrientationDidChangeNotification object:nil];
		_isBarsHiden = YES;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//背景黑色
	self.view.backgroundColor = [UIColor blackColor];
	
	//设定位置
	[self resetFrames];
	
	//准备UI
	[self.view addSubview:self.contentView];
	
	//指示器
	[self.view addSubview:self.loadingView];
	
	//加载视频
	[self loadVideo];
}

#pragma mark - Notifications

- (void)didPlayToEndTimeNotification:(NSNotification *)notification {
	[self endPlay];
}

- (void)orientationdidChangeNotification:(NSNotification *)notification  {
	if (self.lockHorizontal) {
		return;
	}
	
	//这几种不处理
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationFaceUp
		|| orientation == UIDeviceOrientationFaceDown
		|| orientation == UIDeviceOrientationUnknown) {
		return;
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		[self resetFrames];
	}];
}


/**
 *  控制隐藏timer
 */
- (void)stopHideTimer {
	if ([_hideTimer isValid]) {
		[_hideTimer invalidate];
		_hideTimer = nil;
	}
}

/**
 *  控制隐藏timer
 */
- (void)startHideTimer {
	_hideTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onHideBars) userInfo:nil repeats:NO];
}

/**
 *  更新时间信息
 */
- (void)updatePlayInfo {
	if (self.playerItem.duration.timescale) {
		self.controlView.totalPlaybackTime = self.playerItem.duration.value / self.playerItem.duration.timescale;
		self.controlView.currentPlaybackTime = self.player.currentTime.value / self.player.currentTime.timescale;
	}
}

/**
 *  触发渐隐
 */
- (void)toggleBarsHidenOrNot {
	[self stopHideTimer];
	
	_isBarsHiden = !_isBarsHiden;
	
	CGFloat alpha = _isBarsHiden ? 0.0f : 1.0f;
	
	[UIView animateWithDuration:0.25f animations:^{
		self.headerView.alpha = alpha;
		self.controlView.alpha = alpha;
	} completion:^(BOOL finished) {
		if (!_isBarsHiden) {
			[self startHideTimer];
		}
	}];
}

/**
 *  自动引藏
 */
- (void)onHideBars {
	if (_isBarsHiden) {
		return;
	}
	
	[self stopHideTimer];

	[UIView animateWithDuration:0.25f animations:^{
		self.headerView.alpha = 0;
		self.controlView.alpha = 0;
	} completion:^(BOOL finished) {
		_isBarsHiden = YES;
	}];
}

/**
 *  设定当前的播放时间
 *
 *  @param playTime 时间
 */
- (void)setCurrentPlaybackTime:(NSTimeInterval )playTime {
	[self stopTimer];
	
	[self.player seekToTime:CMTimeMake(playTime, 1)];
}

/**
 *  退出
 */
- (void)exit {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	//KVO
	[self removeKVO];
	
	//取消timer
	[self stopHideTimer];
	[self stopTimer];
	
	//停止
	[self stopPlay];
	
	//返回
	[self dismissViewControllerAnimated:NO completion:nil];
}


/**
 *  加载播放
 */
- (void)loadVideo {
	[self addKVO];
	
	[self.loadingView startAnimating];

	//显示操作栏-能播放的情况下
	self.controlView.hidden = NO;
	
	//显示上下栏
	[self toggleBarsHidenOrNot];
}

- (AVPlayerLayer *)playerLayer {
	if (!_playerLayer) {
		_playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
		_playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
	}
	return _playerLayer;
}


/**
 *  控制播放
 */
- (void)togglePlayOrPause {
	if (self.playState == MISPlayVideoPlayStatePrepare) {
		return;
	}
	
	if (self.playState == MISPlayVideoPlayStateEnd) {
		[self.player seekToTime:CMTimeMake(0, 1)];
		[self startPlay];
		return;
	}
	
	if (self.playState == MISPlayVideoPlayStatePlaying) {
		[self pausePlay];
		return;
	}
	
	if (self.playState == MISPlayVideoPlayStatePause) {
		[self startPlay];
		return;
	}
}

/**
 *  开始播放
 */
- (void)startPlay {
	[self.player play];
	[self startTimer];
	
	self.playState = MISPlayVideoPlayStatePlaying;
	self.controlView.isPlaying = YES;
}

/**
 *  暂停播放
 */
- (void)pausePlay {
	[self.player pause];
	[self stopTimer];
	
	self.playState = MISPlayVideoPlayStatePause;
	self.controlView.isPlaying = NO;
}

/**
 *  停止播放
 */
- (void)stopPlay {
	[self.player pause];
	[self stopTimer];
	
	self.playState = MISPlayVideoPlayStatePrepare;
	self.controlView.isPlaying = NO;
}

/**
 *  播放完成
 */
- (void)endPlay {
	[self stopTimer];
	self.playState = MISPlayVideoPlayStateEnd;
	self.controlView.isPlaying = NO;
}

/**
 *  关闭定时器
 */
- (void)stopTimer {
	if (_timerSource) {
		dispatch_source_cancel(_timerSource);
		_timerSource = nil;
	}
}

/**
 *  启动定时器
 */
- (void)startTimer {
	[self stopTimer];
	
	//创建 timer
	_timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
	uint64_t interval = 0.05 * NSEC_PER_SEC;
	dispatch_source_set_timer(_timerSource, dispatch_time(DISPATCH_TIME_NOW, interval), interval, 0);
	
	__weak __typeof(&*self) weakSelf = self;
	dispatch_source_set_event_handler(_timerSource, ^{
		[weakSelf updatePlayInfo];
	});
	
	dispatch_resume(_timerSource);
}


#pragma mark - OverWrite

- (BOOL)prefersStatusBarHidden {
	return YES;
}


#pragma mark - Getter

- (void)resetFrames {
    CGFloat width              = [self viewWidth];
    CGFloat height             = [self viewHeight];
    self.contentView.transform = self.view.transform;

    self.headerView.frame      = CGRectMake(0, 0, width, 44.0f);
    self.controlView.frame     = CGRectMake(0, height - 44.0f, width, 44.0f);
    self.tapView.frame         = CGRectMake(0, 0, width, height);
    self.contentView.frame     = CGRectMake(0, 0, width, height);
	self.playerLayer.frame     = CGRectMake(0, 0, width,  height);
    self.contentView.center    = self.view.center;
	
	//横屏锁定
	if (self.lockHorizontal) {
		self.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
		return;
	}
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	switch (orientation) {
		case UIDeviceOrientationPortraitUpsideDown: {
			self.contentView.transform = CGAffineTransformMakeRotation(M_PI);
		}
			break;
		case UIDeviceOrientationLandscapeLeft: {
			self.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
		}
			break;
		case UIDeviceOrientationLandscapeRight: {
			self.contentView.transform = CGAffineTransformMakeRotation(-M_PI_2);
		}
			break;
		default:
			break;
	}
}

- (AVPlayerItem *)playerItem {
	if (!_playerItem) {
		_playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
	}
	return _playerItem;
}

- (AVPlayer *)player {
	if (!_player) {
		_player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
	}
	return _player;
}


- (UIActivityIndicatorView *)loadingView {
	if (!_loadingView) {
		_loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_loadingView.center = self.view.center;
	}
	return _loadingView;
}


- (UIView *)contentView {
	if (!_contentView) {
		_contentView = [[UIView alloc] init];

		//播放界面
		[_contentView.layer addSublayer:self.playerLayer];
		
		//手势view
		[_contentView addSubview:self.tapView];
		
		//header view
		[_contentView addSubview:self.headerView];
		
		//控制view
		[_contentView addSubview:self.controlView];
	}
	return _contentView;
}


- (UIView *)headerView {
	if (!_headerView) {
		_headerView = [[UIView alloc] init];
		_headerView.alpha = 0.0f;
		_headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];

		UIButton* doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		doneBtn.frame = CGRectMake(10, 0, 44.0f, 44.0);
		doneBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[doneBtn setTitle:@"返回" forState:UIControlStateNormal];
		[doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[doneBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[doneBtn addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
		
		[_headerView addSubview:doneBtn];
	}
	return _headerView;
}

- (UIView *)tapView {
	if (!_tapView) {
		_tapView = [[UIView alloc] init];
		[_tapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBarsHidenOrNot)]];
	}
	return _tapView;
}


- (MISVideoPlayerControlView *)controlView {
	if (!_controlView) {
		_controlView = [[MISVideoPlayerControlView alloc] init];

		_controlView.hidden = YES;
		_controlView.alpha = 0.0f;
		
		__weak __typeof(&*self) weakSelf = self;
		
		//开始控制进度时
		_controlView.sliderValueWillChangeBlock = ^{
			[weakSelf pausePlay];
			[weakSelf stopTimer];
			[weakSelf stopHideTimer];
		};
		
		//控制进度时
		_controlView.sliderValueChangingBlock = ^(NSTimeInterval playTime) {
			[weakSelf setCurrentPlaybackTime:playTime];
		};
		
		
		//控制进度变化时
		_controlView.sliderValueDidChangedBlock = ^{
			[weakSelf startPlay];
			[weakSelf startHideTimer];
		};
		
		//播放/暂停
		_controlView.playBlock  = ^{
			[weakSelf togglePlayOrPause];
		};
	}
	return _controlView;
}

- (CGFloat )viewWidth {
	if (self.lockHorizontal) {
		return CGRectGetHeight(self.view.frame);
	}
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationLandscapeLeft
		|| orientation == UIDeviceOrientationLandscapeRight) {
		return  CGRectGetHeight(self.view.frame);
	} else {
		return  CGRectGetWidth(self.view.frame);
	}
}

- (CGFloat)viewHeight {
	if (self.lockHorizontal) {
		return CGRectGetWidth(self.view.frame);
	}
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationLandscapeLeft
		|| orientation == UIDeviceOrientationLandscapeRight) {
		return  CGRectGetWidth(self.view.frame);
	}else {
		return  CGRectGetHeight(self.view.frame);
	}
}

#pragma mark - KVO

- (void)addKVO {
	[self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
	[self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeKVO {
	[self.playerItem removeObserver:self forKeyPath:@"status"];
	[self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
	
	if ([keyPath isEqualToString:@"status"]) {
		switch (self.player.status) {
			case AVPlayerStatusUnknown:{
				[self.loadingView stopAnimating];
			}
				break;
			case AVPlayerStatusReadyToPlay: {
				[self.loadingView stopAnimating];
				
				[self startPlay];
			}
				break;
			case AVPlayerStatusFailed: {
				[self.loadingView stopAnimating];
			}
				break;
			default:
				break;
		}
	}
	
	//更新buffer
	if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
		NSArray* loadedTimeRanges = self.playerItem.loadedTimeRanges;
		if (loadedTimeRanges && [loadedTimeRanges count]) {
			CMTimeRange timerange = [[loadedTimeRanges firstObject] CMTimeRangeValue];
			NSTimeInterval value = CMTimeGetSeconds(CMTimeAdd(timerange.start, timerange.duration));
			self.controlView.currentBufferTime = value;
		}
	}
}


@end
