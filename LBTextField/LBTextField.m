//
//  FLBTextField.m
//  LBTextField
//
//  Created by 刘彬 on 16/3/28.
//  Copyright © 2016年 刘彬. All rights reserved.
//

#import "LBTextField.h"
@interface LBTextField ()<UITextFieldDelegate>
@property (nonatomic,strong)NSObject<UITextFieldDelegate> *realProxy;//真实代理（LBTextField本身作为消息转发虚拟代理）
@property (nonatomic,strong)NSArray *partFirstFormat;//@INT_MAX之前的称为partFirst
@property (nonatomic,strong)NSArray *partSecondReverseFormat;
@property (nonatomic,strong)NSArray<NSString *> *allDelimiters;
@property (nonatomic,strong)NSArray<NSString *> *partFirstDelimiters;
@property (nonatomic,strong)NSArray<NSString *> *partSecondReverseDelimiters;
@property (nonatomic,strong)NSMutableArray<NSString *> *partFirstNoneDelimiterRanges;
@property (nonatomic,strong)NSMutableArray<NSString *> *partSecondReverseNoneDelimiterRanges;//取真实text时候需要去掉分隔符的range

@property (nonatomic,strong)NSMutableArray<NSString *> *partFirstDelimiterRanges;
@property (nonatomic,strong)NSMutableArray<NSString *> *partSecondReverseDelimiterRanges;////格式化输入的时候需要插入分隔符的range

@property (nonatomic, strong) NSString *currentChangedRange;
@property (nonatomic, strong) NSString *currentChangedString;
@end

@implementation LBTextField

- (instancetype)init
{
    self = [[self.class alloc] initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        [super setDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self];
    }
    return self;
}
-(void)setDelegate:(id<UITextFieldDelegate>)delegate{
    self.realProxy = delegate;
    [super setDelegate:self];
}
-(void)setText:(NSString *)text{
    [super setText:text];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
}

-(void)setLb_textFormatter:(NSArray *)lb_textFormatter{
    _lb_textFormatter = lb_textFormatter;
    
    typeof(self) __weak weakSelf = self;
    
    _partFirstFormat = _lb_textFormatter;
    if ([_lb_textFormatter containsObject:@INT_MAX]) {
        NSUInteger uncertainFormatIndex = [_lb_textFormatter indexOfObject:@INT_MAX];
        _partFirstFormat = [_lb_textFormatter subarrayWithRange:NSMakeRange(0, uncertainFormatIndex)];
        _partSecondReverseFormat = [[_lb_textFormatter subarrayWithRange:NSMakeRange(uncertainFormatIndex+1, _lb_textFormatter.count-uncertainFormatIndex-1)] reverseObjectEnumerator].allObjects;
    }
    
    _allDelimiters = [_lb_textFormatter filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:NSString.self];
    }]];
    
    _partFirstDelimiters = [_partFirstFormat filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:NSString.self];
    }]];
    _partSecondReverseDelimiters = [_partSecondReverseFormat filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:NSString.self];
    }]];
    
    
    __block NSUInteger summation = 0;
    _partFirstNoneDelimiterRanges = [NSMutableArray array];
    [_partFirstFormat enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSString.self]) {
            [weakSelf.partFirstNoneDelimiterRanges addObject:NSStringFromRange(NSMakeRange(summation, [obj length]))];
        }else if ([obj isKindOfClass:NSNumber.self]){
            summation += [obj integerValue];//当替换下一个的时候上一个已经被替换了，所以要去掉分隔符的长度
        }
    }];
    
    summation = 0;
    _partSecondReverseNoneDelimiterRanges = [NSMutableArray array];
    [_partSecondReverseFormat enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSString.self]) {
            [weakSelf.partSecondReverseNoneDelimiterRanges addObject:NSStringFromRange(NSMakeRange(summation+[obj length], [obj length]))];//因为location是从前面算，所以location加上length
        }else if ([obj isKindOfClass:NSNumber.self]){
            summation += [obj integerValue];//当替换下一个的时候上一个已经被替换了，所以要去掉分隔符的长度
        }
    }];
    
    //*************************
    summation = 0;
    _partFirstDelimiterRanges = [NSMutableArray array];
    [_partFirstFormat enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSString.self]) {
            [weakSelf.partFirstDelimiterRanges addObject:NSStringFromRange(NSMakeRange(summation, [obj length]))];
        }
        summation += [obj isKindOfClass:NSNumber.self]?[obj integerValue]:[obj length];
    }];
    
    
    summation = 0;
    _partSecondReverseDelimiterRanges = [NSMutableArray array];
    [_partSecondReverseFormat enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSString.self]) {
            [weakSelf.partSecondReverseDelimiterRanges addObject:NSStringFromRange(NSMakeRange(summation, [obj length]))];
        }
        summation += [obj isKindOfClass:NSNumber.self]?[obj integerValue]:[obj length];//当insert下一个的时候上一个已经insert了，所以要加上分隔符的长度
    }];
}

