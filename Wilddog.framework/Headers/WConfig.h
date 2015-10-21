//
//  WConfig.h
//  Wilddog
//
//  Created by junpengwang on 15/7/20.
//  Copyright (c) 2015年 Wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  默认配置
 */
@interface WConfig : NSObject

/**
 *  设置所有被触发事件的队列。默认队列为主队列。
 */
@property (nonatomic, strong) dispatch_queue_t callbackQueue;

@end
