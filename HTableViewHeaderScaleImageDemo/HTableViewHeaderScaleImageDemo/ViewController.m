//
//  ViewController.m
//  HTableViewHeaderScaleImageDemo
//
//  Created by hejunsong on 16/12/15.
//  Copyright © 2016年 hjs. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+HHeaderScaleImage.h"
@interface ViewController ()


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置tableView头部缩放图片
    self.tableView.h_headerScaleImage = [UIImage imageNamed:@"header"];
    
    // 设置tableView头部视图，必须设置头部视图背景颜色为clearColor,否则会被挡住
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
