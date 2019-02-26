//
//  ViewController.m
//  WawajiOpenDemo
//
//  Created by mikey on 2018/8/24.
//  Copyright © 2018年 mikey. All rights reserved.
//

#import "ViewController.h"

#import <XHWaWaJi/XHWaWaJi.h>

@interface ViewController ()<XHPlayerManagerDelegate,XHLivePlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *lianmaiRootView;
@property (weak, nonatomic) IBOutlet UIView *panluRootView;
@property (weak, nonatomic) IBOutlet UIButton *queueBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

// 视频是否连麦状态
@property (nonatomic, assign) BOOL isLianmai;
// 当前摄像头索引
@property (nonatomic, strong) NSNumber *cameraIndex;
// 是否使用熊猫排队功能
@property (nonatomic, assign) BOOL isQueueEnable;

@end

@implementation ViewController
{
    NSString *liveUrl1;
    NSString *liveUrl2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.lianmaiRootView.layer.borderColor = [[UIColor redColor] CGColor];
    self.lianmaiRootView.layer.borderWidth = 1;
    self.panluRootView.layer.borderColor = [[UIColor greenColor] CGColor];
    self.panluRootView.layer.borderWidth = 1;
    
    liveUrl1 = @"";
    liveUrl2 = @"";

    // 摄像头方向默认为正面
    self.cameraIndex = @0; // @0 => 正面， @1侧面

    // 是否使用熊猫排队功能
    self.isQueueEnable = false;
    
    // 进入房间，优先显示旁路视频
    //[self showPangluView];j
    // 加载旁路视频
    //[[XHLivePlayer sharedManager] addWawajiLive:@[liveUrl1, liveUrl2] rootView:self.panluRootView];
    //[[XHLivePlayer sharedManager] setLiveListener:self];
}

#pragma mark ============== 视频部分 ==============
- (void)joinLianmaiRoom{
    __weak typeof(self) weakself = self;
    [[XHLivePlayer sharedManager] pausePlayers]; // 暂停旁路视频
    NSString *kRoomId = @"500884"; // 500xxx
    NSString *masterId = [NSString stringWithFormat:@"wowgotcha_%@_1",kRoomId];
    //NSString *slaveId = [NSString stringWithFormat:@"wowgotcha_%@_2",kRoomId];
    NSString *slaveId = masterId;
    XHLiveCamera *camera = [XHLiveCamera liveCameraWithMasterId:masterId slaveId:slaveId];
    XHLiveManager *manager = [XHLiveManager sharedManager];
    [manager setStreamSrcType:QAVVIDEO_SRC_TYPE_CAMERA sideSrcType:QAVVIDEO_SRC_TYPE_SCREEN];
    [manager joinRoom:kRoomId liveCarema:camera rootView:self.lianmaiRootView playingFrame:self.lianmaiRootView.bounds success:^{
        __strong typeof(self) strongself = weakself;
        NSLog(@"加入连麦房间成功");
        // 连麦视频已拉流成功
        strongself.cameraIndex = [manager switchCamera:strongself.cameraIndex]; // 同步当前的摄像头方向
        
        // 由于加载连麦视频需要时间拉流和渲染，因此将view的hidden属性放在这里处理
        [strongself showLianmaiView];
        
        // ****** upToVideoMember方法，若需要做玩家视频采集的，需要调用此方法 ******
        /*
        [manager upToVideoMemberSuccess:^{rol
            NSLog(@"上麦成功");
        } failure:^(NSString *vgd, int errId, NSString *errMsg) {
            // 上麦失败，一般原因是腾讯云后台角色配置不对
            NSLog(@"上麦失败");
        }];
        */
    } failure:^(NSString *module, int errId, NSString *errMsg) {
        NSLog([NSString stringWithFormat:@"加入失败 errId: %d, errMsg: %@", errId, errMsg]);
    }];
}

- (void)showLianmaiView{
    self.isLianmai = YES;
    self.lianmaiRootView.hidden = NO;
    self.panluRootView.hidden = YES;
}

- (void)showPangluView{
    self.isLianmai = NO;
    self.lianmaiRootView.hidden = YES;
    self.panluRootView.hidden = NO;
}

- (void)switchToPanglu{
    [self showPangluView];
    [[XHLivePlayer sharedManager] resumePlayers];
    [[XHLivePlayer sharedManager] switchCamera:self.cameraIndex];
    [[XHLiveManager sharedManager] quitRoomSuccess:^{
        NSLog(@"退出连麦视频房间成功");
    } failure:^(NSString *vgd, int errId, NSString *errMsg) {
        NSLog(@"退出连麦视频房间失败");
    }];
}

- (void)switchToLianmai{
    [[XHLivePlayer sharedManager] pausePlayers];
    [self joinLianmaiRoom];
}

- (IBAction)switchCamera:(id)sender {
    if (self.isLianmai) {
        self.cameraIndex = [[XHLiveManager sharedManager] switchCamera:nil];
    } else {
        self.cameraIndex = [[XHLivePlayer sharedManager] switchCamera:nil];
    }
}

// 旁路视频播放回调
- (void)livePlayerBegin:(NSString *)url{
    if ([url isEqualToString:liveUrl1]) {
        NSLog(@"正面视频已播放");
    }
    if ([url isEqualToString:liveUrl2]) {
        NSLog(@"侧面视频已播放");
    }
}

