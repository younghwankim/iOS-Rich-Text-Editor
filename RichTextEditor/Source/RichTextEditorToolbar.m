//
//  RichTextEditorToolbar.m
//  RichTextEdtor
//
//  Created by Aryan Gh on 7/21/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/iOS-Rich-Text-Editor
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RichTextEditorToolbar.h"
#import <CoreText/CoreText.h>
#import "RichTextEditorPopover.h"
#import "RichTextEditorFontSizePickerViewController.h"
#import "RichTextEditorFontPickerViewController.h"
#import "RichTextEditorColorPickerViewController.h"
#import "WEPopoverController.h"
#import "RichTextEditorToggleButton.h"
#import "UIFont+RichTextEditor.h"
#import "FontPickerController.h"
#import "ColorPickerVController.h"

#define ITEM_SEPARATOR_SPACE 5
#define ITEM_TOP_AND_BOTTOM_BORDER 5
#define ITEM_WITH 40

@interface RichTextEditorToolbar() <RichTextEditorFontSizePickerViewControllerDelegate, RichTextEditorFontSizePickerViewControllerDataSource, RichTextEditorFontPickerViewControllerDelegate, RichTextEditorFontPickerViewControllerDataSource, RichTextEditorColorPickerViewControllerDataSource, RichTextEditorColorPickerViewControllerDelegate, FontPickerDelegate, ColorPickerVCDelegate, WEPopoverControllerDelegate>
@property (nonatomic, strong) id <RichTextEditorPopover> popover;
@property (nonatomic, strong) RichTextEditorToggleButton *btnDownOne;
@property (nonatomic, strong) RichTextEditorToggleButton *btnDownTwo;
@property (nonatomic, strong) RichTextEditorToggleButton *btnBold;
@property (nonatomic, strong) RichTextEditorToggleButton *btnItalic;
@property (nonatomic, strong) RichTextEditorToggleButton *btnUnderline;
@property (nonatomic, strong) RichTextEditorToggleButton *btnStrikeThrough;
@property (nonatomic, strong) RichTextEditorToggleButton *btnSuperScript;
@property (nonatomic, strong) RichTextEditorToggleButton *btnSubScript;
@property (nonatomic, strong) RichTextEditorToggleButton *btnFontSize;
@property (nonatomic, strong) RichTextEditorToggleButton *btnFont;
@property (nonatomic, strong) RichTextEditorToggleButton *btnBackgroundColor;
@property (nonatomic, strong) RichTextEditorToggleButton *btnForegroundColor;
@property (nonatomic, strong) RichTextEditorToggleButton *btnTextAlignmentLeft;
@property (nonatomic, strong) RichTextEditorToggleButton *btnTextAlignmentCenter;
@property (nonatomic, strong) RichTextEditorToggleButton *btnTextAlignmentRight;
@property (nonatomic, strong) RichTextEditorToggleButton *btnTextAlignmentJustified;
@property (nonatomic, strong) RichTextEditorToggleButton *btnParagraphIndent;
@property (nonatomic, strong) RichTextEditorToggleButton *btnParagraphOutdent;
@property (nonatomic, strong) RichTextEditorToggleButton *btnParagraphFirstLineHeadIndent;
@property (nonatomic, strong) RichTextEditorToggleButton *btnBulletPoint;

@property (nonatomic, strong) WEPopoverController *wePopoverController;
@end

@implementation RichTextEditorToolbar

#pragma mark - Initialization -

- (id)initWithFrame:(CGRect)frame delegate:(id <RichTextEditorToolbarDelegate>)delegate dataSource:(id <RichTextEditorToolbarDataSource>)dataSource
{
	if (self = [super initWithFrame:frame])
	{
		self.delegate = delegate;
		self.dataSource = dataSource;
		
		self.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
		self.layer.borderWidth = .7;
		self.layer.borderColor = [UIColor lightGrayColor].CGColor;
		
		[self initializeButtons];
        [self populateToolbar];
	}
	
	return self;
}

#pragma mark - Public Methods -

- (void)redraw
{
	[self populateToolbar];
}

