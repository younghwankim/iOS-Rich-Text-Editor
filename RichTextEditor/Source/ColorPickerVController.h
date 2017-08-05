//
//  ColorPickerVController.h
//  SmartStart
//
//  Created by Younghwan Kim on 2014-09-27.
//  Copyright (c) 2014 Younghwan Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerVCDelegate <NSObject>
@optional
- (void) closeColorPicker;
- (void) selectedColor:(UIColor *)color;
- (void) selectedHighlightColor:(UIColor *)color;
@end

@interface ColorPickerVController : UIViewController

@property (nonatomic, weak) id<ColorPickerVCDelegate> colorPickerDelegate;
@end
