//
//  UPPKeyboard.m
//  UPPayPlugin
//
//  Created by 王林 on 2018/8/31.
//  Copyright © 2018年 王林. All rights reserved.
//

#import "UPTKeyboard.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "UPPLineView.h"
#import "UIImage+UPTImage.h"

#define RGB(X,Y,Z) [UIColor colorWithRed:X/255.0 green:Y/255.0 blue:Z/255.0 alpha:1]
#define RGBa(X,Y,Z,a) [UIColor colorWithRed:X/255.0 green:Y/255.0 blue:Z/255.0 alpha:a]

#define UPColor_Line_Keyboard                       RGB(204,208,214)
#define UPColor_Keyboard_Normal                     RGB(0x33,0x33,0x33)
#define UPColor_Keyboard_HighLighted                RGB(0x66,0x66,0x66)
#define UPColor_Keyboard_Background_Normal          RGB(0xff,0xff,0xff)
#define UPColor_Keyboard_Background_HighLighted     RGB(0xcf,0xde,0xec)

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define __kScreenHeight ([[UIScreen mainScreen]bounds].size.height)
#define __kScreenWidth ([[UIScreen mainScreen]bounds].size.width)
#define SCREEN_MIN_LENGTH (MIN(__kScreenWidth, __kScreenHeight))
#define SCREEN_MAX_LENGTH (MAX(__kScreenWidth, __kScreenHeight))
#define IS_IPHONEX (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

#define KKeyNumbers         10
#define KFont               30
#define KFont_Title         14
//#define KHeight_Board       274
#define kHeight_Title       0
#define kSecret             @"*"
#define kHeight_Line_Common              1
#define _keyHeight  60
#define _keyWidth   (CGRectGetWidth(self.frame) / 3)
#define kLOCALE_EN               @"en"
#define kKeyboardDoneCH          @"完成"
#define kKeyboardDoneEN          @"DONE"
#define kSyslocalekey            @"AppleLanguages"

#define kUPTAESKeyLength               16

static CGFloat displayWidth() {
    return [UIScreen mainScreen].bounds.size.width;
}

@interface UPTKeyboard()

@property (nonatomic, strong) UIView* keyboardView;
@property (nonatomic, strong) NSMutableArray *rowLines;
@property (nonatomic, strong) NSMutableArray *mKeyArray;
@property (nonatomic, strong) NSMutableArray *passwordArray; //存储加密密码数组
@property (nonatomic, strong) NSString *randAesKey;
@property int lengthOfPin;
@property float keyboardHeight;

@end

@implementation UPTKeyboard

- (instancetype)initWithDoneButton:(BOOL)needDoneButton
{
    _keyboardHeight = 240;
    if(IS_IPHONEX) {
        _keyboardHeight = 274;
    }
    
    CGRect frame = CGRectMake(0, 0, displayWidth(), _keyboardHeight +kHeight_Title);
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];
        _needDoneButton = needDoneButton;
        _lengthOfPin = 6;
        _randAesKey = [self randStr:kUPTAESKeyLength];
        self.passwordArray = [[NSMutableArray alloc] initWithCapacity:_lengthOfPin];
        [self prepareKeyArray];
        [self makeKeyboardView];
        
    }
    return self;
}

- (instancetype)init {
    return [self initWithDoneButton:YES];
}

- (UIColor *)configureBackgroundColor {
    return RGB(0x2d, 0x2d, 0x2d);
}


- (void)doneClick:(UIButton*)btn {
    [self.delegate doneClick:[self getPayData]];
}


- (void)makeKeyboardView {
    // add base
    CGFloat baseWidth = CGRectGetWidth(self.frame);
    CGRect frame = CGRectMake(0, kHeight_Title, baseWidth, _keyboardHeight);
    _keyboardView = [[UIView alloc] initWithFrame:frame];
    [self addSubview:_keyboardView];

    [self addKeys];
    [self makeSeperators];
}

- (void)textChanged:(UIButton*)btn {
    if([self.passwordArray count] < _lengthOfPin) {
        //内部存储加密数据
        NSString *singalPin = [NSString stringWithFormat:@"%ld", (unsigned long)btn.tag];
        [self encryptText:singalPin];
        
        //发送给UI
//        NSString *text = kSecret;
        NSString *text = [NSString stringWithFormat:@"%ld", (unsigned long)btn.tag];
        [self.delegate textChanged:text keyboard:self];
    }
}

- (void)deleteClick {
    
    if (self)
    {
        [self deleteEncrypted];
    }
    
    [self.delegate deleteClickKeyboard:self];
}

- (void)encryptText:(NSString*)pinText {
    [self.passwordArray addObject:[self aes256encrypt:pinText key:self.randAesKey]];
}



- (void)cleanSecurity {
    [self.passwordArray removeAllObjects];
}

- (void)deleteEncrypted {
    [self.passwordArray removeLastObject];
}


- (void)setSecurity:(BOOL)security {
    _security = security;
    [self refreshKeyBoard];
}