- (void)updateStateWithAttributes:(NSDictionary *)attributes
{
	UIFont *font = [attributes objectForKey:NSFontAttributeName];
	NSParagraphStyle *paragraphTyle = [attributes objectForKey:NSParagraphStyleAttributeName];
	
	[self.btnFontSize setTitle:[NSString stringWithFormat:@"%.f", font.pointSize] forState:UIControlStateNormal];
	[self.btnFont setTitle:font.familyName forState:UIControlStateNormal];
	
	self.btnBold.on = [font isBold];
	self.btnItalic.on = [font isItalic];
	
	self.btnTextAlignmentLeft.on = NO;
	self.btnTextAlignmentCenter.on = NO;
	self.btnTextAlignmentRight.on = NO;
	self.btnTextAlignmentJustified.on = NO;
	self.btnParagraphFirstLineHeadIndent.on = (paragraphTyle.firstLineHeadIndent > paragraphTyle.headIndent) ? YES : NO;
	
	switch (paragraphTyle.alignment)
	{
		case NSTextAlignmentLeft:
			self.btnTextAlignmentLeft.on = YES;
			break;
		case NSTextAlignmentCenter:
			self.btnTextAlignmentCenter.on = YES;
			break;
			
		case NSTextAlignmentRight:
			self.btnTextAlignmentRight.on = YES;
			break;
			
		case NSTextAlignmentJustified:
			self.btnTextAlignmentJustified.on = YES;
			break;
			
		default:
			self.btnTextAlignmentLeft.on = YES;
			break;
	}
	
	NSNumber *existingUnderlineStyle = [attributes objectForKey:NSUnderlineStyleAttributeName];
	self.btnUnderline.on = (!existingUnderlineStyle || existingUnderlineStyle.intValue == NSUnderlineStyleNone) ? NO :YES;
	
	NSNumber *existingStrikeThrough = [attributes objectForKey:NSStrikethroughStyleAttributeName];
	self.btnStrikeThrough.on = (!existingStrikeThrough || existingStrikeThrough.intValue == NSUnderlineStyleNone) ? NO :YES;
    
    if(attributes[@"NSSuperScript"]){
        NSString *strScript = [NSString stringWithFormat:@"%@",attributes[@"NSSuperScript"]];
        if([strScript isEqualToString:@"1"]){
            self.btnSuperScript.on = YES;
            self.btnSubScript.on = NO;
        }else if([strScript isEqualToString:@"-1"]){
            self.btnSuperScript.on = NO;
            self.btnSubScript.on = YES;
        }else{
            self.btnSuperScript.on = NO;
            self.btnSubScript.on = NO;
        }
    }else{
        self.btnSuperScript.on = NO;
        self.btnSubScript.on = NO;
    }
}

#pragma mark - IBActions -
- (void)downSelected:(UIButton *)sender
{
    [self.delegate richTextEditorToolbarDidSelectDown:self.btnDownOne.on];
}

- (void)boldSelected:(UIButton *)sender
{
    [self.delegate richTextEditorToolbarDidSelectBold:self.btnBold.on];
}

- (void)italicSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectItalic:self.btnItalic.on];
}

- (void)underLineSelected:(UIButton *)sender
{
    [self.delegate richTextEditorToolbarDidSelectUnderline:self.btnUnderline.on];
}

- (void)strikeThroughSelected:(UIButton *)sender
{
    [self.delegate richTextEditorToolbarDidSelectStrikeThrough:self.btnStrikeThrough.on];
}

- (void)superScriptSelected:(UIButton *)sender
{
    [self.delegate richTextEditorToolbarDidSelectSuperScript:self.btnSuperScript.on];
}

- (void)subScriptSelected:(UIButton *)sender
{
    [self.delegate richTextEditorToolbarDidSelectSubScript:self.btnSubScript.on];
}

- (void)bulletPointSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectBulletPoint];
}

- (void)paragraphIndentSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectParagraphIndentation:ParagraphIndentationIncrease];
}

- (void)paragraphOutdentSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectParagraphIndentation:ParagraphIndentationDecrease];
}

- (void)paragraphHeadIndentOutdentSelected:(UIButton *)sender
{
	[self.delegate richTextEditorToolbarDidSelectParagraphFirstLineHeadIndent];
}

- (void)fontSizeSelected:(UIButton *)sender
{
    [self fontSelected:sender];
}

