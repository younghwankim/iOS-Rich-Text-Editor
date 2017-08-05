//
//  ColorPickerVController.m
//  SmartStart
//
//  Created by Younghwan Kim on 2014-09-27.
//  Copyright (c) 2014 Younghwan Kim. All rights reserved.
//

#import "ColorPickerVController.h"

@interface ColorPickerVController ()
@property (nonatomic, strong) NSArray *hexColors;
@end

@implementation ColorPickerVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hexColors = @[@"0x000000",@"0x808080",@"0xffffff",@"0x9e1812",@"0xcd232b",@"0xd36a53",
                       @"0xa46116",@"0xdd8f2f",@"0xe4ac64",@"0xac9e19",@"0xfeef2b",@"0xfdf869",
                       @"0x5b8828",@"0x90cb41",@"0xadd773",@"0x4b75a2",@"0x71aced",@"0x7dbdf1",
                       @"0x440d61",@"0x662292",@"0x845aa8",@"0x9a0b59",@"0xcb1c8e",@"0xd263a9"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeBtnClicked:(id)sender
{
    [self.colorPickerDelegate closeColorPicker];
}

- (IBAction)textColorSelected:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if(button.tag >0)
        [self.colorPickerDelegate selectedColor:[self colorWithHexString:self.hexColors[button.tag-1]]];
}

- (IBAction)textHighlightColorSelected:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if(button.tag >0)
        [self.colorPickerDelegate selectedHighlightColor:[self colorWithHexString:self.hexColors[button.tag-1]]];
}


- (UIColor *)colorWithHexString:(NSString *)colorString
{
    colorString = [colorString stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    
    if (colorString.length == 3)
        colorString = [NSString stringWithFormat:@"%c%c%c%c%c%c",
                       [colorString characterAtIndex:0], [colorString characterAtIndex:0],
                       [colorString characterAtIndex:1], [colorString characterAtIndex:1],
                       [colorString characterAtIndex:2], [colorString characterAtIndex:2]];
    
    if (colorString.length == 6)
    {
        int r, g, b;
        sscanf([colorString UTF8String], "%2x%2x%2x", &r, &g, &b);
        return [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
    }
    return nil;
}

@end