-(void)setKeyboardType:(UIKeyboardType)keyboardType{
    [super setKeyboardType:keyboardType];
    if (keyboardType == UIKeyboardTypeNumberPad) {
        if (_lb_inputPredicate == nil) {
            _lb_inputPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[0-9]*"];
        }
    }
    else if (keyboardType == UIKeyboardTypeDecimalPad){
        if (_lb_inputPredicate == nil) {
            _lb_inputPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[.0-9]*"];
        }
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if ([self.unablePerformActions containsObject:NSStringFromSelector(action)]) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

-(void)setLb_maxLength:(NSNumber *)lb_maxLength{
    _lb_maxLength = lb_maxLength;
    switch (_lb_inputType) {
        case LBCodeInput:
        case LBPayPasswordInput:
        case LBCVV2Input:
        case LBIndateInput:
            if (_lb_textPredicate == nil) {
                _lb_textPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", [NSString stringWithFormat:@"\\d{%lu}",_lb_maxLength.unsignedIntegerValue]];
            }
            break;
        default:
            break;
    }
}

-(void)setLb_inputType:(LBInputType)lb_inputType{
    _lb_inputType = lb_inputType;
    switch (lb_inputType) {
        case LBMobileInput:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(11);
            }
            if (_lb_textPredicate == nil) {
                _lb_textPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^1(\\d{10})"];
            }
            break;
        case LBBankCardInput:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(20);
            }
            if (_lb_textPredicate == nil) {
                _lb_textPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(\\d{14,20})"];
            }
            break;
        case LBCVV2Input:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(3);
            }
            break;
        case LBCodeInput:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(6);
            }
            break;
        case LBPayPasswordInput:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(6);
            }
            break;
        case LBIndateInput:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(4);
            }
            break;
        case LBPercentInput:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(4);
            }
            if (_lb_textPredicate == nil) {
                _lb_textPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(\\d?\\d(\\.\\d*)?|100)$"];
            }
            break;
        case LBMoneyInput:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(15);
            }
            if (_lb_textPredicate == nil) {
                _lb_textPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]+(.[0-9]{1,2})?$"];
            }
            break;
        case LBPasswordInput:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(16);
            }
            if (_lb_textPredicate == nil) {
                _lb_textPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(?![a-zA-Z0-9]+$)(?![^a-zA-Z/D]+$)(?![^0-9/D]+$).{8,16}$"];
            }
            break;
        case LBIDCardInput:
            if (_lb_maxLength == nil) {
                _lb_maxLength = @(18);
            }
            if (_lb_inputPredicate == nil) {
                _lb_inputPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9]*$"];
            }
            if (_lb_textPredicate == nil) {
                _lb_textPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(\\d{14}|\\d{17})(\\d|[xX])$"];
            }
            break;
        default:
            break;
    }
}

