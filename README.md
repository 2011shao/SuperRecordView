# SuperRecordView
一个<一>键录制视频,<一>键开启扫描二维码基于 AVFoundation封装的简单库

可以直接录制视频,保存到本地,然后播放,
可以做二维码扫面

<1>录制视频


self.vcc=[[SuperRecordView alloc]initWithRecordingAndSessionPreset:AVCaptureSessionPreset1280x720 SaveFilepath:getFilePath(@"")];
    self.vcc.frame=CGRectMake(0, 20, 320, 200);
    _vcc.recordingTime=10;// 可以不用填写时间 
     _vcc.isTorch=YES;闪光灯的开启
    _vcc.isPositionBack=YES;//yes 为后置摄像头, no 为前置摄像头, 不设置默认是后置摄像头
    
    [self.view addSubview:self.vcc];

<2>二维码

 self.vcc=[[SuperRecordView alloc]initWithQrcode];
    self.vcc.frame=CGRectMake(0, 20, 320, 200);
    self.vcc.delegate=self;//代理方法可以直接得到读出来的字符串
    [self.view addSubview:self.vcc];

就这么多了,不是大牛,我们只是代码的整理工!
