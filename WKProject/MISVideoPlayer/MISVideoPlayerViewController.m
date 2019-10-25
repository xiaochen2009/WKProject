
/***********************************************************
 //  MISVideoPlayerViewController.m
 //  Mao Kebing
 //  Created by Edu on 13-7-25.
 //  Copyright (c) 2013 Eduapp. All rights reserved.
 ***********************************************************/

#import "MISVideoPlayerViewController.h"
#import "MBProgressHUD.h"
#import "MISVideoManager.h"
#import <AVFoundation/AVPlayer.h>



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
@property (nonatomic, strong) UILabel  *startLabel;
@property (nonatomic, strong) UILabel  *endLabel;
@property (nonatomic, strong) UIView   *bgView;

@end

@implementation MISVideoPlayerControlView

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self addSubview:self.bgView];
		[self addSubview:self.playBtn];
		[self addSubview:self.startLabel];
		[self addSubview:self.slider];
		[self addSubview:self.endLabel];
	}
	return self;
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

- (UIView *)bgView {
	if (!_bgView) {
		_bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
		_bgView.backgroundColor = [UIColor blackColor];
		_bgView.alpha = 0.6f;
	}
	return _bgView;
}

- (UIButton *)playBtn {
	if (!_playBtn) {
		_playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_playBtn.frame = CGRectMake(MISVideoPlayerControlViewLRIndent, 0, MISVideoPlayerControlViewHeight, MISVideoPlayerControlViewHeight);
		[_playBtn setImage:[UIImage imageNamed:@"MISVideoPlayer.bundle/MISVideoPlayBtn"] forState:UIControlStateNormal];
		[_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _playBtn;
}

- (UILabel *)startLabel {
	if (!_startLabel) {
		_startLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.playBtn.frame), 0, MISVideoPlayerControlViewLableWidth, MISVideoPlayerControlViewHeight)];
		_startLabel.font = [UIFont systemFontOfSize:MISVideoPlayerControlViewLableFontSize];
		_startLabel.textColor = [UIColor whiteColor];
		_startLabel.textAlignment = NSTextAlignmentRight;
	}
	return _startLabel;
}

- (UILabel *)endLabel {
	if (!_endLabel) {
		_endLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - MISVideoPlayerControlViewLableWidth, 0, MISVideoPlayerControlViewLableWidth, MISVideoPlayerControlViewHeight)];
		_endLabel.font = [UIFont systemFontOfSize:MISVideoPlayerControlViewLableFontSize];
		_endLabel.textColor = [UIColor whiteColor];
		_endLabel.textAlignment = NSTextAlignmentLeft;
	}
	return _endLabel;
}

- (UISlider *)slider {
	if (!_slider) {
        CGFloat xPoint = CGRectGetMaxX(self.startLabel.frame) + MISVideoPlayerControlViewLRIndent;
        CGFloat width  = CGRectGetMinX(self.endLabel.frame) - xPoint - MISVideoPlayerControlViewLRIndent * 2;
		_slider = [[UISlider alloc] initWithFrame:CGRectMake(xPoint, 0, width, MISVideoPlayerControlViewHeight)];
		_slider.minimumTrackTintColor = [UIColor grayColor];
		_slider.maximumTrackTintColor = [UIColor whiteColor];
		[_slider setThumbImage:[UIImage imageNamed:@"MISVideoPlayer.bundle/MISVideoProgressBtn"] forState:UIControlStateNormal];
		[_slider addTarget:self action:@selector(progressValueChanged:) forControlEvents:UIControlEventValueChanged];
		[_slider addTarget:self action:@selector(progressEndChanged:) forControlEvents:UIControlEventTouchUpInside];
		[_slider addTarget:self action:@selector(progressWillChange:) forControlEvents:UIControlEventTouchDown];
	}
	return _slider;
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

@interface MISVideoPlayerViewController()

@property (nonatomic, strong) MPMoviePlayerController *player;        //播放器
@property (nonatomic, strong) UIView *contentView;                    //容器view
@property (nonatomic, strong) UIView *tapView;                        //手势view
@property (nonatomic, strong) MISVideoPlayerControlView *controlView; //控件view
@property (nonatomic, strong) UIView *headerView;                     //顶栏
@property (nonatomic, strong) NSTimer *refreshTimer;                  //更新timer
@property (nonatomic, strong) NSTimer *hideTimer;                     //渐隐timer
@property (nonatomic, strong) MBProgressHUD *hud;                     //进度指示器
@property (nonatomic, strong) UIImageView *placeholderImageView;      //占位图
@property (nonatomic) BOOL isBarsHiden;                               //上下栏是否已隐藏

@end

@implementation MISVideoPlayerViewController

#pragma mark - Life

- (instancetype)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(moviePlayerPlaybackStateDidChangeNotification:)
													 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
		
		_isBarsHiden = YES;
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
	[super viewDidLoad];
		
	//准备UI
	[self.view addSubview:self.contentView];
	
	//加载视频
	[self loadVideo];
}


