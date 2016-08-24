//
//  ViewController.m
//  CusTomVideo
//
//  Created by ios-少帅 on 16/8/19.
//  Copyright © 2016年 ios-shaoshuai. All rights reserved.
//


#import "ViewController.h"
#import "SuperRecordView.h"

#define   getFilePath(fileName)  [NSHomeDirectory()stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",fileName]]

@interface ViewController ()<SuperRecordingDelegate>
@property (nonatomic,strong) SuperRecordView * vcc;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.vcc=[[SuperRecordView alloc]initWithRecordingAndSessionPreset:AVCaptureSessionPreset1280x720 SaveFilepath:getFilePath(@"")];
    self.vcc.frame=CGRectMake(0, 20, 320, 200);
    _vcc.recordingTime=10;
    
    [self.view addSubview:self.vcc];
    

    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSFileManager * FM=[NSFileManager defaultManager];
    
    NSURL * aa=[NSURL fileURLWithPath:getFilePath(@"")];
    

    NSArray *attributes = [NSArray arrayWithObjects:NSURLFileSizeKey,NSURLContentModificationDateKey,nil];

    NSArray * arr1= [FM contentsOfDirectoryAtURL:aa includingPropertiesForKeys:attributes options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    for (NSURL * string in arr1) {
        NSLog(@"%@",string);

    }
   // FM
    
    
    
}
- (IBAction)save:(id)sender {
    [self.vcc saveVideoTolocation];
}
- (IBAction)luzhi:(id)sender {
    
    [self.vcc startVideoRecording];

    
}

-(void)test
{
    //1.将素材拖入到素材库中
    
    AVAsset *asset = [AVAsset assetWithURL:nil];
    
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];//素材的视频轨
    
    AVAssetTrack *audioAssertTrack = [[asset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];//素材的音频轨
   //<2>将素材的视频插入视频轨，音频插入音频轨
    //这是工程文件  工程文件
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    //创建一个tracjid 为0 的 视频轨道
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //在该轨道中添加素材视频轨道
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    
    //在视频轨道插入一个时间段的视频
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //音频轨道
    [audioCompositionTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:audioAssertTrack atTime:kCMTimeZero error:nil];
    //插入音频数据，否则没有声音
   // 3.裁剪视频，就是要将所有视频轨进行裁剪，就需要得到所有的视频轨，而得到一个视频轨就需要得到它上面所有的视频素材
    
    AVMutableVideoCompositionLayerInstruction *videoCompositionLayerIns = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];
    
    [videoCompositionLayerIns setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    
    //得到视频素材（这个例子中只有一个视频）
    AVMutableVideoCompositionInstruction *videoCompositionIns = [AVMutableVideoCompositionInstruction videoCompositionInstruction];[videoCompositionIns setTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)];
    //得到视频轨道（这个例子中只有一个轨道）
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = @[videoCompositionIns];
    videoComposition.renderSize ;
    //裁剪出对应的大小
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //4.导出
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition           presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = videoComposition;
    exporter.outputURL = [NSURL fileURLWithPath:nil isDirectory:YES];
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.error)
        {        //...
        }else{
            //...
        }    }];
    
    
    
    
    
    
    
    
    
    
}
- (void)mergeAndExportVideos:(NSArray*)videosPathArray withOutPath:(NSString*)outpath
{
        if (videosPathArray.count == 0) {
            return;
        }
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        CMTime totalDuration = kCMTimeZero;
        for (int i = 0; i < videosPathArray.count; i++) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videosPathArray[i]]];
            NSError *erroraudio = nil;
            　　　　　//获取AVAsset中的音频 或者视频
            AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            　　　　　//向通道内加入音频或者视频
            BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                          ofTrack:assetAudioTrack
                                           atTime:totalDuration
                                            error:&erroraudio];
            
            NSLog(@"erroraudio:%@%d",erroraudio,ba);
            NSError *errorVideo = nil;
            AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
            BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                          ofTrack:assetVideoTrack
                                           atTime:totalDuration
                                            error:&errorVideo];
            
            NSLog(@"errorVideo:%@%d",errorVideo,bl);
            totalDuration = CMTimeAdd(totalDuration, asset.duration);
        }
        NSLog(@"%@",NSHomeDirectory());
        
        NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPreset640x480];
        exporter.outputURL = mergeFileURL;
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            NSLog(@"exporter%@",exporter.error);
        }];
}

@end
