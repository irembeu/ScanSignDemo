//
//  ViewController.m
//  ScanDemo
//
//  Created by lgj on 2018/3/6.
//  Copyright © 2018年 lgj. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.title = @"首页";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, 150, 80, 40);
    [btn setTitle:@"开始扫描" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)jump {
    ScanViewController *vc = [[ScanViewController alloc] init];
    vc.resultBlock = ^(NSString *value) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:value message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    };
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