-(NSString *)getPayData {
    //返回3DS加密的数据
    NSMutableString *passwordStr = [[NSMutableString alloc] init];
    for(NSString *encryptPinStr in self.passwordArray) {
        
        NSString *decryptStr = [[self aes256decrypt:encryptPinStr key:self.randAesKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        decryptStr = [decryptStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        if(decryptStr) {
            [passwordStr appendString:decryptStr];
        }
    }
    
    //进行md5编码NSMutableString
    NSString *md5 = [self MD5:passwordStr];
    return md5;
}

- (void)prepareKeyArray
{
    self.mKeyArray = [[NSMutableArray alloc] initWithCapacity:KKeyNumbers];
    self.rowLines = [[NSMutableArray alloc] init];
    NSMutableArray *baseArray = [[NSMutableArray alloc] initWithCapacity:KKeyNumbers];
    for (NSInteger i = 1; i<KKeyNumbers+1; i++) {
        NSInteger number = i % KKeyNumbers;
        [baseArray addObject:[NSNumber numberWithLong:number]];
    }
    
    if (self.security)
    {
        for (NSInteger i = 0; i<KKeyNumbers; i++)
        {
            NSInteger index = arc4random() % [baseArray count];
            [self.mKeyArray addObject:[baseArray objectAtIndex:index]];
            [baseArray removeObjectAtIndex:index];
        }
    }
    else
    {
        [self.mKeyArray setArray:baseArray];
    }
}

- (void)refreshKeyBoard {
    for (UIView* view in _keyboardView.subviews) {
        [view removeFromSuperview];
    }
    [self prepareKeyArray];
    [self addKeys];
    [self makeSeperators];
}

- (void)addKeys {
    
    NSInteger index = 0;
    CGFloat x = 0;
    CGFloat y = 0;
    
    while (index < KKeyNumbers)
    {
        
        NSString* title = [NSString stringWithFormat:@"%d", [(NSNumber*)[self.mKeyArray objectAtIndex:index] intValue]];
        
        if (index == 9) { //最后一个
            x = _keyWidth;
            y = 3 * _keyHeight;
        }
        else
        {
            x = (index % 3) * _keyWidth;
            y = (index / 3) * _keyHeight;
        }
        CGRect keyBtnFrame = CGRectMake(x, y, _keyWidth, _keyHeight);
        [self addKeyBtn:keyBtnFrame title:title];
        index++;
    }
    
    CGRect doneBtnFrame = CGRectMake(0, 3 * _keyHeight, _keyWidth, _keyHeight);
    [self addDoneBtn:doneBtnFrame];
    
    CGRect deleteBtnFrame = CGRectMake(2 * _keyWidth, 3 * _keyHeight,
                                       _keyWidth, _keyHeight);
    [self addDeleteBtn:deleteBtnFrame];
}

- (void)addKeyBtn:(CGRect)frame title:(NSString*)title {
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    NSInteger tag = [title integerValue];
    button.tag = tag;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitleColor:UPColor_Keyboard_Normal forState:UIControlStateNormal];
    [button addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setBackgroundImage:[UIImage upp_imageWitColor:UPColor_Keyboard_Background_Normal] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage upp_imageWitColor:UPColor_Keyboard_Background_HighLighted] forState:UIControlStateHighlighted];
    button.exclusiveTouch = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:KFont];
    [_keyboardView addSubview:button];
}

- (void)addDoneBtn:(CGRect)frame {
    NSString *title =kKeyboardDoneCH;
    NSRange range = NSMakeRange(0, 2);
    NSArray* lanArray = [[NSUserDefaults standardUserDefaults] objectForKey:kSyslocalekey];
    NSString* language = [[lanArray objectAtIndex:0] lowercaseString];
    NSString* localLan = [language substringWithRange:range];
    
    if (NSOrderedSame == [localLan compare:kLOCALE_EN options:NSCaseInsensitiveSearch]) {
        title = kKeyboardDoneEN;
    }

    
    UIButton* confirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirm setFrame:frame];
    confirm.exclusiveTouch = YES;
    
    [confirm setTitle:title forState:UIControlStateNormal];
    [confirm setTitle:title forState:UIControlStateHighlighted];
    [confirm setTitleColor:RGB(0x3c,0x72,0xcc) forState:UIControlStateNormal];
    [confirm addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [confirm setBackgroundImage:[UIImage upp_imageWitColor:UPColor_Keyboard_Background_Normal] forState:UIControlStateNormal];
    [confirm setBackgroundImage:[UIImage upp_imageWitColor:UPColor_Keyboard_Background_HighLighted] forState:UIControlStateHighlighted];
    confirm.titleLabel.font = [UIFont systemFontOfSize:18];
    if (self.needDoneButton) {
        [_keyboardView addSubview:confirm];
    }
}

