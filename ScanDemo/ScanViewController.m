//
//  ScanViewController.m
//  ScanDemo
//
//  Created by lgj on 2018/3/6.
//  Copyright © 2018年 lgj. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, assign) BOOL isReading;
@property (nonatomic,strong) UIView *viewPreview;
@property (nonatomic, strong) UIView *boxView;//扫描框
@property (nonatomic, strong) CALayer *scanLayer;//扫描线
@property (nonatomic, strong) AVCaptureSession *captureSession;//捕捉会话
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;//展示layer
@property (nonatomic, strong) NSTimer *timer;//定时器

@end

@implementation ScanViewController

- (void)dealloc {
    self.captureSession = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNav];
    [self initScanPreview];
    //判断权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (granted) {
                [self loadScanView];
            } else {
                NSString *title = @"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                [alertView show];
            }
            
        });
    }];
    
    // Do any additional setup after loading the view.
}

- (void)initNav {
    self.navigationController.title = @"扫一扫";
}

- (void)initScanPreview {
    self.viewPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    [self.view addSubview:self.viewPreview];
}

- (void)loadScanView {
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:output];
    //5.设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //5.2.设置输出媒体数据类型为QRCode
    [output setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    //9.将图层添加到预览view的图层上
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    //10.设置扫描范围
    output.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    //10.1.扫描框
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(_viewPreview.bounds.size.width * 0.2, _viewPreview.bounds.size.height*0.2, _viewPreview.bounds.size.width - _viewPreview.bounds.size.width * 0.4f, _viewPreview.bounds.size.width - _viewPreview.bounds.size.width * 0.4f)];
    _boxView.layer.borderColor = [UIColor redColor].CGColor;
    _boxView.layer.borderWidth = 1.0;
    
    [_viewPreview addSubview:_boxView];
    
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor blackColor].CGColor;
    [_boxView.layer addSublayer:_scanLayer];
    
    [self startRunning];
}
#pragma mark 开始
- (void)startRunning {
    if (self.captureSession) {
        self.isReading = YES;
        [self.captureSession startRunning];
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats: YES];
    }
}
#pragma mark 结束
- (void)stopRunning {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil ;
    }
    [self.captureSession stopRunning];
    [_scanLayer removeFromSuperlayer];
    [_videoPreviewLayer removeFromSuperlayer];
}

- (void)moveUpAndDownLine {
    CGRect frame = self.scanLayer.frame;
    if (_boxView.frame.size.height < self.scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        self.scanLayer.frame = frame;
    } else {
        frame.origin.y += 5;
        [UIView animateWithDuration:0.2 animations:^{
            self.scanLayer.frame = frame;
        }];
    }
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //判断是否有数据
    if (!_isReading) {
        return;
    }
    if (metadataObjects.count > 0) {
        _isReading = NO;
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *result = metadataObject.stringValue;
        if (self.resultBlock) {
            self.resultBlock(result?:@"");
        }
        [self.navigationController popViewControllerAnimated:NO];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
