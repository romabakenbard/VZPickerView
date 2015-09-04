//
//  VZPickerView.m
//  Vazhno
//
//  Created by Alekseenko Oleg on 10.04.14.
//  Copyright (c) 2014 boloid. All rights reserved.
//

#import "VZPickerView.h"

float const VZPickerViewContentHeight = 300;

static UIView *_ipadHolderView = nil;

@interface VZPickerView () <UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverControllerDelegate>
@property (nonatomic, weak) UIView *presentingView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIDatePicker *picker;

@property (nonatomic, strong) NSArray *customObjects;
@property (nonatomic, strong) UIPickerView *customPicker;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic, copy) VZPickerViewDateResultBlock dateCompleteBlock;
@property (nonatomic, copy) VZPickerViewObjectResultBlock objectCompleteBlock;
@property (nonatomic, strong) UIPopoverController *popover;
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
    if ([self isIpad]) {
        frame = CGRectMake(0, 0, 320, VZPickerViewContentHeight);
    }
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.presentingView = view;
        if (![self isIpad]) {
            [self.presentingView addSubview:self];
        }
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
        float offsetY = ([self isIpad]) ? 0 : self.frame.size.height;
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, VZPickerViewContentHeight)];
        _contentView.backgroundColor = [UIColor whiteColor];
        if (![self isIpad]) {
            [self addSubview:_contentView];
        }
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

    if ([self isIpad]) {
        UIViewController *controller = [[UIViewController alloc] init];
        controller.preferredContentSize = CGSizeMake(320, self.contentView.frame.size.height);
        controller.view.frame = self.contentView.bounds;
        [controller.view addSubview:self.contentView];
        self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:self.presentingView.frame inView:self.presentingView.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

        _ipadHolderView = self;
        
    } else {
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
}

- (void)hide {
    
    if ([self isIpad]) {
//        i realy hate popover whitout dispatch_after does not dismissed
        self.popover.passthroughViews = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _ipadHolderView = nil;
            [self.popover dismissPopoverAnimated:NO];
            self.popover = nil;
        });
    } else {
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
}


#pragma mark - UIPickerViewDelegate -

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    NSString *text = _customObjects[row];
    
    UILabel *label = (UILabel*)view;
    if(view == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width-20.0, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.text = text;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:22.0];
    }
    
    return label;
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

#pragma mark - Helper -

- (BOOL)isIpad {
    return UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM();
}

#pragma mark - UIPopoverDelegate -

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _popover = nil;
}
@end