- (void)fontSelected:(UIButton *)sender
{
    UIWindow *keyboardWindow = [UIApplication sharedApplication].windows.lastObject;
    
    FontPickerController *contentViewController = [[FontPickerController alloc]initWithNibName:@"FontPickerController" bundle:[NSBundle bundleForClass:[self class]]];
    contentViewController.preferredContentSize = CGSizeMake(320,236);
    contentViewController.fontPickerDelegate = self;
    contentViewController.currentFont = self.btnFont.currentTitle;
    contentViewController.currentSize = self.btnFontSize.currentTitle;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIPopoverArrowDirection popOverDicrection = UIPopoverArrowDirectionDown;
    
    CGRect frame = CGRectMake(0, 550, 300, 10);
    if([self isIPad]){
        if(screenRect.size.height > screenRect.size.width){
            frame = CGRectMake(200, 680, 300, 10);
            popOverDicrection = UIPopoverArrowDirectionUp;
        }else{
            frame = CGRectMake(200, 600, 300, 10);
        }
    }else{
        if(screenRect.size.height < screenRect.size.width){
            frame = CGRectMake(200, 320, 300, 10);
        }
        contentViewController.view.transform = CGAffineTransformMakeScale(0.85, 0.85);
    }
    
    self.wePopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController] ;
    
    self.wePopoverController.delegate = self;
    [self.wePopoverController presentPopoverFromRect:frame
                                              inView:keyboardWindow
                            permittedArrowDirections: popOverDicrection
                                            animated:YES];
    
    [self.delegate richTextEditorToolbarDidScroll:NO];
}

- (void)textBackgroundColorSelected:(UIButton *)sender
{
    [self textForegroundColorSelected:sender];
}

- (void)textForegroundColorSelected:(UIButton *)sender
{
    UIWindow *keyboardWindow = [UIApplication sharedApplication].windows.lastObject;
    
    ColorPickerVController *contentViewController = [[ColorPickerVController alloc]initWithNibName:@"ColorPickerVController" bundle:[NSBundle bundleForClass:[self class]]];
    contentViewController.preferredContentSize = CGSizeMake(314,381);
    contentViewController.colorPickerDelegate = self;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIPopoverArrowDirection popOverDicrection = UIPopoverArrowDirectionDown;
    
    CGRect frame = CGRectMake(0, 630, 300, 10);
    if([self isIPad]){
        if(screenRect.size.height > screenRect.size.width){
            frame = CGRectMake(250, 630, 300, 10);
            popOverDicrection = UIPopoverArrowDirectionUp;
        }else{
            frame = CGRectMake(340, 700, 300, 10);
        }
    }else{
        if(screenRect.size.height > screenRect.size.width){
            contentViewController.view.transform = CGAffineTransformMakeScale(0.85, 0.85);
        }else{
            frame = CGRectMake(180, 100, 300, 10);
            contentViewController.view.transform = CGAffineTransformMakeScale(0.75, 0.75);
        }
    }
    
    self.wePopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController] ;
    
    self.wePopoverController.delegate = self;
    [self.wePopoverController presentPopoverFromRect:frame
                                              inView:keyboardWindow
                            permittedArrowDirections:popOverDicrection
                                            animated:YES];
    [self.delegate richTextEditorToolbarDidScroll:NO];
}

- (void)textAlignmentSelected:(UIButton *)sender
{
	NSTextAlignment textAlignment = NSTextAlignmentLeft;
	
	if (sender == self.btnTextAlignmentLeft)
		textAlignment = NSTextAlignmentLeft;
	else if (sender == self.btnTextAlignmentCenter)
		textAlignment = NSTextAlignmentCenter;
	else if (sender == self.btnTextAlignmentRight)
		textAlignment = NSTextAlignmentRight;
	else if (sender == self.btnTextAlignmentJustified)
		textAlignment = NSTextAlignmentJustified;
	
	[self.delegate richTextEditorToolbarDidSelectTextAlignment:textAlignment];
}

#pragma mark - Private Methods -

