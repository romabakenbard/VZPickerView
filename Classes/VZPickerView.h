//
//  VZPickerView.h
//  Vazhno
//
//  Created by Alekseenko Oleg on 10.04.14.
//  Copyright (c) 2014 boloid. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VZPickerViewDateResultBlock)(NSDate *selected);
typedef void (^VZPickerViewObjectResultBlock)(id object);

@interface VZPickerView : UIView

@property (nonatomic, strong) UINavigationBar *navigationBar;

+ (instancetype)showDatePickerInView:(UIView *)view minDate:(NSDate *)minDate maxDate:(NSDate *)maxDate currentDate:(NSDate *)current complete:(VZPickerViewDateResultBlock)complete;

/**
 *   Objects can be views or strings
 *   For views used default view height - 50 point
 */
+ (instancetype)showPickerInView:(UIView *)view objects:(NSArray *)objects selectedObject:(id)object complete:(VZPickerViewObjectResultBlock)complete;

/**
 *   @param objects - only views
 */
+ (instancetype)showViewsPickerInView:(UIView *)view views:(NSArray *)objects selectedObject:(id)object rowHeight:(CGFloat)height complete:(VZPickerViewObjectResultBlock)complete;

@end
