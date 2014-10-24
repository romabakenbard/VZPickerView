//
//  VZViewController.m
//  VZPickerView
//
//  Created by Alekseenko Oleg on 25.08.14.
//  Copyright (c) 2014 alekoleg. All rights reserved.
//

#import "VZViewController.h"
#import "VZPickerView.h"

@interface VZViewController ()

@end

@implementation VZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 100, 50)];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"Показать" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)showPicker:(id)sender {
    
    [VZPickerView showDatePickerInView:sender minDate:nil maxDate:nil currentDate:[NSDate date] complete:^(NSDate *selected) {
        
    }];
}
@end