- (void)addDeleteBtn:(CGRect)frame {
    UIButton* del = [UIButton buttonWithType:UIButtonTypeCustom];
    [del setFrame:frame];
    del.exclusiveTouch = YES;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"MMPasswordKeyBoard.bundle/PwdKB.bundle" ofType:nil];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSString *file = [bundle pathForResource:@"KeyboardDelete@3x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:file];
    [del setImage:image forState:UIControlStateNormal];
    [del addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    CGFloat l = (CGRectGetWidth(frame) - image.upp_realSize.width) / 2;
    CGFloat t = (CGRectGetHeight(frame) - image.upp_realSize.height) / 2;
    del.imageEdgeInsets = UIEdgeInsetsMake(t,l,t,l);
    [del setBackgroundImage:[UIImage upp_imageWitColor:UPColor_Keyboard_Background_Normal] forState:UIControlStateNormal];
    [del setBackgroundImage:[UIImage upp_imageWitColor:UPColor_Keyboard_Background_HighLighted] forState:UIControlStateHighlighted];
    [_keyboardView addSubview:del];
}

- (void)makeSeperators {
    UPPLineView *line = nil;
    CGRect frame = CGRectZero;
    CGFloat width = CGRectGetWidth(_keyboardView.frame);
    CGFloat height = CGRectGetHeight(_keyboardView.frame);
    // add row seperator
    CGFloat rowOffset = 0;
    while (rowOffset < height) {
        frame = CGRectMake(0, rowOffset, width, kHeight_Line_Common);
        line = [[UPPLineView alloc] initWithFrame:frame color:UPColor_Line_Keyboard];
        [_keyboardView addSubview:line];
        [self.rowLines addObject:line];
        //[line release];
        rowOffset += _keyHeight;
    }
    
    // add colum seperator
    CGFloat columOffset = _keyWidth;
    while (columOffset < width) {
        frame = CGRectMake(columOffset, 0, kHeight_Line_Common, 4 * _keyHeight);
        line = [[UPPLineView alloc] initWithFrame:frame color:UPColor_Line_Keyboard];
        [_keyboardView addSubview:line];
        //[line release];
        columOffset += _keyWidth;
    }
}

#pragma mark-
#pragma mark 加解密
#pragma mark-
/**
 使用AES加密数据
 
 @param originalStr 被加密字符串，使用UTF-8编码
 @param aesKey      加密使用的秘钥
 
 @return 返回加密并进行base64编码的字符串
 */
- (NSString *)aes256encrypt:(NSString *)originalStr key:( NSString*)aesKey {
    
    char keyPtr[kCCKeySizeAES256+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [aesKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [aesKey getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData* data = [originalStr dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    
    NSUInteger diff = kCCKeySizeAES256 - (dataLength % kCCKeySizeAES256);
    NSUInteger newSize = 0;
    
    if(diff > 0)
    {
        newSize = dataLength + diff;
    }
    
    char dataPtr[newSize];
    memcpy(dataPtr, [data bytes], [data length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x00;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionECBMode,
                                          keyPtr,
                                          kCCKeySizeAES256,
                                          ivPtr,
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytes:buffer length:numBytesCrypted];
        //NSLog(@"data=%@",[resultData base64EncodedStringWithOptions:0]);
        return [resultData base64EncodedStringWithOptions:0];
    }
    free(buffer);
    return nil;
}

/**
 使用AES解密数据
 
 @param encryptStr  待解密字符串，使用base64形式编码
 @param aesKey      解密使用的秘钥
 
 @return 返回解密后并进行了UTF-8遍吗的字符串
 */
- (NSString *)aes256decrypt:(NSString *)encryptStr key:(NSString*)aesKey {
    if(!encryptStr)
        return nil;
    char keyPtr[kCCKeySizeAES256+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [aesKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [aesKey getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data =[[NSData alloc] initWithBase64EncodedString:encryptStr options:0];
    NSUInteger dataLength = [data length];
    
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionECBMode,
                                          keyPtr,
                                          kCCKeySizeAES256,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytes:buffer length:numBytesCrypted];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}


/**
 产生0-10，A-Z,a-z 62个字符组成的随机字符
 
 @param length  随机字符串长度
 
 @return 随机字符串
 */
- (NSString *)randStr:(NSInteger)length {
    
    NSMutableString *randStr = [NSMutableString new];
    
    for(int i=0;i<length;i++) {
        int index = arc4random() % 3;
        
        switch (index) {
            case 0:
            {
                [randStr appendFormat:@"%d",arc4random() % 10];
                break;
            }
            case 1:
            {
                char data[1];
                data[0] = (char)('A' + (arc4random_uniform(26)));
                [randStr appendString: [[NSString alloc] initWithBytes:data length:1 encoding:NSUTF8StringEncoding]];
                break;
            }
                
            case 2:
            {
                char data[1];
                data[0] = (char)('a' + (arc4random_uniform(26)));
                [randStr appendString: [[NSString alloc] initWithBytes:data length:1 encoding:NSUTF8StringEncoding]];
                break;
            }
                
            default:
            {
                [randStr appendFormat:@"%d",arc4random() % 10];
                break;
            }
        }
    }
    
    return randStr;
}


- (NSString *)MD5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}
@end
