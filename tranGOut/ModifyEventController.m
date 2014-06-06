//
//  ModifyEventController.m
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ModifyEventController.h"

@interface ModifyEventController () <UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPopoverController *popOverForDatePicker;
@end

@implementation ModifyEventController 

- (void)viewDidLoad {
    [self createScrollView];
}

- (void) createScrollView{
    const float maxLabelWidth = (1-2*INPUTBOXWIDTHOFFSETPERCENT)*self.view.frame.size.width;
    const float standardLabelHeight = maxLabelWidth/10.0;
    const float viewHeaderHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    // create scrollview
    
    CGPoint scrollViewPoint = CGPointMake(0, LABELSPACING/2+viewHeaderHeight);
    CGSize scrollViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-scrollViewPoint.y-self.navigationController.navigationBar.frame.size.height);
    CGRect scrollViewRect = {scrollViewPoint, scrollViewSize};
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    // Create all input labels
    // Event Title
    CGPoint eventTitlePoint = CGPointMake(SIDESPACING, 0);
    CGSize eventTitleSize = CGSizeMake(maxLabelWidth, standardLabelHeight);
    CGRect eventTitleRect = {eventTitlePoint, eventTitleSize};
    
    self.eventTitle = [[UITextField alloc] initWithFrame:eventTitleRect];
    self.eventTitle.borderStyle = UITextBorderStyleRoundedRect;
    [self.eventTitle setBackgroundColor:[colorUtility opaqueWhiteColor]];
    [self changePlaceholderText:self.eventTitle withString:@"Title"];
    [self.eventTitle setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.eventTitle.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.eventTitle.textAlignment = NSTextAlignmentCenter;
    [self.eventTitle setTextColor:[UIColor blackColor]];
    self.eventTitle.layer.cornerRadius = CORNERRADIUS;
    [[self.eventTitle layer] setBorderWidth:2.0f];
    [[self.eventTitle layer] setBorderColor:[colorUtility darkLabelColor].CGColor];

    // Location Title
    CGPoint eventLocationPoint = CGPointMake(eventTitlePoint.x, eventTitlePoint.y + eventTitleSize.height + LABELSPACING);
    CGSize eventLocationSize = CGSizeMake(maxLabelWidth, standardLabelHeight);
    CGRect eventLocationRect = {eventLocationPoint, eventLocationSize};
    
    self.eventLocation = [[UITextField alloc] initWithFrame:eventLocationRect];
    self.eventLocation.borderStyle = UITextBorderStyleRoundedRect;
    [self.eventLocation setBackgroundColor:[colorUtility opaqueWhiteColor]];
    [self changePlaceholderText:self.eventLocation withString:@"Location"];
    [self.eventLocation setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.eventLocation.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.eventLocation.textAlignment = NSTextAlignmentCenter;
    [self.eventLocation setTextColor:[UIColor blackColor]];
    self.eventLocation.layer.cornerRadius = CORNERRADIUS;
    [[self.eventLocation layer] setBorderWidth:2.0f];
    [[self.eventLocation layer] setBorderColor:[colorUtility darkLabelColor].CGColor];

    // From Text Label
    CGSize fromLabelSize = CGSizeMake(eventLocationSize.width/2.0-SIDESPACING/2, eventLocationSize.height/2.0);
    CGPoint fromLabelPoint = CGPointMake(eventLocationPoint.x, eventLocationPoint.y + eventLocationSize.height + LABELSPACING);
    CGRect fromLabelRect = {fromLabelPoint, fromLabelSize};
    
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:fromLabelRect];
    [fromLabel setText:@"From"];
    [fromLabel setTextColor:[colorUtility textColor]];
    [fromLabel setTextAlignment:NSTextAlignmentCenter];
    fromLabel.font = [fromLabel.font fontWithSize:12];
    
    // To Text Label
    CGSize toLabelSize = fromLabelSize;
    CGPoint toLabelPoint = CGPointMake(fromLabelPoint.x+fromLabelSize.width+SIDESPACING, fromLabelPoint.y);
    CGRect toLabelRect = {toLabelPoint, toLabelSize};
    
    UILabel *toLabel = [[UILabel alloc] initWithFrame:toLabelRect];
    [toLabel setText:@"To"];
    [toLabel setTextColor:[colorUtility textColor]];
    [toLabel setTextAlignment:NSTextAlignmentCenter];
    toLabel.font = [toLabel.font fontWithSize:12];
    
    // Start time input label
    CGPoint startTimePoint = CGPointMake(fromLabelPoint.x, fromLabelPoint.y+fromLabelSize.height+1);
    CGSize startTimeSize = CGSizeMake(fromLabelSize.width, standardLabelHeight);
    CGRect startTimeRect = {startTimePoint, startTimeSize};
    
    self.startTime = [[UIButton alloc] initWithFrame:startTimeRect];
    self.startTime.layer.cornerRadius = CORNERRADIUS;
    self.startTime.clipsToBounds = YES;
    [self.startTime setBackgroundColor:[colorUtility opaqueWhiteColor]];
    self.startTime.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.startTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.startTime setUserInteractionEnabled:YES];
    [self.startTime addTarget:self action:@selector(showDatePicker:) forControlEvents: UIControlEventTouchUpInside];
    [[self.startTime layer] setBorderWidth:2.0f];
    [[self.startTime layer] setBorderColor:[colorUtility darkLabelColor].CGColor];

    // end time input label
    CGPoint endTimePoint = CGPointMake(toLabelPoint.x, toLabelPoint.y+toLabelSize.height+1);
    CGSize endTimeSize = startTimeSize;
    CGRect endTimeRect = {endTimePoint, endTimeSize};
    
    self.endTime = [[UIButton alloc] initWithFrame:endTimeRect];
    self.endTime.layer.cornerRadius = CORNERRADIUS;
    self.endTime.clipsToBounds = YES;
    [self.endTime setBackgroundColor:[colorUtility opaqueWhiteColor]];
    self.endTime.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.endTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.endTime setUserInteractionEnabled:YES];
    [self.endTime addTarget:self action:@selector(showDatePicker:) forControlEvents: UIControlEventTouchUpInside];
    [[self.endTime layer] setBorderWidth:2.0f];
    [[self.endTime layer] setBorderColor:[colorUtility darkLabelColor].CGColor];

    // add event info
    CGPoint eventInfoPoint = CGPointMake(startTimePoint.x, startTimePoint.y+startTimeSize.height+LABELSPACING);
    CGSize eventInfoSize = CGSizeMake(maxLabelWidth, maxLabelWidth/2.0);
    CGRect eventInfoRect = {eventInfoPoint, eventInfoSize};
    
    self.eventInfo = [[UITextView alloc] initWithFrame:eventInfoRect];
    [self.eventInfo setBackgroundColor:[colorUtility textFieldColor]];
    self.eventInfo.textColor = [colorUtility opaqueWhiteColor];
    self.eventInfo.text = @"Enter information about event...";
    self.eventInfo.layer.cornerRadius = CORNERRADIUS;
    [self.eventInfo setUserInteractionEnabled:YES];
    [self.eventInfo setDelegate:self];
    [self.eventInfo scrollRectToVisible:eventInfoRect animated:NO];
    //[self.eventInfo becomeFirstResponder];
    
    // make bold button
    CGPoint boldFontButtonPoint = CGPointMake(eventInfoPoint.x, eventInfoPoint.y+eventInfoSize.height);
    CGSize boldFontButtonSize = CGSizeMake(15, 18);
    CGRect boldFontButtonRect = {boldFontButtonPoint, boldFontButtonSize};
    
    self.boldFontButton = [[UIButton alloc] initWithFrame:boldFontButtonRect];
    [self.boldFontButton setBackgroundColor:[UIColor blackColor]];
    [self.boldFontButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.boldFontButton setTitle:@"B" forState:UIControlStateNormal];
    self.boldFontButton.layer.cornerRadius = CORNERRADIUS/2;
    [self.boldFontButton setUserInteractionEnabled:YES];
    self.boldFontButton.tag = 0;
    [self.boldFontButton addTarget:self action:@selector(boldFontChanged:) forControlEvents: UIControlEventTouchUpInside];
    
    // make italic button
    CGPoint italicFontButtonPoint = CGPointMake(boldFontButtonPoint.x+boldFontButtonSize.width, boldFontButtonPoint.y);
    CGSize italicFontButtonSize = boldFontButtonSize;
    CGRect italicFontButtonRect = {italicFontButtonPoint, italicFontButtonSize};
    
    self.italicFontButton = [[UIButton alloc] initWithFrame:italicFontButtonRect];
    [self.italicFontButton setBackgroundColor:[UIColor whiteColor]];
    [self.italicFontButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.italicFontButton setTitle:@"I" forState:UIControlStateNormal];
    self.italicFontButton.layer.cornerRadius = CORNERRADIUS/2;
    [self.italicFontButton setUserInteractionEnabled:YES];
    self.italicFontButton.tag = 0;
    [self.italicFontButton addTarget:self action:@selector(ItalicFontChanged:) forControlEvents: UIControlEventTouchUpInside];
    
    // add guest input label
    CGSize addGuestButtonSize = CGSizeMake(maxLabelWidth/2.0, standardLabelHeight);
    CGPoint addGuestButtonPoint = CGPointMake(eventInfoPoint.x+maxLabelWidth/4, italicFontButtonPoint.y+italicFontButtonSize.height+8*LABELSPACING);
    CGRect addGuestButtonRect = {addGuestButtonPoint, addGuestButtonSize};
    
    self.addGuestButton = [[UIButton alloc] initWithFrame:addGuestButtonRect];
    self.addGuestButton.layer.cornerRadius = CORNERRADIUS;
    self.addGuestButton.clipsToBounds = YES;
    [self.addGuestButton setBackgroundColor:[colorUtility opaqueWhiteColor]];
    self.addGuestButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.addGuestButton setTitleColor:[colorUtility textColor] forState:UIControlStateNormal];
    [self.addGuestButton setTitle:@"Invite Guests" forState:UIControlStateNormal];
    [self.addGuestButton setUserInteractionEnabled:YES];
    [self.addGuestButton addTarget:self action:@selector(addGuest:) forControlEvents: UIControlEventTouchUpInside];
    [[self.addGuestButton layer] setBorderWidth:2.0f];
    [[self.addGuestButton layer] setBorderColor:[colorUtility buttonColor].CGColor];
    
    // add submit button
    const float additionalSpacing = 15;
    CGPoint submitButtonPoint = CGPointMake(self.addGuestButton.frame.origin.x - additionalSpacing, self.addGuestButton.frame.origin.y+self.addGuestButton.frame.size.height+2*LABELSPACING);
    CGSize submitButtonSize = addGuestButtonSize;
    submitButtonSize.width = submitButtonSize.width + 2*additionalSpacing;
    CGRect submitButtonRect = {submitButtonPoint, submitButtonSize};
    
    self.submitButton = [[UIButton alloc] initWithFrame:submitButtonRect];
    self.submitButton.layer.cornerRadius = CORNERRADIUS;
    self.submitButton.clipsToBounds = YES;
    [self.submitButton setBackgroundColor:[colorUtility buttonColor]];
    self.submitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.submitButton setTitleColor:[colorUtility textMatchingBackgroundColor] forState:UIControlStateNormal];
    [self.submitButton setUserInteractionEnabled:YES];
    
    self.greenColorButton.tag = 0;
    self.blueColorButton.tag = 0;
    self.redColorButton.tag = 0;
    
    [self resetFont];
    
    // add views to scroll view
    [self.scrollView addSubview:self.eventTitle];
    [self.scrollView addSubview:self.eventLocation];
    [self.scrollView addSubview:fromLabel];
    [self.scrollView addSubview:toLabel];
    [self.scrollView addSubview:self.startTime];
    [self.scrollView addSubview:self.endTime];
    [self.scrollView addSubview:self.eventInfo];
    [self.scrollView addSubview:self.boldFontButton];
    [self.scrollView addSubview:self.italicFontButton];
    [self.scrollView addSubview:self.addGuestButton];
    [self.scrollView addSubview:self.submitButton];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, submitButtonPoint.y+submitButtonSize.height+LABELSPACING*2);
}
- (void)changePlaceholderText:(UITextField*)textField withString:(NSString *)placeholderText{
    // set placeholder text color for eventlocation and eventtitle
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [colorUtility opaqueWhiteColor];
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
}
- (IBAction)addGuest:(id)sender{
    NSLog(@"Guest added");
}

-(IBAction)showDatePicker:(id)sender{
    // hide keyboard and button
    self.submitButton.hidden = YES;
    self.addGuestButton.hidden  = YES;
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
    self.addGuestButton.hidden = NO;
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

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
    //[self.datePicker removeFromSuperview];
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
        foregroundColor = [UIColor whiteColor];
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
        [sender setBackgroundColor:[UIColor whiteColor]];
        [sender setTitle:@"White" forState:UIControlStateNormal];
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

#pragma mark Text View and Field Delegates

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.activeField = textView;
    if ([textView.text isEqualToString:@"Enter information about event..."]) {
        textView.text = @"";
        [self resetFont];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.activeField = nil;
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter information about event...";
        textView.textColor = [colorUtility opaqueWhiteColor];
    }
    [textView resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}


@end
