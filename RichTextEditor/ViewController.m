//
//  ViewController.m
//  RichTextEdtor
//
//  Created by Aryan Gh on 7/21/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet RichTextEditor *richTextEditor;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //self.richTextEditor.attributedText
    self.richTextEditor.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSArray *)fontFamilySelectionForRichTextEditor:(RichTextEditor *)richTextEditor {
    NSArray *arrFontNames = @[@"American Typewriter",@"Apple SD Gothic Neo",@"Arial",@"Arial Rounded MT Bold",@"Avenir",@"Courier New",@"Georgia",
                              @"Helvetica",@"Helvetica Neue",@"Menlo",@"Optima",@"Papyrus",@"Times New Roman",@"Trebuchet MS",@"Verdana",@"Zapfino"];
    
    return arrFontNames;
}

- (NSArray *)fontSizeSelectionForRichTextEditor:(RichTextEditor *)richTextEditor
{
	// pas an array of NSNumbers
	return @[@9,@10,@11,@12,@13,@14,@17,@18,@24,@36,@48,@64,@72,@96];
}

/*
- (RichTextEditorToolbarPresentationStyle)presentarionStyleForRichTextEditor:(RichTextEditor *)richTextEditor
{
	return RichTextEditorToolbarPresentationStyleModal;
}

- (UIModalPresentationStyle)modalPresentationStyleForRichTextEditor:(RichTextEditor *)richTextEditor
{
	return UIModalPresentationFormSheet;
}

- (UIModalTransitionStyle)modalTransitionStyleForRichTextEditor:(RichTextEditor *)richTextEditor
{
	return UIModalTransitionStyleFlipHorizontal;
}*/

- (RichTextEditorFeature)featuresEnabledForRichTextEditor:(RichTextEditor *)richTextEditor
{
	return RichTextEditorFeatureFontSize | RichTextEditorFeatureFont | RichTextEditorFeatureAll;
}

- (IBAction)savePDF:(UIButton *)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path_pdf = [NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],@"test11111.pdf"];
    
    [self.richTextEditor savePDFFile:path_pdf completion:^(BOOL result){
        if(result){
            NSLog(@"PDF Success");
        }else{
            NSLog(@"PDF Fail");
        }
    
    }];
}

- (IBAction)saveRTF:(UIButton *)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path_rtf = [NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],@"test11111.rtf"];
    [self.richTextEditor saveRTFFile:path_rtf completion:^(BOOL result){
        if(result){
            NSLog(@"RTF Success");
        }else{
            NSLog(@"RTF Fail");
        }
        
    }];
}
- (IBAction)addLink:(UIButton *)sender {
    [self.richTextEditor addFileLink:@"google" shareLink:@"https://www.google.com" completion:^(BOOL result){
        if(result){
            NSLog(@"RTF Success");
        }else{
            NSLog(@"RTF Fail");
        }
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([RichTextEditor isVersionGreaterThanEqualIOS8] && (range.length == 0)) {
        textView.typingAttributes = [self.richTextEditor.myTypingAttributes copy];
        return YES;
    }else{
        return YES;
    }
}
@end
