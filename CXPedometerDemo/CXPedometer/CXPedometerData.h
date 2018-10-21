//
//  CXPedometerData.h
//  CXPedometerDemo
//
//  Created by 陈晓辉 on 2018/10/21.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 计步器数据实体
 */
@interface CXPedometerData : NSObject

/****************  计步 方法使用参数  **********************/

/**
 步数,iOS7及iOS7以下只有numberOfSteps
 */
@property(nonatomic, strong, nullable) NSNumber *numberOfSteps;

/**
 步行+跑步距离
 */
@property(nonatomic, strong, nullable) NSNumber *distance;

/*
 上楼
 */
@property(nonatomic, strong, nullable) NSNumber *floorsAscended;

/*
 下楼
 */
@property(nonatomic, strong, nullable) NSNumber *floorsDescended;


/****************  motionStateWithHandler(运动状态 及运动速度) 方法使用参数  **********************/

/** 开始运动时间 */
@property (nonatomic, strong) NSDate *startDate;

/** 运动状态 */
@property (nonatomic, copy) NSString *status;

/** 运动速度 */
@property (nonatomic, copy) NSString *confidence;


@end

NS_ASSUME_NONNULL_END
