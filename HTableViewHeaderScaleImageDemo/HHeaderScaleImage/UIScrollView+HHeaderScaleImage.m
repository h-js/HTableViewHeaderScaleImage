//
//  UIScrollView+HHeaderScaleImage.m
//  HTableViewHeaderScaleImageDemo
//
//  Created by hejunsong on 16/12/15.
//  Copyright © 2016年 hjs. All rights reserved.
//

#import "UIScrollView+HHeaderScaleImage.h"
#import <objc/runtime.h>
#define HKeyPath(objc,keyPath) @(((void)objc.keyPath,#keyPath))

static char * const headerImageViewKey = "headerImageViewKey";
static char * const headerImageViewHeight = "headerImageViewHeight";
static char * const isInitialKey = "isInitialKey";
// 默认图片高度
static CGFloat const oriImageH = 200;

@interface NSObject (MethodChange)
//交换对象方法
+(void)H_changeInstanceSelector:(SEL)origSelector
                 changeSelector:(SEL)changeSelector;

//交换类方法
+(void)H_ChangeClassSelector:(SEL)origSelector
              changeSelector:(SEL)changeSelector;

@end
@implementation NSObject (MethodChange)
+(void)H_changeInstanceSelector:(SEL)origSelector changeSelector:(SEL)changeSelector
{
    // 获取原有方法
    Method origMethod = class_getInstanceMethod(self,
                                                origSelector);
    // 获取交换方法
    Method swizzleMethod = class_getInstanceMethod(self,
                                                   changeSelector);
    BOOL isAdd = class_addMethod(self, origSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    
    if (!isAdd) { // 添加方法失败，表示原有方法存在，直接替换
        method_exchangeImplementations(origMethod, swizzleMethod);
    }else {
        class_replaceMethod(self, changeSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }

    
    
}
+(void)H_ChangeClassSelector:(SEL)origSelector
              changeSelector:(SEL)changeSelector
{
    // 获取原有方法
    Method origMethod = class_getClassMethod(self,
                                             origSelector);
    // 获取交换方法
    Method swizzleMethod = class_getClassMethod(self,
                                                changeSelector);
    
    // 添加原有方法实现为当前方法实现
    BOOL isAdd = class_addMethod(self, origSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
    
    if (!isAdd) { // 添加方法失败，原有方法存在，直接替换
        method_exchangeImplementations(origMethod, swizzleMethod);
    }

}

@end







@implementation UIScrollView (HHeaderScaleImage)

+(void)load
{
    [self H_changeInstanceSelector:@selector(setTableFooterView:) changeSelector:@selector(setH_tableHeaderView:)];
}

-(void)setH_tableHeaderView:(UIView *)tableHeaderView
{
    if(![self isMemberOfClass:[UITableView class]]) return;
    
    [self setH_tableHeaderView:tableHeaderView];
    
    UITableView *tableView = (UITableView *)self;
    self.h_headerScaleImageHeight = tableView.tableHeaderView.frame.size.height;

}



-(UIImageView *)h_headerImageView
{
    UIImageView *imageView = objc_getAssociatedObject(self, headerImageViewKey);
    if(imageView == nil)
    {
        imageView = [[UIImageView alloc] init];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self insertSubview:imageView atIndex:0];
        objc_setAssociatedObject(self, headerImageViewKey, imageView,  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return imageView;
}

-(BOOL)h_isInitial
{
    return [objc_getAssociatedObject(self, isInitialKey) boolValue];
}
-(void)setH_isInitial:(BOOL)h_isinitial
{
    objc_setAssociatedObject(self, isInitialKey, @(h_isinitial), OBJC_ASSOCIATION_ASSIGN);
}
-(void)seth_headerScaleImageHeight:(CGFloat)h_headerScaleImageHeight
{
    objc_setAssociatedObject(self, headerImageViewHeight, @(h_headerScaleImageHeight), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void)setH_headerScaleImage:(UIImage *)h_headerScaleImage
{
    [self h_headerImageView].image = h_headerScaleImage;
    [self setupHeaderImageView];
}

-(CGFloat)h_headerScaleImageHeight
{
    CGFloat headerImageHeight = [objc_getAssociatedObject(self, headerImageViewHeight) floatValue];
    return headerImageHeight == 0 ? oriImageH:headerImageHeight;
}
-(UIImage *)h_headerScaleImage
{
    return [self h_headerImageView].image;
}

-(void)setupHeaderImageView
{

    [self setupHeaderIamgeFrame];
    if([self h_isInitial] == NO)
    {
        [self addObserver:self forKeyPath:HKeyPath(self, contentOffset) options:NSKeyValueObservingOptionNew context:nil];
        [self setH_isInitial:YES];
    }
    
}

-(void)setupHeaderIamgeFrame
{
    [self h_headerImageView].frame = CGRectMake(0, 0, self.bounds.size.width, [self h_headerScaleImageHeight]);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{

    CGFloat offsetY = self.contentOffset.y;
    if(offsetY < 0)
    {
        [self h_headerImageView].frame = CGRectMake(offsetY, offsetY,self.bounds.size.width - offsetY * 2, [self h_headerScaleImageHeight] - offsetY);
    }else
    {
        [self h_headerImageView].frame = CGRectMake(0, 0, self.bounds.size.width, [self h_headerScaleImageHeight]);
    }

}

- (void)dealloc
{
    if ([self h_isInitial]) { // 初始化过，就表示有监听contentOffset属性，才需要移除
        
        [self removeObserver:self forKeyPath:HKeyPath(self, contentOffset)];
        
    }
    
}



@end