- (void)populateToolbar
{
    // Remove any existing subviews.
    for (UIView *subView in self.subviews)
	{
        [subView removeFromSuperview];
    }
    
    // Populate the toolbar with the given features.
    RichTextEditorFeature features = [self.dataSource featuresEnabledForRichTextEditorToolbar];
    UIView *lastAddedView = nil;
    
    self.hidden = (features == RichTextEditorFeatureNone);
	
	if (self.hidden)
		return;
    
    if ((features & RichTextEditorFeatureAll) && [self isIPhone] && [self isPortrait])
    {
        UIView *separatorView = [self separatorView];
        [self addView:self.btnDownOne afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnDownOne;
        [self addView:separatorView afterView:self.btnDownOne withSpacing:YES];
        lastAddedView = separatorView;
    }
    
	// Font selection
	if (features & RichTextEditorFeatureFont || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:self.btnFont afterView:lastAddedView withSpacing:YES];
		[self addView:separatorView afterView:self.btnFont withSpacing:YES];
		lastAddedView = separatorView;
	}
	
	// Font size
	if (features & RichTextEditorFeatureFontSize || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:self.btnFontSize afterView:lastAddedView withSpacing:YES];
		[self addView:separatorView afterView:self.btnFontSize withSpacing:YES];
		lastAddedView = separatorView;
	}
	
	// Bold
	if (features & RichTextEditorFeatureBold || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnBold afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnBold;
	}
	
	// Italic
	if (features & RichTextEditorFeatureItalic || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnItalic afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnItalic;
	}
    // Separator view after font properties.
    if (features & RichTextEditorFeatureBold || features & RichTextEditorFeatureItalic || features & RichTextEditorFeatureAll)
    {
        UIView *separatorView = [self separatorView];
        [self addView:separatorView afterView:lastAddedView withSpacing:YES];
        lastAddedView = separatorView;
    }

    // Text color
    if (features & RichTextEditorFeatureTextForegroundColor || features & RichTextEditorFeatureAll)
    {
        [self addView:self.btnForegroundColor afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnForegroundColor;
    }

//    
//    // Background color
//    if (features & RichTextEditorFeatureTextBackgroundColor || features & RichTextEditorFeatureAll)
//    {
//        [self addView:self.btnBackgroundColor afterView:lastAddedView withSpacing:YES];
//        lastAddedView = self.btnBackgroundColor;
//    }
    
    // Separator view after font properties.
    if (features & RichTextEditorFeatureTextForegroundColor || features & RichTextEditorFeatureTextBackgroundColor || features & RichTextEditorFeatureAll)
    {
        UIView *separatorView = [self separatorView];
        [self addView:separatorView afterView:lastAddedView withSpacing:YES];
        lastAddedView = separatorView;
    }
    
	// Underline
	if (features & RichTextEditorFeatureUnderline || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnUnderline afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnUnderline;
	}
	
	// Strikethrough
	if (features & RichTextEditorFeatureStrikeThrough || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnStrikeThrough afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnStrikeThrough;
	}
	
    // SuperScript
    if (features & RichTextEditorFeatureSubScript || features & RichTextEditorFeatureAll)
    {
        [self addView:self.btnSuperScript afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnSuperScript;
    }
    
    // SubScript
    if (features & RichTextEditorFeatureSubScript || features & RichTextEditorFeatureAll)
    {
        [self addView:self.btnSubScript afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnSubScript;
    }
    
	// Separator view after font properties.
	if (features & RichTextEditorFeatureBold || features & RichTextEditorFeatureItalic || features & RichTextEditorFeatureUnderline || features & RichTextEditorFeatureStrikeThrough || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:separatorView afterView:lastAddedView withSpacing:YES];
		lastAddedView = separatorView;
	}
	
	// Align left
	if (features & RichTextEditorFeatureTextAlignmentLeft || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnTextAlignmentLeft afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnTextAlignmentLeft;
	}
	
	// Align center
	if (features & RichTextEditorFeatureTextAlignmentCenter || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnTextAlignmentCenter afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnTextAlignmentCenter;
	}
	
	// Align right
	if (features & RichTextEditorFeatureTextAlignmentRight || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnTextAlignmentRight afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnTextAlignmentRight;
	}
	
	// Align justified
	if (features & RichTextEditorFeatureTextAlignmentJustified || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnTextAlignmentJustified afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnTextAlignmentJustified;
	}
	
	// Separator view after alignment section
	if (features & RichTextEditorFeatureTextAlignmentLeft || features & RichTextEditorFeatureTextAlignmentCenter || features & RichTextEditorFeatureTextAlignmentRight || features & RichTextEditorFeatureTextAlignmentJustified || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:separatorView afterView:lastAddedView withSpacing:YES];
		lastAddedView = separatorView;
	}
	
	// Paragraph indentation
	if (features & RichTextEditorFeatureParagraphIndentation || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnParagraphOutdent afterView:lastAddedView  withSpacing:YES];
		[self addView:self.btnParagraphIndent afterView:self.btnParagraphOutdent withSpacing:YES];
		lastAddedView = self.btnParagraphIndent;
	}
	
	// Paragraph first line indentation
	if (features & RichTextEditorFeatureParagraphFirstLineIndentation || features & RichTextEditorFeatureAll)
	{
		[self addView:self.btnParagraphFirstLineHeadIndent afterView:lastAddedView withSpacing:YES];
		lastAddedView = self.btnParagraphFirstLineHeadIndent;
	}
	
	// Separator view after Indentation
	if (features & RichTextEditorFeatureParagraphIndentation || features & RichTextEditorFeatureParagraphFirstLineIndentation || features & RichTextEditorFeatureAll)
	{
		UIView *separatorView = [self separatorView];
		[self addView:separatorView afterView:lastAddedView withSpacing:YES];
		lastAddedView = separatorView;
	}
    
    // Down
    if ((features & RichTextEditorFeatureAll) && [self isIPhone] && [self isPortrait])
    {
        [self addView:self.btnDownTwo afterView:lastAddedView withSpacing:YES];
        lastAddedView = self.btnDownTwo;
    }
}

