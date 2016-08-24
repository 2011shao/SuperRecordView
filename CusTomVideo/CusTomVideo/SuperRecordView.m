//
//  SuperRecordView.m
//  CusTomVideo
//
//  Created by ios-少帅 on 16/8/19.
//  Copyright © 2016年 ios-shaoshuai. All rights reserved.
//

#import "SuperRecordView.h"
#import "ProgressView.h"

#define TIMER_INTERVAL 0.5;

@interface SuperRecordView ()<AVCaptureFileOutputRecordingDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    NSTimer * countTimer;
    double currentTime;
    NSMutableArray * urlArray;
    NSString * videoFilePath;
}

@property (nonatomic,strong)AVCaptureDeviceInput * photoInput;//视频输入设备对象
@property (nonatomic,strong)AVCaptureMovieFileOutput * movieOutput;//视频输出对象
@property (nonatomic,strong)AVCaptureMetadataOutput* metaOutput;//二维码输出对象
@property (nonatomic,strong)AVCaptureVideoPreviewLayer * previewLayer;//输入预览 layer
@property (nonatomic,strong)ProgressView * progressView;//进度条
@property (strong,nonatomic)  UIImageView *focusCursor; //聚焦光标




@end

@implementation SuperRecordView
//**************************************二维码****************

#pragma makr - - 二维码
-(instancetype)initWithQrcode
{
    self=[super init];
    if (self) {
        
        [self creatRcordInfo];
        
        
    }
    return self;
    
    
}
//配置二维码信息
-(void)creatRcordInfo
{
    urlArray=[[NSMutableArray alloc]initWithCapacity:0];
    //摄像头
    AVCaptureDevice *backPhoto=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    _photoInput=[AVCaptureDeviceInput deviceInputWithDevice:backPhoto error:nil];
    
    
    
    //创建会话 将摄像头和麦克风添加到会话中
    _captureSession=[[AVCaptureSession alloc]init];
    
    //会话
    _captureSession.sessionPreset=AVCaptureSessionPresetHigh;
    
    if ([_captureSession canAddInput:_photoInput]) {
        [_captureSession addInput:_photoInput];}
    
    
    
    
    //输出 添加到会话中
    _metaOutput=[[AVCaptureMetadataOutput alloc]init];
    if ([_captureSession canAddOutput:_metaOutput]) {
        [_captureSession addOutput:_metaOutput];
    }
    _metaOutput.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    [_metaOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    [self.captureSession startRunning];
    
    
    
}
//二维码代理方法
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [self.captureSession stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        [_delegate QrCodecompleteWithResult:metadataObject.stringValue];
    }
}
//************************************视频录制****************

//进度条
-(ProgressView*)progressView
{
    if (!_progressView) {
        _progressView=[[ProgressView alloc]init];
        
    }
    return _progressView;
}
//录制过程中==修改分辨率
-(void)setChangeSessionPreset:(NSString *)changeSessionPreset
{
    _changeSessionPreset=changeSessionPreset;
  
    //更改分辨率先配置开启配置 更改完后再提交配置
    [self.captureSession beginConfiguration];
    self.captureSession.sessionPreset=changeSessionPreset;
    [self.captureSession commitConfiguration];

    
    
}
-(instancetype)initWithRecordingAndSessionPreset:(NSString*)sessionpreset  SaveFilepath:(NSString*)saveFilepath
{
    self=[super init];
    if (self) {
        
        [self creatRcordInfoWithSessionPreset:sessionpreset];
        videoFilePath=saveFilepath;
        
    }
    return self;
}

