//
//  SuperRecordView.h
//  CusTomVideo
//
//  Created by ios-少帅 on 16/8/19.
//  Copyright © 2016年 ios-shaoshuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol SuperRecordingDelegate <NSObject>

@optional

-(void)QrCodecompleteWithResult:(NSString*)scanningResult;

@end

@interface SuperRecordView :UIView
/***  闪光灯的开启 yes 为开启*/
@property(nonatomic,assign)BOOL isTorch;
/***  是不是后置摄像头 yes 为后置, no 为前置*/
@property(nonatomic,assign)BOOL isPositionBack;
/***  录制时间*/
@property(nonatomic,assign)CGFloat  recordingTime;
/***  录制会话*/
@property (nonatomic,strong)AVCaptureSession * captureSession;
//二维码需要用到代理
@property(nonatomic,assign)id<SuperRecordingDelegate>delegate;
/**设置分辨率*/
@property (nonatomic,copy)NSString * changeSessionPreset;





//************************************视频录制****************

/***创建视频的视图*/
-(instancetype)initWithRecordingAndSessionPreset:(NSString*)sessionpreset  SaveFilepath:(NSString*)saveFilepath;
/***  开始录制*/
-(void)startVideoRecording;
/***  停止录制*/
-(void)stopVideoRcording;
/***  保存视频内容到本地*/
-(void)saveVideoTolocation;
/***  清楚所有视频数据*/
- (void)deleteAllVideos;


/***  根据指定的路径获取该路径下所有的文件url - - 用来播放视频*/
-(NSArray*)getALLVideoformfilePath:(NSString*)filePath;
//**************************************二维码****************

#pragma mark - - 二维码
/***创建二维码视图*/
-(instancetype)initWithQrcode;

//*********************************根据图像地址获取视频截图
+ (UIImage *)imageWithVideo:(NSURL *)videoURL;
@end