-(NSError *)lb_textError{
    NSString *text = self.text;
    NSString *errorDescription = nil;
    if (!text.length){
        errorDescription = [self.placeholder rangeOfString:@"输入"].length?self.placeholder:[NSString stringWithFormat:@"请输入%@",self.placeholder];
    }else{
        switch (self.lb_inputType) {
            case LBBankCardInput:
                if (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text]){
                    errorDescription = @"银行卡号格式错误";
                }
                break;
            case LBMoneyInput:
                if (![text floatValue] || (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text])) {
                    errorDescription = @"请输入有效金额";
                }
                break;
            case LBIDCardInput:
                if (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text]){
                    errorDescription = @"身份证号码格式错误";
                }
                break;
            case LBMobileInput:
                if (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text]){
                    errorDescription = @"手机号码格式错误";
                }
                break;
            case LBCodeInput:
                if (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text]){
                    errorDescription = @"验证码格式错误";
                }
                break;
            case LBIndateInput:
                if (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text]) {
                    errorDescription = @"有效期格式错误";
                }else if ((text.length < 4 || [[text substringToIndex:2] integerValue] > 12 || [[text substringToIndex:2] integerValue] == 0 || [[text substringFromIndex:2] integerValue] > 31 || [[text substringFromIndex:2] integerValue] == 0)){
                    errorDescription = @"有效期格式错误";
                }
                break;
            case LBCVV2Input:
                if (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text]) {
                    errorDescription = @"安全码格式错误";
                }else if (text.length < 3){
                    errorDescription = @"安全码格式错误";
                }
                break;
            case LBPasswordInput:
                if (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text]) {
                    errorDescription = @"密码格式错误";
                }
                break;
            case LBPayPasswordInput:
                if (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text]) {
                    errorDescription = @"支付密码格式错误";
                }else{
                    NSUInteger index = 0;
                    BOOL isNotAllEnqual = NO;
                    while ((!isNotAllEnqual) && (index+1) < text.length) {
                        if ([[text substringWithRange:NSMakeRange(index, 1)] isEqualToString:[text substringWithRange:NSMakeRange(index+1, 1)]]) {
                            index ++;
                        }else{
                            isNotAllEnqual = YES;
                        }
                    }
                    
                    NSUInteger index2 = 0;
                    BOOL isNotAscending = NO;
                    while ((!isNotAscending) && (index2+1) < text.length) {
                        if ([[text substringWithRange:NSMakeRange(index2, 1)] integerValue] + 1 == [[text substringWithRange:NSMakeRange(index2+1, 1)] integerValue]) {
                            index2 ++;
                        }else{
                            isNotAscending = YES;
                        }
                    }
                    
                    NSUInteger index3 = 0;
                    BOOL isNotDescending = NO;
                    while ((!isNotDescending) && (index3+1) < text.length) {
                        if ([[text substringWithRange:NSMakeRange(index3, 1)] integerValue] - 1 == [[text substringWithRange:NSMakeRange(index3+1, 1)] integerValue]) {
                            index3 ++;
                        }else{
                            isNotDescending = YES;
                        }
                    }
                    
                    if ((!isNotAllEnqual || !isNotAscending || !isNotDescending || [text isEqualToString:@"123456"] ||  [text isEqualToString:@"654321"])) {
                        errorDescription = @"为了您的账户安全，请避免输入过于简单的支付密码";
                    }
                }
                
                break;
            default:
                if (_lb_textPredicate && ![_lb_textPredicate evaluateWithObject:text]){
                    errorDescription = @"输入格式错误";
                }
                break;
        }
    
    }
    NSError *inputError = nil;
    if (errorDescription) {
        inputError = [NSError errorWithDomain:@"LBInputError" code:6666 userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
    }
    return inputError;
}

-(NSString *)text{
    return [self noneDelimiterString:[super text]];
}
-(NSString *)mayDelimiterText{
    return [super text];
}

-(NSString *)noneDelimiterString:(NSString *)string{
    if (_lb_textFormatter) {
        typeof(self) __weak weakSelf = self;
        
        __block NSString *text = string.copy;
        [_partFirstNoneDelimiterRanges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = NSRangeFromString(obj);
            if (range.location+range.length <= text.length) {
                if ([[text substringWithRange:range] isEqualToString:weakSelf.partFirstDelimiters[idx]]) {
                    text = [text stringByReplacingCharactersInRange:NSRangeFromString(obj) withString:@""];
                }
                
            }
        }];
        
        [_partSecondReverseNoneDelimiterRanges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = NSRangeFromString(obj);
            NSInteger location = text.length-NSRangeFromString(obj).location;
            range.location = (location<0?0:location);

            if (range.location+range.length <= text.length) {

                if ([[text substringWithRange:range] isEqualToString:weakSelf.partSecondReverseDelimiters[idx]]) {
                    text = [text stringByReplacingCharactersInRange:range withString:@""];
                }
            }
        }];
        return text;
    }
    return string;
}