-(void)creatRcordInfoWithSessionPreset:(NSString*)sessionpreset
{
    urlArray=[[NSMutableArray alloc]initWithCapacity:0];
    //摄像头
   AVCaptureDevice *backPhoto=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
     _photoInput=[AVCaptureDeviceInput deviceInputWithDevice:backPhoto error:nil];
    
    //麦克风
    AVCaptureDevice * audio=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput * audioInput=[AVCaptureDeviceInput deviceInputWithDevice:audio error:nil];
    
    //创建会话 将摄像头和麦克风添加到会话中
    _captureSession=[[AVCaptureSession alloc]init];
    
    //会话
    if([_captureSession canSetSessionPreset:sessionpreset])
    {
        _captureSession.sessionPreset=sessionpreset;
    }else{
        //当前所设置的分辨率超过设备要求后会使用设备的最低分辨率
        _captureSession.sessionPreset=AVCaptureSessionPresetLow;
    }
    
    if ([_captureSession canAddInput:_photoInput]) {
        [_captureSession addInput:_photoInput];}
    if ([_captureSession canAddInput:audioInput]) {
        [_captureSession addInput:audioInput];
        AVCaptureConnection *captureConnection=[_movieOutput connectionWithMediaType:AVMediaTypeVideo];
        //是否支持视频稳定  设置视频稳定模式
        if ([captureConnection isVideoStabilizationSupported ]) {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }

    }
    
    //输出 添加到会话中
    _movieOutput=[[AVCaptureMovieFileOutput alloc]init];
    if ([_captureSession canAddOutput:_movieOutput]) {
        [_captureSession addOutput:_movieOutput];
    }
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self addGestureRecognizer:tapGesture];
    
    [self.captureSession startRunning];

    
    
}
-(void)layoutSubviews
{
    //创建视图会话
    _previewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession];
    _previewLayer.backgroundColor=[UIColor redColor].CGColor;
    
    _previewLayer.frame=self.layer.frame;
    //设置填充模式
    _previewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    
    self.progressView.frame=CGRectMake(0, self.previewLayer.frame.size.height+10, self.previewLayer.frame.size.width, 1);
    
    [self.layer insertSublayer:_previewLayer atIndex:0];
}
-(void)setRecordingTime:(CGFloat)recordingTime
{
    _recordingTime=recordingTime;
    [self addSubview:self.progressView];
}
#pragma mark - - 开始录制
-(void)startVideoRecording
{
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //根据连接取得设备输出的数据
    if (![self.movieOutput isRecording]) {
        //预览图层和视频方向保持一致
        captureConnection.videoOrientation=[self.previewLayer connection].videoOrientation;

        [self.movieOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self getVideoSaveFilePathString]] recordingDelegate:self];
    }
    else{
        [self stopTimer];

        [self.movieOutput stopRecording];//停止录制
    }
    
    
}
//停止录制
-(void)stopVideoRcording
{
    [self.movieOutput stopRecording];
}
//保存视频到本地
-(void)saveVideoTolocation{
    
       //正在拍摄
    if (_movieOutput.isRecording) {
        [_movieOutput stopRecording];
        
        
    }
    
    [self mergeAndExportVideosAtFileURLs:urlArray];
    
    if(self.recordingTime>0){
        currentTime=0;
        [countTimer invalidate];
        countTimer = nil;
    }


}


-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.previewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
        
    }];
}


#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
    if (self.recordingTime>0) {
        [self startTimer];

    }
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    
    [urlArray addObject:outputFileURL];
  
    
    
}




- (void)deleteAllVideos
{
    for (NSURL *videoFileURL in urlArray) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *filePath = [[videoFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath]) {
                NSError *error = nil;
                [fileManager removeItemAtPath:filePath error:&error];
                
                if (error) {
                    NSLog(@"delete All Video 删除视频文件出错:%@", error);
                }
            }
        });
    }
    [urlArray removeAllObjects];
}


- (NSString *)getVideoSaveFilePathString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName=[NSString stringWithFormat:@"%@/%@.mov",videoFilePath,nowTimeStr];
   
    
    return fileName;
}

-(void)startTimer{
    
    countTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    [countTimer fire];
}

-(void)stopTimer{
    
    [countTimer invalidate];
    countTimer = nil;
    
}
- (void)onTimer:(NSTimer *)timer
{
    currentTime += 0.5;
    //进度条
    self.progressView.progress=currentTime/_recordingTime;
    
       //时间到了停止录制视频
    if (currentTime>=_recordingTime) {
        [countTimer invalidate];
        countTimer = nil;
        [_movieOutput stopRecording];
    }
    
}

