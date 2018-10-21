//
//  CXPedometerManager.m
//  CXPedometerDemo
//
//  Created by 陈晓辉 on 2018/10/21.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXPedometerManager.h"

#import <CoreMotion/CoreMotion.h>

@interface CXPedometerManager ()

@property(nonatomic, strong) CMPedometer *pedometer;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation CXPedometerManager

+ (CXPedometerManager *)shared {
    
    static CXPedometerManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        if ([CMPedometer isStepCountingAvailable]) {
            self.pedometer = [[CMPedometer alloc] init];
        }
    }
    return self;
}

/**
 计步器是否可以使用

 @return YES or NO
 */
+ (BOOL)isStepCountingAvailable {
    
    return [CMPedometer isStepCountingAvailable];
}

/**
 查询某时间段的行走数据

 @param start 开始时间
 @param end 结束时间
 @param handler 查询结果
 */
- (void)queryPedometerDataFromDate:(NSDate *)start
                            toDate:(NSDate *)end
                       withHandler:(CXPedometerHandler)handler {
    
    [_pedometer queryPedometerDataFromDate:start toDate:end withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        
        //只走一遍,不会实时刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //获取运动数据
            CXPedometerData *customPedometerData = [[CXPedometerData alloc] init];
            customPedometerData.numberOfSteps = pedometerData.numberOfSteps;
            customPedometerData.distance = pedometerData.distance;
            customPedometerData.floorsAscended = pedometerData.floorsAscended;
            customPedometerData.floorsDescended = pedometerData.floorsDescended;
            
            //
            handler(customPedometerData, error);
        });
    }];
}

/**
 监听今天（从零点开始）的行走数据

 @param handler 查询结果、变化就更新
 */
- (void)startPedometerUpdatesTodayWithHandler:(CXPedometerHandler)handler {
    
    /*
     第一种:
     NSDate *date = [NSDate date];
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"yyyy-MM-dd"];
     // 开始日期
     NSDate *startDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:date]];
     */
    /*
     第二种:
     NSCalendar *calendar = [NSCalendar currentCalendar];
     NSDate *now = [NSDate date];
     NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
     // 开始日期
     NSDate *startDate = [calendar dateFromComponents:components];
     // 结束日期
     NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
     */
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    // 开始日期
    NSDate *startDate = [calendar dateFromComponents:components];
    // 结束日期
    //NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    [_pedometer startPedometerUpdatesFromDate:startDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        
        //只走一遍,不会实时刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //获取运动数据
            CXPedometerData *customPedometerData = [[CXPedometerData alloc] init];
            customPedometerData.numberOfSteps = pedometerData.numberOfSteps;
            customPedometerData.distance = pedometerData.distance;
            customPedometerData.floorsAscended = pedometerData.floorsAscended;
            customPedometerData.floorsDescended = pedometerData.floorsDescended;
            
            //
            handler(customPedometerData, error);
        });
    }];
}

/**
 停止监听运动数据
 */
- (void)stopPedometerUpdates {
    
    [_pedometer stopPedometerUpdates];
}

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
- (void)motionStateWithHandler:(CXPedometerHandler)handler {
    
    if ([CMMotionActivityManager isActivityAvailable]) {
        
        CMMotionActivityManager *motionManager = [[CMMotionActivityManager alloc] init];
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        [motionManager startActivityUpdatesToQueue:operationQueue withHandler:^(CMMotionActivity * _Nullable activity) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //开始运动时间
                NSDate *startDate = activity.startDate;
                //运动状态
                NSString *status = [self statusForActivity:activity];
                //运动速度
                NSString *confidence = [self stringFromConfidence:activity.confidence];
                
                //获取运动数据
                CXPedometerData *customPedometerData = [[CXPedometerData alloc] init];
                customPedometerData.startDate = startDate;
                customPedometerData.status = status;
                customPedometerData.confidence = confidence;
                
                //
                NSError *error;
                handler(customPedometerData, error);
            });
        }];
    }
}
//MARK: 移动状态
- (NSString *)statusForActivity:(CMMotionActivity *)activity {
    
    NSMutableString *status = @"".mutableCopy;
    
    //True if the device is not moving.静止
    if (activity.stationary) {
        
        [status appendString:@"not moving"];
    }
    
    //True if the device is on a walking person.行走
    if (activity.walking) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"on a walking person"];
    }
    
    //True if the device is on a running person.跑步
    if (activity.running) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"on a running person"];
    }
    
    //True if the device is in a vehicle. 机动车辆
    if (activity.automotive) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"in a vehicle"];
    }
    
    //True if the device is on a bicycle.自行车
    if (activity.cycling) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"in a cycling"];
    }
    
    //True if there is no estimate of the current state.  This can happen if the device was turned off. 关闭设备
    if (activity.unknown || !status.length) {
        
        [status appendString:@"unknown"];
    }
    
    return status;
}
//MARK: 速度快慢
- (NSString *)stringFromConfidence:(CMMotionActivityConfidence)confidence {
    
    switch (confidence) {
            
        case CMMotionActivityConfidenceLow:
            
            return @"Low";
            
        case CMMotionActivityConfidenceMedium:
            
            return @"Medium";
            
        case CMMotionActivityConfidenceHigh:
            
            return @"High";
            
        default:
            
            return nil;
    }
}

@end