-(BOOL)textField:(LBTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.lb_textFormatter == nil) {
        //当有lb_textFormatter的时候因为又要进行手动添加分隔符，所以无法判断真正的replacementString
        textField.currentChangedRange = NSStringFromRange(range);
        textField.currentChangedString = string;
    }
    
    //如果真实代理实现了这个代理方法优先考虑真实代理的返回值，所谓用者至上
    if ([textField.realProxy respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        BOOL realProxyReturnVuale = [textField.realProxy textField:textField shouldChangeCharactersInRange:range replacementString:string];
        if (!realProxyReturnVuale) {
            return realProxyReturnVuale;
        }
    }
    
    if (textField.markedTextRange!=nil) {
        return YES;
    }
    
    
    __block NSMutableString *text = textField.text.mutableCopy;
    //@INT_MAX之前的称为第一部分
    //1.转移操作对象到没有分隔符的text上
    //2.再将没有分隔符的text加上分隔符赋值给textField
    
    if (string.length &&
        textField.lb_maxLength &&
        (text.length >= textField.lb_maxLength.integerValue)){//输入的时候长度已满限制输入
        if (text.length > textField.lb_maxLength.integerValue) {
            textField.text = [text substringToIndex:textField.lb_maxLength.integerValue];
        }
        return NO;
    }
    else if (textField.lb_textFormatter){
        UITextPosition *position =textField.selectedTextRange.end;
        
        //textField的原text
        NSString *mayDelimiterText = [textField mayDelimiterText];
        
        //第一部分带分隔符的text最后一个range，用于计算第一部分的长度
        NSRange partFirstLastDeliniterRange =  NSRangeFromString(textField.partFirstDelimiterRanges.lastObject);
        
        NSMutableArray<NSString *> *allDelimiterRanges  = textField.partFirstDelimiterRanges.mutableCopy;
        NSMutableArray *partSecondReverseDelimiterRealRanges = [NSMutableArray array];
        [textField.partSecondReverseDelimiterRanges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = NSRangeFromString(obj);
            NSInteger location = mayDelimiterText.length-range.location-range.length;
        //第一部分的长度加上第二部分当前range的长度得出如果有第二部分当前分隔符mayDelimiterText要满足的最低长度
            NSInteger havePartSecondMinLenght =
            partFirstLastDeliniterRange.location
            +partFirstLastDeliniterRange.length
            +NSRangeFromString(obj).location
            +NSRangeFromString(obj).length;
            if (mayDelimiterText.length > havePartSecondMinLenght) {
                range.location = location;
                [partSecondReverseDelimiterRealRanges addObject:NSStringFromRange(range)];
                
            }
        }];
        //将倒序的ranges正序排列
        [allDelimiterRanges addObjectsFromArray:partSecondReverseDelimiterRealRanges.reverseObjectEnumerator.allObjects];
        //当用户删除或者替换的range包含分隔符，将整个分隔符一起替换，所以将重新计算range
        __block NSRange newRange = range;
        [allDelimiterRanges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange delimiterRange = NSRangeFromString(obj);
            if (NSIntersectionRange(delimiterRange, range).length) {
            //找出第一个和分隔符的交集的位置，如果该位置小于当前操作的range，应该分隔符的location作为新location
                if (delimiterRange.location < newRange.location) {
                    newRange.location = delimiterRange.location;
                }
                *stop = YES;
            }
        }];
        
        
        __block NSUInteger deletedDelimiterLenth = 0;
        [allDelimiterRanges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange delimiterRange = NSRangeFromString(obj);
            if (NSIntersectionRange(delimiterRange, range).length) {
            //找出最后一个有交集的分隔符的endLocation,如果改endLocation位置大于当前操作的range的endLocation，用该endLocation作为新的range的endLocation
                if (delimiterRange.location+delimiterRange.length > newRange.location+newRange.length) {
                    newRange.length = (delimiterRange.location+delimiterRange.length - newRange.location);
                    
                }
                deletedDelimiterLenth += [mayDelimiterText substringWithRange:delimiterRange].length;
            }
        }];
        //因为是对去掉分隔符的text进行操作，所以找出修改区域的分隔符，去掉其长度
        newRange.length -= deletedDelimiterLenth;
        
        NSString *frontRealText = [mayDelimiterText substringToIndex:range.location];
        //还要找出操作range之前里面的分隔符总长度并去掉，算出该range的准确location
        [allDelimiterRanges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = NSRangeFromString(obj);
            if (range.location+range.length <= frontRealText.length) {
                newRange.location -= [frontRealText substringWithRange:range].length;
            }
        }];
        
        [text replaceCharactersInRange:newRange withString:string];
        
        
        if (textField.lb_maxLength && (text.length>textField.lb_maxLength.integerValue)) {
            text = [text substringToIndex:textField.lb_maxLength.integerValue].mutableCopy;
        }
        
        __weak typeof(textField) weakTextField = textField;
        //重新排列新字符串
        [textField.partFirstDelimiterRanges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = NSRangeFromString(obj);
            if (range.location < text.length) {
                [text insertString:weakTextField.partFirstDelimiters[idx] atIndex:range.location];
            }
        }];
        
        
        
        [textField.partSecondReverseDelimiterRanges enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = NSRangeFromString(obj);
            NSUInteger location = text.length-range.location;
            NSInteger partFirstLenght = (partFirstLastDeliniterRange.location+partFirstLastDeliniterRange.length)+range.location;
            if (text.length > partFirstLenght) {
                [text insertString:weakTextField.partSecondReverseDelimiters[idx] atIndex:location];
            }
        }];
        
        //重新赋值新的带分隔符的text
        textField.text = text;
        
        UITextPosition *newPosition = [textField positionFromPosition:position offset:text.length-mayDelimiterText.length];
        
        if (newPosition) {
            dispatch_async(dispatch_get_main_queue(), ^{
                textField.selectedTextRange = [textField textRangeFromPosition:newPosition toPosition:newPosition];
            });
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
        return NO;
    }
    else if (textField.lb_maxLength && ([text stringByReplacingCharactersInRange:range withString:string].length > textField.lb_maxLength.integerValue)){//输入的时候长度大于限制长度
        
        textField.currentChangedString = [string substringToIndex:textField.lb_maxLength.integerValue-text.length];//当前输入的加上之前的text超过maxLength的时候由于要被截取，所以实际的currentChangedString要比当前输入的短
        
        UITextPosition *position =textField.selectedTextRange.start;
        
        NSUInteger differLength = textField.lb_maxLength.integerValue-[text stringByReplacingCharactersInRange:range withString:@""].length;
        textField.text = [text stringByReplacingCharactersInRange:range withString:[string substringToIndex:differLength]];
        
        UITextPosition *aNewPosition = [textField positionFromPosition:position offset:differLength];
        if (aNewPosition) {
            dispatch_async(dispatch_get_main_queue(), ^{
                textField.selectedTextRange = [textField textRangeFromPosition:aNewPosition toPosition:aNewPosition];
            });
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
        return NO;
    }
    
    if (string.length &&
        (textField.lb_inputType == LBMoneyInput ||
         textField.lb_inputType == LBPercentInput)){//金额输入的时候特殊处理
        if ([textField.text isEqualToString:@"0"] && ![string isEqualToString:@"."]) {
            return NO;
        }else if (!textField.text.length && [string isEqualToString:@"."]){
            textField.text = @"0";
            return YES;
        }else if ([textField.text rangeOfString:@"."].length){
            if ([[textField.text componentsSeparatedByString:@"."] lastObject].length >=2) {
                return NO;
            }else if ([string isEqualToString:@"."]){
                return NO;
            }
        }
    }
    return YES;
}
-(void)textDidChange:(NSNotification *)notificaion{//ios13之前系统键盘联想出来的字符输入不会走shouldChangeCharactersInRange代理方法，所以需要该方法容错支撑
    LBTextField *textField = notificaion.object;
    if (textField.markedTextRange == nil) {
        if (textField.currentChangedRange) {
            NSRange range = NSRangeFromString(textField.currentChangedRange);
            textField.currentChangedRange = nil;
            if (textField.currentChangedString.length && (textField.lb_inputPredicate && ![textField.lb_inputPredicate evaluateWithObject:textField.currentChangedString])) {//输入的格式不符合限制输入
                if (range.location+textField.currentChangedString.length<=textField.mayDelimiterText.length &&
                    [[textField.mayDelimiterText substringWithRange:NSMakeRange(range.location, textField.currentChangedString.length)] isEqualToString:textField.currentChangedString]) {
                    textField.text = [textField.mayDelimiterText stringByReplacingCharactersInRange:NSMakeRange(range.location, textField.currentChangedString.length) withString:@""];
                }
            }
        }
        
        if (textField.lb_maxLength && (textField.text.length > textField.lb_maxLength.integerValue)){//输入的时候长度已满切断
            textField.text = [textField.text substringToIndex:textField.lb_maxLength.integerValue];
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//如果本类没实现的代理方法由realProxy实现
- (BOOL)respondsToSelector:(SEL)aSelector{
    BOOL respondsSelector = [super respondsToSelector:aSelector];
    if (!respondsSelector && [self.realProxy respondsToSelector:aSelector]) {
        return YES;
    }
    return respondsSelector;
}
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (![super respondsToSelector:aSelector] && [self.realProxy respondsToSelector:aSelector]) {
        return self.realProxy;
    }
    return [super forwardingTargetForSelector: aSelector];
}
@end
