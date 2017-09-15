//
//  FontPickerController.m
//  RichTextEditor
//
//  Created by Young Kim on 2012-12-23.
//
//

#import "FontPickerController.h"

@interface FontPickerController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation FontPickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    if(self.fontNames == nil || [self.fontNames count]==0){
        self.fontNames = @[@"American Typewriter",@"Apple SD Gothic Neo",@"Arial",@"Arial Rounded MT Bold",@"Avenir",@"Avenir Next",@"Courier",@"Courier New",@"Georgia",
                           @"Helvetica",@"Helvetica Neue",@"Menlo",@"Optima",@"Papyrus",@"Times New Roman",@"Trebuchet MS",@"Verdana",@"Zapfino"];
    }
    
    if(self.fontSizes == nil || [self.fontSizes count]==0){
        self.fontSizes =  @[@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@20,@24,@30,@36,@48,@64,@72,@96];
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    for(int i = 0; i < [self.fontNames count]; i++){
        if([self.currentFont isEqualToString:self.fontNames[i]]){
            [self.pickerView selectRow:i inComponent:0 animated:YES];
        }
    }

    for(int i = 0; i < [self.fontSizes count]; i++){
        NSString *strFontSize = [NSString stringWithFormat:@"%d",[self.fontSizes[i] intValue]];
        if([self.currentSize isEqualToString:strFontSize]){
            [self.pickerView selectRow:i inComponent:1 animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
    if (component == kNameComponent)
        return [self.fontNames count];
    else
        return [self.fontSizes count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
    if (component == kNameComponent)
        return [self.fontNames objectAtIndex:row];
    else
        return [self.fontSizes objectAtIndex:row];
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    
    UILabel *pickerLabel = [[UILabel alloc] init];
    if (component == kNameComponent) {
        pickerLabel.textColor = [UIColor darkGrayColor];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.text = self.fontNames[row];
        pickerLabel.font = [UIFont fontWithName:self.fontNames[row] size:16];
    }else{
        pickerLabel.textColor = [UIColor darkGrayColor];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.text = [NSString stringWithFormat:@"%d", [self.fontSizes[row] intValue]];
        pickerLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    }
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
    if (component == kNameComponent){
        [self.fontPickerDelegate selectedFont:self.fontNames[row]];
    }else{
        [self.fontPickerDelegate selectedFontSize:self.fontSizes[row]];
    }
}


- (IBAction)onClose
{
    [self.fontPickerDelegate closeFontPicker];
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    switch (component){
        case 0:
            
            return 202.0f;
        case 1:
            return 55.0f;
    }
    return 0;
}

@end