- (void)initializeButtons
{
	self.btnFont = [self buttonWithImageNamed:@"dropDownTriangle.png"
										width:130
								  andSelector:@selector(fontSelected:)];
	[self.btnFont setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
	[self.btnFont setTitle:@"Helvetica" forState:UIControlStateNormal];
	
	self.btnFontSize = [self buttonWithImageNamed:@"dropDownTriangle.png"
											width:50
									  andSelector:@selector(fontSizeSelected:)];
	[self.btnFontSize setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
	[self.btnFontSize setTitle:@"14" forState:UIControlStateNormal];
	
    self.btnDownOne = [self buttonWithImageNamed:@"s_down_arrow.png"
                                  andSelector:@selector(downSelected:)];
    self.btnDownOne.frame = CGRectMake(0, 0, 18, 18);
    
    self.btnDownTwo = [self buttonWithImageNamed:@"s_down_arrow.png"
                                     andSelector:@selector(downSelected:)];
    self.btnDownTwo.frame = CGRectMake(0, 0, 18, 18);
    
	self.btnBold = [self buttonWithImageNamed:@"bold.png"
								  andSelector:@selector(boldSelected:)];
	
	
	self.btnItalic = [self buttonWithImageNamed:@"italic.png"
									andSelector:@selector(italicSelected:)];
	
	
	self.btnUnderline = [self buttonWithImageNamed:@"underline.png"
									   andSelector:@selector(underLineSelected:)];
	
	self.btnStrikeThrough = [self buttonWithImageNamed:@"strikethrough"
										   andSelector:@selector(strikeThroughSelected:)];
	
    self.btnSuperScript = [self buttonWithImageNamed:@"superscript.png"
                                       andSelector:@selector(superScriptSelected:)];
    
    self.btnSubScript = [self buttonWithImageNamed:@"subscript.png"
                                           andSelector:@selector(subScriptSelected:)];
    
	self.btnTextAlignmentLeft = [self buttonWithImageNamed:@"justifyleft.png"
											   andSelector:@selector(textAlignmentSelected:)];
	
	
	self.btnTextAlignmentCenter = [self buttonWithImageNamed:@"justifycenter.png"
												 andSelector:@selector(textAlignmentSelected:)];
	
	
	self.btnTextAlignmentRight = [self buttonWithImageNamed:@"justifyright.png"
												andSelector:@selector(textAlignmentSelected:)];
	
	self.btnTextAlignmentJustified = [self buttonWithImageNamed:@"justifyfull.png"
													andSelector:@selector(textAlignmentSelected:)];
	
	self.btnForegroundColor = [self buttonWithImageNamed:@"forecolor.png"
											 andSelector:@selector(textForegroundColorSelected:)];
	
	self.btnBackgroundColor = [self buttonWithImageNamed:@"backcolor.png"
											 andSelector:@selector(textBackgroundColorSelected:)];
	
	self.btnBulletPoint = [self buttonWithImageNamed:@"bullist.png"
										 andSelector:@selector(bulletPointSelected:)];
	
	self.btnParagraphIndent = [self buttonWithImageNamed:@"indent.png"
											 andSelector:@selector(paragraphIndentSelected:)];
	
	self.btnParagraphOutdent = [self buttonWithImageNamed:@"outdent.png"
											  andSelector:@selector(paragraphOutdentSelected:)];
	
	self.btnParagraphFirstLineHeadIndent = [self buttonWithImageNamed:@"firstLineIndent.png"
														  andSelector:@selector(paragraphHeadIndentOutdentSelected:)];
}

- (RichTextEditorToggleButton *)buttonWithImageNamed:(NSString *)image width:(NSInteger)width andSelector:(SEL)selector
{
	RichTextEditorToggleButton *button = [[RichTextEditorToggleButton alloc] init];
	[button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
	[button setFrame:CGRectMake(0, 0, width, 0)];
	[button.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
	[button.titleLabel setTextColor:[UIColor blackColor]];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *img = [UIImage imageNamed:image inBundle:bundle compatibleWithTraitCollection:nil];
	[button setImage:img forState:UIControlStateNormal];
	
	return button;
}

- (RichTextEditorToggleButton *)buttonWithImageNamed:(NSString *)image andSelector:(SEL)selector
{
	return [self buttonWithImageNamed:image width:ITEM_WITH andSelector:selector];
}

- (UIView *)separatorView
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.frame.size.height)];
	view.backgroundColor = [UIColor lightGrayColor];
	
	return view;
}

- (void)addView:(UIView *)view afterView:(UIView *)otherView withSpacing:(BOOL)space
{
	CGRect otherViewRect = (otherView) ? otherView.frame : CGRectZero;
	CGRect rect = view.frame;
	rect.origin.x = otherViewRect.size.width + otherViewRect.origin.x;
	if (space)
		rect.origin.x += ITEM_SEPARATOR_SPACE;
	
	rect.origin.y = ITEM_TOP_AND_BOTTOM_BORDER;
	rect.size.height = self.frame.size.height - (2*ITEM_TOP_AND_BOTTOM_BORDER);
	view.frame = rect;
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	[self addSubview:view];
	[self updateContentSize];
}

- (void)updateContentSize
{
	NSInteger maxViewlocation = 0;
	
	for (UIView *view in self.subviews)
	{
		NSInteger endLocation = view.frame.size.width + view.frame.origin.x;
		
		if (endLocation > maxViewlocation)
			maxViewlocation = endLocation;
	}
	
	self.contentSize = CGSizeMake(maxViewlocation+ITEM_SEPARATOR_SPACE, self.frame.size.height);
}

- (void)presentViewController:(UIViewController *)viewController fromView:(UIView *)view
{
	if ([self.dataSource presentationStyleForRichTextEditorToolbar] == RichTextEditorToolbarPresentationStyleModal)
	{
		viewController.modalPresentationStyle = [self.dataSource modalPresentationStyleForRichTextEditorToolbar];
		viewController.modalTransitionStyle = [self.dataSource modalTransitionStyleForRichTextEditorToolbar];
		[[self.dataSource firsAvailableViewControllerForRichTextEditorToolbar] presentViewController:viewController animated:YES completion:nil];
	}
	else if ([self.dataSource presentationStyleForRichTextEditorToolbar] == RichTextEditorToolbarPresentationStylePopover)
	{
		id <RichTextEditorPopover> popover = [self popoverWithViewController:viewController];
		[popover presentPopoverFromRect:view.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
	}
}

- (id <RichTextEditorPopover>)popoverWithViewController:(UIViewController *)viewController
{
	id <RichTextEditorPopover> popover;
	
	if (!popover)
	{
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			popover = (id<RichTextEditorPopover>) [[UIPopoverController alloc] initWithContentViewController:viewController];
		}
		else
		{
			popover = (id<RichTextEditorPopover>) [[WEPopoverController alloc] initWithContentViewController:viewController];
		}
	}
	
	[self.popover dismissPopoverAnimated:YES];
	self.popover = popover;
	
	return popover;
}

- (void)dismissViewController
{
	if ([self.dataSource presentationStyleForRichTextEditorToolbar] == RichTextEditorToolbarPresentationStyleModal)
	{
		[[self.dataSource firsAvailableViewControllerForRichTextEditorToolbar] dismissViewControllerAnimated:YES completion:NO];
	}
	else if ([self.dataSource presentationStyleForRichTextEditorToolbar] == RichTextEditorToolbarPresentationStylePopover)
	{
		[self.popover dismissPopoverAnimated:YES];
	}
}

#pragma mark - RichTextEditorColorPickerViewControllerDelegate & RichTextEditorColorPickerViewControllerDataSource Methods -

- (void)richTextEditorColorPickerViewControllerDidSelectColor:(UIColor *)color withAction:(RichTextEditorColorPickerAction)action
{
	if (action == RichTextEditorColorPickerActionTextBackgroundColor)
	{
		[self.delegate richTextEditorToolbarDidSelectTextBackgroundColor:color];
	}
	else
	{
		[self.delegate richTextEditorToolbarDidSelectTextForegroundColor:color];
	}
	
	[self dismissViewController];
}

- (void)richTextEditorColorPickerViewControllerDidSelectClose
{
	[self dismissViewController];
}

- (BOOL)richTextEditorColorPickerViewControllerShouldDisplayToolbar
{
	return ([self.dataSource presentationStyleForRichTextEditorToolbar] == RichTextEditorToolbarPresentationStyleModal) ? YES: NO;
}

#pragma mark - RichTextEditorFontSizePickerViewControllerDelegate & RichTextEditorFontSizePickerViewControllerDataSource Methods -

- (void)richTextEditorFontSizePickerViewControllerDidSelectFontSize:(NSNumber *)fontSize
{
	[self.delegate richTextEditorToolbarDidSelectFontSize:fontSize];
	[self dismissViewController];
}

- (void)richTextEditorFontSizePickerViewControllerDidSelectClose
{
	[self dismissViewController];
}

- (BOOL)richTextEditorFontSizePickerViewControllerShouldDisplayToolbar
{
	return ([self.dataSource presentationStyleForRichTextEditorToolbar] == RichTextEditorToolbarPresentationStyleModal) ? YES: NO;
}

- (NSArray *)richTextEditorFontSizePickerViewControllerCustomFontSizesForSelection
{
	return [self.dataSource fontSizeSelectionForRichTextEditorToolbar];
}

#pragma mark - RichTextEditorFontPickerViewControllerDelegate & RichTextEditorFontPickerViewControllerDataSource Methods -

- (void)richTextEditorFontPickerViewControllerDidSelectFontWithName:(NSString *)fontName
{
	[self.delegate richTextEditorToolbarDidSelectFontWithName:fontName];
	[self dismissViewController];
}

- (void)richTextEditorFontPickerViewControllerDidSelectClose
{
	[self dismissViewController];
}

- (NSArray *)richTextEditorFontPickerViewControllerCustomFontFamilyNamesForSelection
{
	return [self.dataSource fontFamilySelectionForRichTextEditorToolbar];
}

- (BOOL)richTextEditorFontPickerViewControllerShouldDisplayToolbar
{
	return ([self.dataSource presentationStyleForRichTextEditorToolbar] == RichTextEditorToolbarPresentationStyleModal) ? YES: NO;
}

#pragma mark - FontPickerDelegate

- (void) closeFontPicker {
    if (self.wePopoverController != nil && self.wePopoverController.popoverVisible) {
        [self.wePopoverController dismissPopoverAnimated:YES];
        self.wePopoverController = nil;
        [self.delegate richTextEditorToolbarDidScroll:YES];
    }
}

- (void) selectedFont:(NSString *)fontName
{
    [self.delegate richTextEditorToolbarDidSelectFontWithName:fontName];
}

- (void) selectedFontSize:(NSNumber *)fontSize
{
    [self.delegate richTextEditorToolbarDidSelectFontSize:fontSize];
}

#pragma mark - ColorPickerVCDelegate
- (void) closeColorPicker {
    if (self.wePopoverController != nil && self.wePopoverController.popoverVisible) {
        [self.wePopoverController dismissPopoverAnimated:YES];
        self.wePopoverController = nil;
        [self.delegate richTextEditorToolbarDidScroll:YES];
    }
}

- (void) selectedColor:(UIColor *)color {
    [self.delegate richTextEditorToolbarDidSelectTextForegroundColor:color];
}

- (void) selectedHighlightColor:(UIColor *)color {
    [self.delegate richTextEditorToolbarDidSelectTextBackgroundColor:color];
}

#pragma mark - Util

- (BOOL)isIPad {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (BOOL)isIPhone {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

- (BOOL)isPortrait {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if(screenRect.size.height < screenRect.size.width){
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - WEPopoverControllerDelegate
- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    [self.delegate richTextEditorToolbarDidScroll:YES];
    return YES;
}
@end
