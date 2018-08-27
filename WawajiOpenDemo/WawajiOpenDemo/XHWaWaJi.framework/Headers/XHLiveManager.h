//
//  XHLiveManager.h
//  XHLive
//
//  Created by Michael on 2017/11/29.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ILiveSDK/ILiveQualityData.h>
#import <ILiveSDK/ILiveCoreHeader.h>
#import <ILiveSDK/ILiveSDK.h>
#import <TILLiveSDK/TILLiveSDK.h>

typedef void (^XHSuccess)(void);
typedef void (^XHFailure)(NSString *vgd, int errId, NSString *errMsg);

@class XHLiveCamera;

@interface XHLiveManager : NSObject <QAVLogger>

/**
 *  管理类单例
 */
+(instancetype)sharedManager;


/**
 *  初始化SDK
 *
 *  @param appId    传入腾讯云的appid
 *  @param accountType    传入腾讯云的accounttype
 */
- (void)initSdk:(int)appId accountType:(int)accountType;


/**
 *  帐号登录
 *
 *  @param userId    用户id
 *  @param sig    用户签名
 *  @param success    成功回调
 *  @param failure    失败回调
 */
- (void)loginWithUserId:(NSString *)userId sig:(NSString *)sig success:(XHSuccess)success failure:(XHFailure)failure;


/**
 *  加入房间,加入成功之后会在上层添加一层视频的RenderView
 *
 *  @param roomId    房间id
 *  @param success   成功回调
 *  @param failure   失败回调
 */
- (void)joinRoom:(NSString *)roomId liveCarema:(XHLiveCamera *)camera rootView:(UIView *)rootView playingFrame:(CGRect)frame success:(XHSuccess)success failure:(XHFailure)failure;


/**
 *  切换摄像头。当参数为nil时，自动转换到另一个摄像头
 *  @param index    指定切换摄像头的下标，如果需要自动切换，传入nil既可
 */
- (NSNumber *)switchCamera:(NSNumber *)index;

/**
 *  上麦
 */
- (void)upToVideoMemberSuccess:(XHSuccess)success failure:(XHFailure)failure;


/**
 *  下麦
 */
- (void)downToVideoMemberSuccess:(XHSuccess)success failure:(XHFailure)failure;


/**
 *  退出房间
 */
- (void)quitRoomSuccess:(XHSuccess)success failure:(XHFailure)failure;


/**
 *  重新拉取视频流 (已弃用)
 */
- (void)reloadLiveStream:(XHSuccess)success failure:(XHFailure)failure;

/**
 *  开启摄像头,必须在用户上麦之前打开
 *
 *  注意：开启之后游戏用户的前置摄像头视频会传到房间的所有用户
 *
 *  @param frame    用户摄像头视频渲图层的frame
 */
- (void)enableCameraWithPlayerFrame:(CGRect)frame;

/**
 *  开启麦克风，必须在用户上麦之前打开
 *
 *  注意：开启之后游戏用户的语音会传到房间的所有用户
 */
- (void)enableMic;


/**
 *  获取所有渲染窗口
 *  @return NSArray ILiveRenderView
 */
- (NSArray<ILiveRenderView *> *)getAllAVRenderViews;

/**
 *  获取当前摄像头的位置
 *  @return NSInteger 0 => 主摄像头， 1 => 侧摄像头
 */
- (NSInteger)getCameraIndex;


/**
 *  禁用视频解码信息的Log
 */
- (void)disableLogPrint;


/**
 *  设置系统声音为正常
 *  由于对接互动直播ILiveSDK, 在调用以下几个方法时，会有音频通道变化的影响，导致系统声音变小
 *  1.joinRoom 2.quitRoom 3.upToVideoMember 4.downToVideoMember
 */
- (void)setSystemVolumeNormal;

@end


@interface XHLiveCamera : NSObject

@property (nonatomic, copy, readonly) NSString *masterId;
@property (nonatomic, copy, readonly) NSString *slaveId;

+ (XHLiveCamera *)liveCameraWithMasterId:(NSString *)masterId slaveId:(NSString *)slaveId;

@end
