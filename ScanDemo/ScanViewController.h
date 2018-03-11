//
//  ScanViewController.h
//  ScanDemo
//
//  Created by lgj on 2018/3/6.
//  Copyright © 2018年 lgj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanViewController : UIViewController

@property (nonatomic, copy) void(^resultBlock)(NSString *value);

@end
