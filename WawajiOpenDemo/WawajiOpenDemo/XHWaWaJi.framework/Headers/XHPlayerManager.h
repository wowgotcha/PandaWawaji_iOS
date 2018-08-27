//
//  XHPlayerManager.h
//  XHLive
//
//  Created by Michael on 2018/1/2.
//  Copyright © 2018年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XHPlayerOperation){
    XHPlayerOperationUpPress,
    XHPlayerOperationUpRelease,
    XHPlayerOperationLeftPress,
    XHPlayerOperationLeftRelease,
    XHPlayerOperationDownPress,
    XHPlayerOperationDownRelease,
    XHPlayerOperationRightPress,
    XHPlayerOperationRightRelease,
    XHPlayerOperationCatch
};

typedef NS_ENUM(NSInteger, XHPlayerGameError){
    XHPlayerGameErrorInsertCoin, // 投币失败，可能是用户币不足，建议业务上提前检查游戏币，再开始游戏
    XHPlayerGameErrorQueuing, // 进入队列失败
    XHPlayerGameErrorCancleQueuing, // 主动退出队列失败
    XHPlayerGameErrorOther // 其他类型错误，根据错误信息辅助判断
};

@protocol XHPlayerManagerDelegate<NSObject>

@required
/**
 *  websocket连接成功，游戏进入roomReady状态
 */
- (void)roomReady:(NSDictionary *)readyInfo;

/**
 *  websocket连接成功，用户在上局游戏未结束，返回剩余时间等信息
 */
- (void)gameReconnect:(NSDictionary *)reconnectInfo;

/**
 *  游戏开始
 *  @param data    开始游戏信息
 */
- (void)gameStarted:(NSDictionary *)data;

/**
 *  接收游戏抓取结果
 *  @param success    抓取结果
 *  @param sessionId    游戏记录id
 */
- (void)receiveGameResult:(BOOL)success sessionId:(NSString *)sessionId;

/**
 *  游戏出现异常
 *  @param info    异常信息
 */
- (void)gameError:(NSDictionary *)info errorType:(XHPlayerGameError)type;

/**
 *  队列实时变化信息
 *  @param position    用户所处队列的位置
 */
- (void)gameQueueInfo:(NSInteger)position;

/**
 *  游戏排队完成，准备开始游戏
 *  @param leftTime    队列等待剩余时间
 */
- (void)gamePrepare:(NSInteger)leftTime;

/**
 *  游戏结束，队列等待leftTiem秒，可供游戏再来
 *  @param leftTime    队列等待剩余时间
 */
- (void)gameWaitRestart:(NSInteger)leftTime;

/**
 *  踢出队列，用户未在规定队列等待时间内做任何操作，则被系统踢出队列
 */
- (void)gameQueueKickOff;

@optional

/**
 *  取消排队成功，进入该回调
 */
- (void)queueCanceled;

/**
 *  游戏结束后关闭websocket后进入该回调
 */
- (void)websocketClosed;

@end

@interface XHPlayerManager : NSObject

/**
 *  设置sdk是否使用排队机制，默认为YES
 */
@property (nonatomic, assign) BOOL enqueue;

/**
 *  管理类单例
 */
+ (instancetype)sharedManager;

/**
 *  设置监听对象
 */
- (void)setManagerListener:(id)listener;

/**
 *  连接游戏websocket
 *
 *  @param websocketURL    游戏websocket链接
 *  @param success    连接成功回调
 *  @param failure    连接失败回调
 */
- (void)connectWithWebSocketURL:(NSString *)websocketURL success:(void(^)(void))success failure:(void(^)(NSError *error))failure;

/**
 *  开始游戏
 */
- (void)startGame;

/**
 *  开始排队
 */
- (void)startQueue;

/**
 *  取消排队
 */
- (void)cancelQueue;

/**
 *  退出房间时先关闭websocket
 */
- (void)closeWebSocket;

/**
 *  发送游戏指令
 *
 *  @param operation    XHPlayerOperation枚举值，注意按下与释放必须成对发送，用户按下时发送Press结尾的枚举值，松开时发送Release结尾的枚举值
 */
- (void)sendOperation:(XHPlayerOperation)operation;

/**
 *  打印websocket通信消息体
 *  所有相关打印均在消息体附加了 “Panda:” 的前缀
 */
- (void)printWebsocketMsg;

@end
