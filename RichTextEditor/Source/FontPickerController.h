//
//  FontPickerController.h
//  RichTextEditor
//
//  Created by Young Kim on 2012-12-23.
//
//

#import <UIKit/UIKit.h>

#ifndef _FONTPICKERCONTROLLER_H_
#define _FONTPICKERCONTROLLER_H_

#define kNameComponent  0
#define kSizeComponent  1


@protocol FontPickerDelegate <NSObject>
@optional
- (void) closeFontPicker;
- (void) selectedFont:(NSString *)strFont;
- (void) selectedFontSize:(NSNumber *)fontSize;
@end

@interface FontPickerController : UIViewController

@property (nonatomic, weak) id<FontPickerDelegate> fontPickerDelegate;
@property (nonatomic, strong) NSString *currentFont;
@property (nonatomic, strong) NSString *currentSize;
@property (nonatomic, strong) NSArray *fontNames;
@property (nonatomic, strong) NSArray *fontSizes;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

- (IBAction) onClose;

@end

#endif
