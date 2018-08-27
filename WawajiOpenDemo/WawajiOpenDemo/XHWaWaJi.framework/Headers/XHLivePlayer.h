//
//  XHLivePlayer.h
//  XHLive
//
//  Created by mikey on 2018/7/5.
//  Copyright © 2018年 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XHLivePlayerType){
    XHLivePlayerTypeWawaji,
    XHLivePlayerTypeUser
};

@protocol XHLivePlayerDelegate<NSObject>

- (void)livePlayerBegin:(NSString *)url;

@end

@interface XHLivePlayer : NSObject

@property (nonatomic, strong) NSString *test;

/**
 *  管理类单例
 */
+(instancetype)sharedManager;

/**
 *  添加娃娃机摄像头直播
 */
- (void)addWawajiLive:(NSArray *)urls rootView:(UIView *)rootView;

/**
 *  添加用户摄像头直播地址
 */
- (void)addUserLive:(NSString *)url rootView:(UIView *)rootView;

/**
 *  设置显示的摄像头下标， 0 => 正面, 1 => 侧面
 */
- (void)setLiveIndex:(NSInteger)index;

/**
 *  切换摄像头位置，并返回切换后的摄像头下标， 0 => 正面, 1 => 侧面
 *  @param index    指定切换摄像头的下标，如果需要自动切换，传入nil既可
 */
- (NSNumber *)switchCamera:(NSNumber *)index;
//- (NSInteger)switchCamera;

/**
 *  获取当前显示的摄像头下标
 */
- (NSInteger)getCameraIndex;

/**
 *  暂停所有直播
 */
- (void)pausePlayers;

/**
 *  恢复所有直播
 */
- (void)resumePlayers;

/**
 *  退出页面前需要主动调用销毁方法
 */
- (void)destroyPlayers;

//- (void)enableLog:(BOOL)enable;

/**
 *  设置监听对象
 */
- (void)setLiveListener:(id)listener;

@end