/**
 *  停止 timer
 */
- (void)stopRefreshTimer {
	if ([_refreshTimer isValid]) {
		[_refreshTimer invalidate];
		_refreshTimer = nil;
	}
}

/**
 *  启动 timer
 */
- (void)startRefreshTimer {
	[self stopRefreshTimer];
	
	_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updatePlayInfo) userInfo:nil repeats:YES];
}

- (void)stopHideTimer {
	if ([_hideTimer isValid]) {
		[_hideTimer invalidate];
		_hideTimer = nil;
	}
}

- (void)startHideTimer {
	_hideTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onHideBars) userInfo:nil repeats:NO];
}

/**
 *  更新时间信息
 */
- (void)updatePlayInfo {
	self.controlView.totalPlaybackTime = self.player.duration;
	self.controlView.currentPlaybackTime = self.player.currentPlaybackTime;
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
	[self stopRefreshTimer];
	
	self.player.currentPlaybackTime = playTime;
}

/**
 *  退出
 */
- (void)exit {
	//取消下载
	[self cancelLoad];
	
	//取消timer
	[self stopHideTimer];
	[self stopRefreshTimer];
	
	//停止
	[self.player stop];
	
	//返回
	[self dismissViewControllerAnimated:NO completion:nil];
}

/**
 *  删除项-用于预览时
 */
- (void)delItem {
	//取消下载
	[self cancelLoad];
	
	//取消timer
	[self stopHideTimer];
	[self stopRefreshTimer];
	
	//停止
	[self.player stop];
	
	//回调
	if (self.deleteBlock) {
		self.deleteBlock();
	}
	
	//返回
	[self dismissViewControllerAnimated:NO completion:nil];
}

/**
 *  加载视频
 */
- (void)loadVideo {
	//传入的是本地文件URL-免下载直接播放
	if ([self.videoURL.scheme isEqualToString:@"file"]) {
	
		//播放
		[self startPlayVideoWithURL:self.videoURL];
		return;
	}
	
	//网络的走下面的流程-
	
	/**
	 *  显示占位图
	 */
	[self showPlaceholder];
	
	__weak __typeof(&*self) weakSelf = self;
	[self.hud show:YES];

	[[MISVideoManager sharedManager] fetchVideoWithURL:self.videoURL progress:^(int64_t receivedSize, int64_t expectedSize) {
		if (expectedSize > 0) {
			//显示进度
			weakSelf.hud.progress = receivedSize / (float) expectedSize;
		}
	} completed:^(NSURL *fileURL, NSError *error) {
		[weakSelf.hud hide:YES];
		[weakSelf hidePlaceholder];

		//播放
		[weakSelf startPlayVideoWithURL:fileURL];
	}];
}

/**
 *  取消下载
 */
- (void)cancelLoad {
	[[MISVideoManager sharedManager] cancelTaskForURL:self.videoURL];
}

/**
 *  显示占位图片
 */
- (void)showPlaceholder {
	[self.placeholderImageView sd_setImageWithURL:self.placeholderURL
								 placeholderImage:self.placeholder];
	
	self.placeholderImageView.hidden  = NO;
}

/**
 *  隐藏占位图
 */
- (void)hidePlaceholder {
	self.placeholderImageView.hidden = YES;
}

/**
 *  开始播放
 *
 *  @param url 传入 url
 */
- (void)startPlayVideoWithURL:(NSURL *)url {
	self.player.contentURL = url;
	[self.player play];
	
	//显示操作栏-能播放的情况下
	self.controlView.hidden = NO;
	
	//显示上下栏
	[self toggleBarsHidenOrNot];
}


#pragma mark - Notifactions

- (void)moviePlayerPlaybackStateDidChangeNotification:(NSNotification *)notifaction {
	if (self.player.playbackState == MPMoviePlaybackStatePlaying) {
		self.controlView.isPlaying = YES;
		[self updatePlayInfo];
		[self startRefreshTimer];
	}else {
		[self updatePlayInfo];
		[self stopRefreshTimer];
		self.controlView.isPlaying = NO;
	}
}


#pragma mark - OverWrite

- (BOOL)prefersStatusBarHidden {
	return YES;
}


#pragma mark - Getter


