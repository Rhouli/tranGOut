//
//  ModifyEventController.m
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "ModifyEventController.h"

@interface ModifyEventController () <UITextFieldDelegate>
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPopoverController *popOverForDatePicker;
@end

@implementation ModifyEventController 

- (void)viewDidLoad {
    self.boldFontButton.tag = 0;
    self.italicFontButton.tag = 0;
    self.greenColorButton.tag = 0;
    self.blueColorButton.tag = 0;
    self.redColorButton.tag = 0;
    [self resetFont];
}

-(IBAction)showDatePicker:(id)sender{
    // hide keyboard and button
    self.submitButton.hidden = YES;
    [self.view endEditing:YES];
    
    // mark which button it is for later
    self.startTime.tag = 0;
    self.startTime.tag = 0;
    UIButton* senderButton = (UIButton *)sender;
    senderButton.tag = 1;
    
    if ([self.view viewWithTag:9]) {
        return;
    }
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    
    UIView *whiteView = [[UIView alloc] initWithFrame:self.view.bounds];
    whiteView.alpha = 0;
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    [whiteView addGestureRecognizer:tapGesture];
    [self.view addSubview:whiteView];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    self.datePicker.tag = 10;
    [self.datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    if([sender titleForState:UIControlStateNormal] != NULL){
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterShortStyle];
        [dateFormat setTimeStyle:NSDateFormatterShortStyle];
        [self.datePicker setDate:[dateFormat dateFromString:[sender titleForState:UIControlStateNormal]]];
    }
    [self.view addSubview:self.datePicker];
    
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 280, 44)];
    self.toolBar.tag = 11;
    self.toolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    doneButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    doneButton.frame = (CGRect) {
        .size.width = 80,
        .size.height = 30,
    };
    [doneButton addTarget:self action:@selector(dismissDatePicker:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    [self.toolBar setItems:[NSArray arrayWithObjects:spacer, doneBarButton, nil]];
    [self.view addSubview:self.toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    self.toolBar.frame = toolbarTargetFrame;
    self.datePicker.frame = datePickerTargetFrame;
    whiteView.alpha = 0.5;
    [UIView commitAnimations];
}


-(UIImage *)imageFromText:(NSString *)text {
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:16.0];
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGSize size  = [text sizeWithAttributes:attributes];
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(size);
    
    // draw in context, you can use also drawInRect:withFont:
    [text drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:attributes];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
    self.submitButton.hidden = NO;
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (void)changeDate:(UIDatePicker *)sender {
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    
    if(self.startTime.tag){
        [self.startTime setTitle:[dateFormat stringFromDate:[sender date]] forState:UIControlStateNormal];
        if ([[self.endTime titleLabel] text] == nil){
            NSDate* newDate = [self addToDate:[sender date] numberOfHours:3];
            [self.endTime setTitle:[dateFormat stringFromDate:newDate] forState:UIControlStateNormal];
        } else if([[dateFormat dateFromString:[[self.endTime titleLabel] text]] compare:[sender date]]==NSOrderedAscending){
            [self.endTime setTitle:[dateFormat stringFromDate:[sender date]] forState:UIControlStateNormal];
        }
    } else if(self.endTime.tag){
        [self.endTime setTitle:[dateFormat stringFromDate:[sender date]] forState:UIControlStateNormal];
        if ([[self.startTime titleLabel] text] == nil){
            NSDate* newDate = [self addToDate:[sender date] numberOfHours:-3];
            [self.startTime setTitle:[dateFormat stringFromDate:newDate] forState:UIControlStateNormal];
        } else if([[dateFormat dateFromString:[[self.startTime titleLabel] text]] compare:[sender date]]==NSOrderedDescending){
            [self.startTime setTitle:[dateFormat stringFromDate:[sender date]] forState:UIControlStateNormal];
        }
    }
    NSLog(@"Picked the date %@", [dateFormat stringFromDate:[sender date]]);
}

- (NSDate *)addToDate:(NSDate *)date numberOfHours:(NSInteger)hoursToAdd {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:hoursToAdd];
    return [calendar dateByAddingComponents:components toDate:date options:0];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:textField.frame];
    datePicker.datePickerMode = UIDatePickerModeTime;
    [datePicker addTarget:self action:@selector(changeTextFieldValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    return YES;
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
    //[self.datePicker removeFromSuperview];
}

-(void)changeTextFieldValue:(id)sender {
    NSDate *date = [sender date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"hh-mm"];
    NSString *dateString = [dateFormatter stringFromDate:date ];
    self.eventTitle.text = dateString;
}

-(void)LabelChange:(id)sender {
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateStyle = NSDateFormatterMediumStyle;
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[df stringFromDate:self.datePicker.date]]);
}

- (void)resetFont {
    float fontSize = self.eventInfo.font.pointSize;
    UIColor *foregroundColor;
    UIFont *font;
    if(self.greenColorButton.tag != 0)
        foregroundColor = [UIColor greenColor];
    else if(self.blueColorButton.tag != 0)
        foregroundColor = [UIColor blueColor];
    else if(self.redColorButton.tag != 0)
        foregroundColor = [UIColor redColor];
    else
        foregroundColor = [UIColor blackColor];
    if(self.boldFontButton.tag != 0 && self.italicFontButton.tag !=0)
        font = [UIFont fontWithName:@"Trebuchet-BoldItalic" size:fontSize];
    else if(self.boldFontButton.tag !=0)
        font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:fontSize];
    else if(self.italicFontButton.tag != 0)
        font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:fontSize];
    else
        font = [UIFont fontWithName:@"TrebuchetMS" size:fontSize];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           font, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    [self.eventInfo setTypingAttributes:attrs];
}

- (IBAction)boldFontChanged:(id)sender {
    if(self.boldFontButton.tag == 0){
        self.boldFontButton.tag = 1;
        [self.boldFontButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self resetFont];
    } else {
        self.boldFontButton.tag = 0;
        [self.boldFontButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self resetFont];
    }
}

- (IBAction)ItalicFontChanged:(id)sender {
    if(self.italicFontButton.tag == 0){
        self.italicFontButton.tag = 1;
        [self.italicFontButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self resetFont];
    } else {
        self.italicFontButton.tag = 0;
        [self.italicFontButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self resetFont];
    }
}

- (IBAction)colorSelected:(UIButton*)sender {
    if(sender.tag == 1) {
        sender.tag = 0;
        
        [self resetColorButtons];
    }
    else if (sender.tag == 0) {
        self.greenColorButton.tag = 0;
        self.blueColorButton.tag = 0;
        self.redColorButton.tag = 0;
        
        [self resetColorButtons];
        
        sender.tag = 1;
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor blackColor]];
        [sender setTitle:@"Black" forState:UIControlStateNormal];
    }
    [self resetFont];
}

- (void)resetColorButtons {
    [self.greenColorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.greenColorButton setBackgroundColor:[UIColor greenColor]];
    [self.greenColorButton setTitle:@"Green" forState:UIControlStateNormal];
    [self.blueColorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.blueColorButton setBackgroundColor:[UIColor blueColor]];
    [self.blueColorButton setTitle:@"Blue" forState:UIControlStateNormal];
    [self.redColorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.redColorButton setBackgroundColor:[UIColor redColor]];
    [self.redColorButton setTitle:@"Red" forState:UIControlStateNormal];
}

@end