#pragma mark ============== 控制部分 ==============
- (IBAction)connectWS:(id)sender {
    [self switchToLianmai];
    return;
    
    [[XHPlayerManager sharedManager] setEnqueue:self.isQueueEnable]; // sdk默认使用排队功能，如不需要，则次方法必须调用并传入NO
    [[XHPlayerManager sharedManager] printWebsocketMsg]; // 调试时可以打开注释，此开关会打印Websocket通信消息体
    NSString *wsUrl = @"ws://ws1.open.wowgotcha.com:9090/play/5d901e1c0a68abb43a5d1a2c59cbafb4e935cd8c"; // ws地址只有几分钟过期时间，需替为当前使用的ws url
    [[XHPlayerManager sharedManager] setManagerListener:self];
    [[XHPlayerManager sharedManager] connectWithWebSocketURL:wsUrl success:^{
        NSLog(@"websocket连接成功");
    } failure:^(NSError *error) {
        NSLog(@"websocket连接失败");
    }];
}
- (IBAction)startQueue:(id)sender {
    [[XHPlayerManager sharedManager] startQueue];
}
- (IBAction)startGame:(id)sender {
    [[XHPlayerManager sharedManager] startGame];
}
- (IBAction)cancelQueue:(id)sender {
    [[XHPlayerManager sharedManager] cancelQueue];
    self.startBtn.enabled = NO;
    if (self.isQueueEnable && self.isLianmai) {
        [self switchToPanglu];
    }
}
- (IBAction)directionTouchDown:(UIButton *)sender {
    if (sender.tag == 1000) {
        // 上
        [[XHPlayerManager sharedManager] sendOperation:XHPlayerOperationUpPress];
    }else if (sender.tag == 1001){
        // 左
        [[XHPlayerManager sharedManager] sendOperation:XHPlayerOperationLeftPress];
    }else if (sender.tag == 1002){
        // 下
        [[XHPlayerManager sharedManager] sendOperation:XHPlayerOperationDownPress];
    }else if (sender.tag == 1003){
        // 右
        [[XHPlayerManager sharedManager] sendOperation:XHPlayerOperationRightPress];
    }
}
- (IBAction)directionTouchUp:(UIButton *)sender {
    if (sender.tag == 1000) {
        // 上
        [[XHPlayerManager sharedManager] sendOperation:XHPlayerOperationUpRelease];
    }else if (sender.tag == 1001){
        // 左
        [[XHPlayerManager sharedManager] sendOperation:XHPlayerOperationLeftRelease];
    }else if (sender.tag == 1002){
        // 下
        [[XHPlayerManager sharedManager] sendOperation:XHPlayerOperationDownRelease];
    }else if (sender.tag == 1003){
        // 右
        [[XHPlayerManager sharedManager] sendOperation:XHPlayerOperationRightRelease];
    }
}
- (IBAction)catch:(UIButton *)sender {
    [[XHPlayerManager sharedManager] sendOperation:XHPlayerOperationCatch];
}

// ---------- 游戏socket事件回调
- (void)roomReady:(NSDictionary *)readyInfo{
    // websocket连接成功之后，游戏进入roomReady状态，表明游戏机可用，之后才可以发送相应命令
    NSLog(@"room ready,%@",readyInfo);
    if (self.isQueueEnable) {
        self.queueBtn.enabled = YES;
        self.cancelBtn.enabled = YES;
    } else {
        self.startBtn.enabled = YES;
    }
}
- (void)gameReconnect:(NSDictionary *)reconnectInfo{
    NSLog(@"game reconnect,%@",reconnectInfo);
}
- (void)gameQueueInfo:(NSInteger)position{
    // 用户排队之后，会持续收到队列变化信息
    NSLog(@"user position, %ld", position);
}
- (void)gamePrepare:(NSInteger)leftTime{
    // 排队完成，准备开始游戏
    NSLog(@"queue time left,%ld",leftTime);
    self.startBtn.enabled = YES;
    if (self.isQueueEnable && leftTime == 9) {
        //
    }
}
- (void)gameStarted:(NSDictionary *)data{
    // 游戏已开始，可以操作上下左右和下爪
    NSLog(@"game started,%@",data);
    if (!self.isQueueEnable) {
        // 未使用熊猫排队功能，游戏结束需要切换回旁路视频
        [self switchToLianmai];
    } else {
        // 如果上一局已经连麦过了，并且继续了游戏之后不需要重复连麦，并且一个房间只允许有一个连麦，无法支持同时多次连麦
        if (!self.isLianmai) {
            [self switchToLianmai];
        }
    }
}
- (void)receiveGameResult:(BOOL)success sessionId:(NSString *)sessionId{
    // 当次游戏结果
    NSLog(@"game result %@",sessionId);
    if (!self.isQueueEnable) {
        // 未使用熊猫排队功能，游戏结束需要切换回旁路视频
        [self switchToPanglu];
    }
}
- (void)gameWaitRestart:(NSInteger)leftTime{
    // 一局游戏结束，重新倒计时，等待用户上机或取消
    NSLog(@"queue time left,%ld",leftTime);
    self.startBtn.enabled = YES;
}
- (void)gameError:(NSDictionary *)info errorType:(XHPlayerGameError)type{
    NSLog(@"game errofr %@",info);
}
- (void)gameQueueKickOff{
    NSLog(@"game queue Kick Off");
    self.startBtn.enabled = NO;
    if (self.isQueueEnable && self.isLianmai) {
        [self switchToPanglu];
    }
}
- (void)websocketClosed{
    NSLog(@"websocket已关闭");
}

@end
