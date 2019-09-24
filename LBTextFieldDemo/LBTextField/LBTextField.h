//
//  LBTextField.h
//  LBTextField
//
//  Created by 刘彬 on 16/3/28.
//  Copyright © 2016年 刘彬. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LBInputType) {
    LBBankCardInput = 1,
    LBMoneyInput,
    LBIDCardInput,
    LBMobileInput,
    LBIndateInput,//1212(12月12日)
    LBCVV2Input,
    LBCodeInput,
    LBPasswordInput,
    LBPayPasswordInput,
    LBPercentInput
};
@interface LBTextField : UITextField
@property(nonatomic,assign)LBInputType lb_inputType;//设置对应type，将便利设置一些默认属性
//例如电话号码@[@3,@" ",@4,@" ",@4]，181 0808 8888
//数字代表该位置字符串长度，空格代表分隔符，你也可以用任何字符当作该分隔符，如@[@3,@"，",@4,@"#",@4]，181，0808#8888
//任意长度用@INT_MAX代替且一个Format有且只能出现一个@INT_MAX；如如@[@3,@"，",@INT_MAX,@"#",@4]，181，0845312408#8888
@property(nonatomic,strong)NSArray *lb_textFormatter;
@property(nonatomic,strong)NSPredicate *lb_inputPredicate;//输入限制，当前输入的字符不属于该Predicate的时候将限制输入
@property(nonatomic,strong)NSPredicate *lb_textPredicate;//TextField输入完成的Predicate，用以验证数据格式是否正确，它将和lb_textError相对
@property(nonatomic,readonly,strong)NSError *lb_textError;
@property(nonatomic,strong)NSNumber *lb_maxLength;//对应每个lb_inputType有其默认值
@property(nonatomic,strong)NSArray<NSString *> *unablePerformActions;//不响应的方法列表 (例如：NSStringFromSelector(@selector(paste:))--->禁止粘贴)

-(NSString *)mayDelimiterText;//可能有分隔符号的原text
+(BOOL)textField:(LBTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end