- (MBProgressHUD *)hud {
	if (_hud == nil) {
		_hud  = [[MBProgressHUD alloc] initWithView:self.contentView];
		_hud.mode  = MBProgressHUDModeDeterminate;
	}
	return _hud;
}

- (MPMoviePlayerController *)player {
	if (!_player) {
		_player = [[MPMoviePlayerController alloc] init];
		_player.view.frame = CGRectMake(0, 0, [self viewWidth], [self viewHeight]);
		_player.controlStyle = MPMovieControlStyleNone;
		_player.scalingMode = MPMovieScalingModeAspectFit;
	}
	return _player;
}

- (UIView *)contentView {
	if (!_contentView) {
		_contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self viewWidth], [self viewHeight])];
		_contentView.center = self.view.center;
	
		//播放view
		[_contentView addSubview:self.player.view];
		
		[_contentView addSubview:self.placeholderImageView];
		
		//指示器
		[_contentView addSubview:self.hud];
		
		//手势view
		[_contentView addSubview:self.tapView];
		
		//header view
		[_contentView addSubview:self.headerView];
		
		//控制view
		[_contentView addSubview:self.controlView];
		
		if (self.lockHorizontal) {
			//横屏
			_contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
		}
	}
	return _contentView;
}

- (UIImageView *)placeholderImageView {
	if (!_placeholderImageView) {
		_placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self viewWidth], [self viewHeight])];
		_placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
		_placeholderImageView.hidden = YES;
	}
	return _placeholderImageView;
}


- (UIView *)headerView {
	if (!_headerView) {
		_headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self viewWidth], 44.0f)];
		_headerView.alpha = 0.0f;
		
		UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self viewWidth], 44.0f)];
		bgView.backgroundColor = [UIColor blackColor];
		bgView.alpha = 0.6f;
		[_headerView addSubview:bgView];
		
		UIButton* doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		doneBtn.frame = CGRectMake(10, 0, 44.0f, 44.0);
		doneBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[doneBtn setTitle:@"返回" forState:UIControlStateNormal];
		[doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[doneBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[doneBtn addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:doneBtn];
		
		//用于预览
		if (self.useForPreview) {
			UIButton* delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			delBtn.frame = CGRectMake([self viewWidth] - 10 - 44.0f, 0, 44.0f, 44.0);
			delBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
			[delBtn setTitle:@"删除" forState:UIControlStateNormal];
			[delBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[delBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
			[delBtn addTarget:self action:@selector(delItem) forControlEvents:UIControlEventTouchUpInside];
			[_headerView addSubview:delBtn];
		}
	}
	return _headerView;
}

- (UIView *)tapView {
	if (!_tapView) {
		_tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self viewWidth], [self viewHeight])];
		[_tapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBarsHidenOrNot)]];
	}
	return _tapView;
}


- (MISVideoPlayerControlView *)controlView {
	if (!_controlView) {
		_controlView = [[MISVideoPlayerControlView alloc] initWithFrame:CGRectMake(0, [self viewHeight] - 44.0f, [self viewWidth], 44.0f)];
		_controlView.hidden = YES;
		_controlView.alpha = 0.0f;
		
		__weak __typeof(&*self) weakSelf = self;
		
		//开始控制进度时
		_controlView.sliderValueWillChangeBlock = ^{
			[weakSelf stopRefreshTimer];
			[weakSelf stopHideTimer];
		};
		
		//控制进度时
		_controlView.sliderValueChangingBlock = ^(NSTimeInterval playTime) {
			[weakSelf setCurrentPlaybackTime:playTime];
		};
		
		
		//控制进度变化时
		_controlView.sliderValueDidChangedBlock = ^{
			[weakSelf.player play];
			[weakSelf startHideTimer];
		};
		
		//播放/暂停
		_controlView.playBlock  = ^{
			if (weakSelf.player.playbackState == MPMoviePlaybackStatePlaying) {
				[weakSelf.player pause];
				return ;
			}
			
			if (weakSelf.player.playbackState == MPMoviePlaybackStateStopped
				|| weakSelf.player.playbackState == MPMoviePlaybackStatePaused){
				[weakSelf.player play];
			}
		};
	}
	return _controlView;
}

- (CGFloat )viewWidth {
	CGFloat value = CGRectGetWidth(self.view.frame);
	if (self.lockHorizontal) {
		value = CGRectGetHeight(self.view.frame);
	}
	return value;
}

- (CGFloat)viewHeight {
	CGFloat value = CGRectGetHeight(self.view.frame);
	if (self.lockHorizontal) {
		value = CGRectGetWidth(self.view.frame);
	}
	return value;
}


@end
