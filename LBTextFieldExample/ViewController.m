//
//  ViewController.m
//  LBTextFieldDemo
//
//  Created by 刘彬 on 2019/9/24.
//  Copyright © 2019 刘彬. All rights reserved.
//

#import "ViewController.h"
#import "LBTextField.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"LBTextField";
    
    LBTextField *textField = [[LBTextField alloc] initWithFrame:CGRectMake(20, 200, CGRectGetWidth(self.view.frame)-20*2, 50)];
    textField.layer.borderColor = [UIColor grayColor].CGColor;
    textField.layer.cornerRadius = 10;
    textField.layer.borderWidth = 1;
    textField.placeholder = @"请输入手机号";
    textField.lb_maxLength = @11;
    textField.lb_inputPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[0-9]*"];//只能输入数字 ＝ textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.lb_textPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^1(\\d{10})"];//输入格式为1开头的11位数字的时候lb_textError=nil;
//    textField.lb_inputType = LBMobileInput;//以上所有自定义的设置你也可以快捷的直接设置type为LBMobileInput
    textField.lb_textFormatter = @[@3,@" ",@4,@" ",@4];//比如188 8888 8888
    [self.view addSubview:textField];
}
@end