#pragma mark - - 转换摄像头
-(void)setIsPositionBack:(BOOL)isPositionBack
{
    _isPositionBack=isPositionBack;
    
    //AVCaptureDevice *currentDevice=[self.photoInput device];
    //AVCaptureDevicePosition currentPosition=[currentDevice position];
    AVCaptureDevicePosition toChangePosition=_isPositionBack ?AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    
    AVCaptureDevice *toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
#pragma mark - - 改变配置一定要先开启配置,配置完成后再提交配置改变
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.photoInput];
    //添加新的输入对象`
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.photoInput=toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
    
    
    self.isTorch=NO;
    
}
//根据要求得到前/后摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position
{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}
#pragma makr - - 开启关闭闪光灯
-(void)setIsTorch:(BOOL)isTorch
{
    _isTorch=isTorch;
    AVCaptureDevice *captureDevice= [self.photoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    
    if ([captureDevice lockForConfiguration:&error]) {
        //
        AVCaptureTorchMode torchMode=_isTorch ? AVCaptureTorchModeOn:AVCaptureTorchModeOff;
        
        if ([captureDevice isTorchModeSupported:torchMode]) {
            [captureDevice setTorchMode:torchMode];
        }
        //设置完成后解锁
        [captureDevice unlockForConfiguration];
    }

}
- (void)mergeAndExportVideosAtFileURLs:(NSMutableArray *)fileURLArray
{
    NSError *error = nil;
    
    CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    //创建工程文件
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
    
    for (NSURL *fileURL in fileURLArray) {
        //获取所有的视频素材
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        //将所有的视频素材添加到数组中
        [assetArray addObject:asset];
        
        //获取视频轨道
        NSArray* tmpAry =[asset tracksWithMediaType:AVMediaTypeVideo];
        if (tmpAry.count>0) {
            AVAssetTrack *assetTrack = [tmpAry objectAtIndex:0];
            //将所有的视频轨道添加到数组中
            [assetTrackArray addObject:assetTrack];
            renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
            renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
        }
    }
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    CGFloat wid=self.frame.size.width;
    CGFloat hig=self.frame.size.height;
    
    //所有的素材是视频数据 和所有的视频轨道数组 for 循环
    for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        NSArray*dataSourceArray= [asset tracksWithMediaType:AVMediaTypeAudio];
        //将音频轨道插入到工程中
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:([dataSourceArray count]>0)?[dataSourceArray objectAtIndex:0]:nil
                             atTime:totalDuration
                              error:nil];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        //将视频轨道插入到工程中
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetTrack
                             atTime:totalDuration
                              error:&error];
       // AVMutableVideoCompositionLayerInstruction：视频轨道中的一个视频，可以缩放、旋转等；

        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        CGFloat rate;
        rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
    
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0+hig/wid*(hig-wid)/2));
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);
        
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    NSString *path = [self getVideoMergeFilePathString];
    NSURL *mergeFileURL = [NSURL fileURLWithPath:path];
    //AVMutableVideoCompositionInstruction：一个视频轨道，包含了这个轨道上的所有视频素材；
    //视频操作指令
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 100);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW*(hig/wid));
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"%@",mergeFileURL);
            //已经 cu
            
//            PlayVideoViewController* view = [[PlayVideoViewController alloc]init];
//            view.videoURL =mergeFileURL;
//            [self.navigationController pushViewController:view animated:YES];
//            
        });
    }];
    
    
}
//最后合成为 mp4
- (NSString *)getVideoMergeFilePathString
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString * fileName=[NSString stringWithFormat:@"%@/%@.merge.mp4",videoFilePath,nowTimeStr];
    
    return fileName;
}

-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    AVCaptureDevice * captureDevice=[self.photoInput device];
    if ([captureDevice lockForConfiguration:nil]) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
        [captureDevice unlockForConfiguration];

    };
}

-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    AVCaptureDevice * captureDevice=[self.photoInput device];
    if ([captureDevice lockForConfiguration:nil]) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
        [captureDevice unlockForConfiguration];

    };
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point
{
    AVCaptureDevice * captureDevice=[self.photoInput device];
    if ([captureDevice lockForConfiguration:nil]) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
        [captureDevice unlockForConfiguration];

    };
}
//*********************************根据图像地址获取视频截图
+ (UIImage *)imageWithVideo:(NSURL *)videoURL

{
    
    // 根据视频的URL创建AVURLAsset
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    // 根据AVURLAsset创建AVAssetImageGenerator对象
    
    AVAssetImageGenerator* gen = [[AVAssetImageGenerator alloc] initWithAsset: asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    // 定义获取0帧处的视频截图
    
    CMTime time = CMTimeMake(0, 10);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    // 获取time处的视频截图
    
    CGImageRef  image = [gen  copyCGImageAtTime: time actualTime: &actualTime error:&error];
    
    // 将CGImageRef转换为UIImage
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage: image];
    
    CGImageRelease(image);
    
    return  thumb;
    
}
/***  根据指定的路径获取该路径下所有的视频文件*/
-(NSArray*)getALLVideoformfilePath:(NSString*)filePath
{
    NSFileManager * FM=[NSFileManager defaultManager];
    
    NSURL * filePathUrl=[NSURL fileURLWithPath:filePath];
    
    
    NSArray *attributes = [NSArray arrayWithObjects:NSURLFileSizeKey,NSURLContentModificationDateKey,nil];
    
    ;
    
    return [FM contentsOfDirectoryAtURL:filePathUrl includingPropertiesForKeys:attributes options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
}
@end
