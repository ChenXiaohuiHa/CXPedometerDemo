//
//  ViewController.m
//  CXPedometerDemo
//
//  Created by 陈晓辉 on 2018/10/10.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "ViewController.h"


#import "CXPedometer/CXPedometerManager.h"

@interface ViewController ()

@property(nonatomic, strong) UILabel *stepsLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
    //查询某天的计步数据
    [self startPedometerUpdatesToday];
    //查询某个时间段计步数据
    [self queryPedometerDataFromDate];
    //运动状态和速度
    [self motionState];
}
- (void)setUpUI {
    
    self.stepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, [UIScreen mainScreen].bounds.size.width - 40,300)];
    _stepsLabel.numberOfLines = 5;
    _stepsLabel.backgroundColor = [UIColor redColor];
    _stepsLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_stepsLabel];
}

#pragma mark ---------- 查询某天的计步数据 ----------
- (void)startPedometerUpdatesToday {
    
    __weak ViewController *weakSelf = self;
    if ([CXPedometerManager isStepCountingAvailable]) {
        [[CXPedometerManager shared] startPedometerUpdatesTodayWithHandler:^(CXPedometerData *pedometerData, NSError *error) {
             if (!error) {
                 weakSelf.stepsLabel.text = [NSString
                                             stringWithFormat:@" 步数:%@\n 距离:%@\n 爬楼:%@\n 下楼:%@",
                                             pedometerData.numberOfSteps,
                                             pedometerData.distance,
                                             pedometerData.floorsAscended,
                                             pedometerData.floorsDescended];
             }
         }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"此设备不支持记步功能"
                                  message:@"仅支持iPhone5s及其以上设备"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}
#pragma mark ---------- 查询某个时间段计步数据 ----------
- (void)queryPedometerDataFromDate {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    // 开始日期
    NSDate *startDate = [calendar dateFromComponents:components];
    // 结束日期
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    __weak typeof(self) weakSelf = self;
    [[CXPedometerManager shared] queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CXPedometerData *pedometerData,NSError *error) {
         if (!error) {
             weakSelf.stepsLabel.text = [NSString
                                         stringWithFormat:
                                         @" 步数:%@\n 距离:%@\n 爬楼:%@\n 下楼:%@",
                                         pedometerData.numberOfSteps,
                                         pedometerData.distance,
                                         pedometerData.floorsAscended,
                                         pedometerData.floorsDescended];
         }
     }];
}

#pragma mark ---------- 运动状态和速度 ----------
- (void)motionState {
    
    __weak typeof(self) weakSelf = self;
    [[CXPedometerManager shared] motionStateWithHandler:^(CXPedometerData *pedometerData, NSError *error) {
        
        weakSelf.stepsLabel.text = [NSString stringWithFormat:@"\n %@\n %@\n %@",pedometerData.startDate,pedometerData.status,pedometerData.confidence];
    }];
}

@end
