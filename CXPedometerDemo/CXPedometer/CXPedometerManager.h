//
//  CXPedometerManager.h
//  CXPedometerDemo
//
//  Created by 陈晓辉 on 2018/10/21.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CXPedometerData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 *  计步器管理类
 */

typedef void (^CXPedometerHandler)(CXPedometerData *pedometerData, NSError *error);

@interface CXPedometerManager : NSObject

+ (CXPedometerManager *)shared;

/**
 计步器是否可以使用
 
 @return YES or NO
 */
+ (BOOL)isStepCountingAvailable;

/**
 查询某时间段的行走数据
 
 @param start   开始时间
 @param end     结束时间
 @param handler 查询结果
 */
- (void)queryPedometerDataFromDate:(NSDate *)start
                            toDate:(NSDate *)end
                       withHandler:(CXPedometerHandler)handler;

/**
 监听今天（从零点开始）的行走数据
 
 @param handler 查询结果、变化就更新
 */
- (void)startPedometerUpdatesTodayWithHandler:(CXPedometerHandler)handler;

/**
 停止监听运动数据
 */
- (void)stopPedometerUpdates;


/*
 运动状态 及运动速度
 
 CMMotionActivity
 
 此对象包含了运动事件的数据。在支持动作识别的设备上，你可以使用 CMMotionActivityManager 去查询当前运动状态的改变。当运动状态改变发生时，更新的信息会被打包成 CMMotionActivity 对象，并发给到你的 app。
 
 运动类型：
 
 stationary 静止
 walking 走路
 running 跑步
 automotive 开车
 unknown 未知
 
 运动数据:
 
 startDate 运动的开始时间
 confidence 运动强度
 
 @param handler 运动状态 及运动速度
 */
- (void)motionStateWithHandler:(CXPedometerHandler)handler;

@end

NS_ASSUME_NONNULL_END
