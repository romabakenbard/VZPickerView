//
//  VZPickerView.m
//  Vazhno
//
//  Created by Alekseenko Oleg on 10.04.14.
//  Copyright (c) 2014 boloid. All rights reserved.
//

#import "VZPickerView.h"

@interface VZPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, weak) UIView *presentingView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIDatePicker *picker;

@property (nonatomic, strong) NSArray *customObjects;
@property (nonatomic, strong) UIPickerView *customPicker;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic, copy) VZPickerViewDateResultBlock dateCompleteBlock;
@property (nonatomic, copy) VZPickerViewObjectResultBlock objectCompleteBlock;
@end

@implementation VZPickerView


//--------------------------------------------------------------------------------------------
+ (instancetype)showDatePickerInView:(UIView *)view minDate:(NSDate *)minDate maxDate:(NSDate *)maxDate currentDate:(NSDate *)current complete:(VZPickerViewDateResultBlock)complete {
    VZPickerView *pickerView = [[VZPickerView alloc]initWithView:view];
    [pickerView prepareToShowDatePicker];
    pickerView.picker.minimumDate = minDate;
    pickerView.picker.maximumDate = maxDate;
    pickerView.picker.date = current;
    pickerView.dateCompleteBlock = complete;
    [pickerView show];
    return pickerView;
}

+ (instancetype)showPickerInView:(UIView *)view objects:(NSArray *)objects selectedObject:(id)object complete:(VZPickerViewObjectResultBlock)complete {
    
    return [self showPickerInView:view objects:objects selectedObject:object rowHeight:50 complete:complete];
}

+ (instancetype)showViewsPickerInView:(UIView *)view views:(NSArray *)objects selectedObject:(id)object rowHeight:(CGFloat)height complete:(VZPickerViewObjectResultBlock)complete {
    return [self showPickerInView:view objects:objects selectedObject:object rowHeight:height complete:complete];
}

+ (instancetype)showPickerInView:(UIView *)view objects:(NSArray *)objects selectedObject:(id)object rowHeight:(CGFloat)height complete:(VZPickerViewObjectResultBlock)complete {
    VZPickerView *pickerView = [[VZPickerView alloc]initWithView:view];
    pickerView.customObjects = objects;
    [pickerView prepateToShowCustomPicker];
    if (object) {
        NSUInteger index = [objects indexOfObject:object];
        if (index != NSNotFound) {
            [pickerView.customPicker selectRow:index inComponent:0 animated:YES];
        }
    }
    pickerView.objectCompleteBlock = complete;
    pickerView.rowHeight = height;
    [pickerView show];
    return pickerView;
}

//--------------------------------------------------------------------------------------------

- (id)initWithView:(UIView *)view
{
    CGRect frame = view.bounds;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.presentingView = view;
        [self.presentingView addSubview:self];
    }
    return self;
}

- (void)prepareToShowDatePicker {
    [self setupDimView];
    [self setupContentView];
    [self setupNavigationBar];
    [self setupDatePicker];
}

- (void)prepateToShowCustomPicker {
    [self setupDimView];
    [self setupContentView];
    [self setupNavigationBar];
    [self setupCustomPickerView];
}

#pragma mark - Setup -

- (void)setupDimView {
    if (!_dimView) {
        _dimView = [[UIView alloc]initWithFrame:self.bounds];
        _dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _dimView.alpha = 0.0;
        [self addSubview:_dimView];
    }
}

- (void)setupContentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 300)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
    }
}

- (void)setupNavigationBar {
    self.navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 44)];
    UINavigationItem *item = [[UINavigationItem alloc]initWithTitle:@""];
    [self.navigationBar setItems:@[item]];
    item.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [self.contentView addSubview:self.navigationBar];
}

- (void)setupDatePicker {
    if (!_picker) {
        _picker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 44, self.contentView.frame.size.width, 216)];
        _picker.datePickerMode = UIDatePickerModeDate;
        [self.contentView addSubview:_picker];
        self.contentView.frame = ({
            CGRect frame = self.contentView.frame;
            frame.size.height = _picker.frame.origin.y + _picker.frame.size.height;
            frame;
        });
    }
}

- (void)setupCustomPickerView {
    if (!_customPicker) {
        _customPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.contentView.frame.size.width, 216)];
        _customPicker.delegate = self;
        _customPicker.dataSource = self;
        _customPicker.showsSelectionIndicator = YES;
        [self.contentView addSubview:_customPicker];
        self.contentView.frame = ({
            CGRect frame = self.contentView.frame;
            frame.size.height = _customPicker.frame.origin.y + _customPicker.frame.size.height;
            frame;
        });
    }
}

#pragma mark - Actions -

- (void)doneClicked:(id)sender {
    if (_picker) {
        if (_dateCompleteBlock) {
            _dateCompleteBlock(_picker.date);
        }
    }
    
    if (_customPicker) {
        if (_objectCompleteBlock) {
            id object = _customObjects[[_customPicker selectedRowInComponent:0]];
            _objectCompleteBlock(object);
        }
    }
    [self hide];
}

- (void)show {
    
    //hide keyboard
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        _dimView.alpha = 1.0;
        _contentView.frame = ({
            CGRect frame = _contentView.frame;
            frame.origin.y = self.frame.size.height - frame.size.height;
            frame;
        });
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        _dimView.alpha = 0.0;
        _contentView.frame = ({
            CGRect frame = _contentView.frame;
            frame.origin.y = self.frame.size.height;
            frame;
        });
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.contentView = nil;
        self.dateCompleteBlock = nil;
        self.presentingView = nil;
        self.customPicker = nil;
        self.objectCompleteBlock = nil;
        self.dimView = nil;
    }];
}


#pragma mark - UIPickerViewDelegate -

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _customObjects[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    id object = _customObjects[row];
    if (![object isKindOfClass:[UIView class]]) {
        object = nil;
    } else {
        UIView * myView = object;
        // first convert to a UIImage
        UIGraphicsBeginImageContextWithOptions(myView.bounds.size, NO, 0);
        [myView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // then convert back to a UIImageView and return it
        object = [[UIImageView alloc] initWithImage:image];
    }
    return object;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _customObjects.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    
    if ([NSStringFromSelector(aSelector) isEqualToString:NSStringFromSelector(@selector(pickerView:viewForRow:forComponent:reusingView:))]) {
        BOOL result = (_customObjects.count > 0);
        if (result) {
            id object = _customObjects[0];
            result = ([object isKindOfClass:[UIView class]]);
        }
        return result;
    }
    return [super respondsToSelector:aSelector];
}
@end
