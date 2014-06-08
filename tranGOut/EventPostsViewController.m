//
//  EventPostsViewController.m
//  tranGOut
//
//  Created by Ryan on 6/5/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

#import "AttributedStringCoderHelper.h"
#import "EventPostsViewController.h"
#import "colorAndFontUtility.h"

#define MAXPOSTVIEWWIDTH 0.8

@interface EventPostsViewController () <UITextViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextView *postTextInputView;
@property (strong, nonatomic) UIButton *submitPostButton;
@property (strong, nonatomic) NSMutableArray *postFieldArray;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIView* activeField;
@end

@implementation EventPostsViewController 

#pragma mark viewcontroller lifecycle
- (void)viewDidLoad {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapRecognizer];
    self.tabBarController.tabBar.hidden=YES;
    
    self.navigationItem.title = @"Event Discussion";
    
    [self.view setBackgroundColor:[colorAndFontUtility backgroundColor]];
    
    self.postFieldArray = [[NSMutableArray alloc] init];
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    self.spinner.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.spinner.color = [colorAndFontUtility textColor];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden=NO;
}

- (void)viewDidLayoutSubviews {
    [self createScrollView];
    [self.scrollView addSubview:self.spinner];
    [self.spinner startAnimating];
    
    [self downloadPostsAndCreateScrollViewContent];
    
    [self registerForKeyboardNotifications];
}

#pragma mark create view

- (void)createScrollView {
    // create scrollview
    const float viewHeaderHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGPoint scrollViewPoint = CGPointMake(0, viewHeaderHeight);
    CGSize scrollViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-scrollViewPoint.y);
    CGRect scrollViewRect = {scrollViewPoint, scrollViewSize};
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
}

-(void)createScrollViewContents {
    const float maxLabelWidth = (1-2*INPUTBOXWIDTHOFFSETPERCENT)*self.view.frame.size.width;
    const float standardLabelHeight = maxLabelWidth/10.0;

    // input all the posts
    for(int i = 0; i < [self.postFieldArray count]; i++){
        UITextView* postView = [self.postFieldArray objectAtIndex:i];
        [self.scrollView addSubview:postView];
    }
    
    // add event info
    UITextView* lastView = [self.postFieldArray lastObject];
    CGPoint postTextInputViewPoint;
    CGSize postTextInputViewSize;
    
    if(lastView){
        postTextInputViewPoint = CGPointMake(self.scrollView.frame.origin.x+LABELSPACING, lastView.frame.origin.y+lastView.frame.size.height+3*LABELSPACING);
        postTextInputViewSize = CGSizeMake(maxLabelWidth, maxLabelWidth/4.0);
    } else {
        postTextInputViewPoint = CGPointMake(LABELSPACING, LABELSPACING);
        postTextInputViewSize = CGSizeMake(maxLabelWidth, maxLabelWidth/4.0);
    }
    CGRect postTextInputViewRect = {postTextInputViewPoint, postTextInputViewSize};

    self.postTextInputView = [[UITextView alloc] initWithFrame:postTextInputViewRect];
    [self.postTextInputView setBackgroundColor:[colorAndFontUtility textFieldColor]];
    self.postTextInputView.textColor = [colorAndFontUtility opaqueWhiteColor];
    self.postTextInputView.text = @"Enter a new posting...";
    self.postTextInputView.layer.cornerRadius = CORNERRADIUS;
    [self.postTextInputView setUserInteractionEnabled:YES];
    [self.postTextInputView setDelegate:self];
    [self.postTextInputView scrollRectToVisible:postTextInputViewRect animated:NO];

    // end time input label
    CGPoint submitPostButtonPoint = CGPointMake(LABELSPACING + maxLabelWidth/4, postTextInputViewPoint.y+postTextInputViewSize.height+LABELSPACING);
    CGSize submitPostButtonSize = CGSizeMake(maxLabelWidth/2.0, standardLabelHeight);
    CGRect submitPostButtonRect = {submitPostButtonPoint, submitPostButtonSize};
    
    self.submitPostButton = [[UIButton alloc] initWithFrame:submitPostButtonRect];
    [colorAndFontUtility buttonStyleThree:self.submitPostButton withRoundEdges:YES];
    [self.submitPostButton setTitle:@"Submit Post" forState:UIControlStateNormal];
    [self.submitPostButton addTarget:self action:@selector(submitPost:) forControlEvents: UIControlEventTouchUpInside];

    [self.scrollView addSubview:self.postTextInputView];
    [self.scrollView addSubview:self.submitPostButton];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, submitPostButtonPoint.y+submitPostButtonSize.height+LABELSPACING*2);
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    if(self.scrollView.contentSize.height > self.scrollView.frame.size.height){
        [self.scrollView setContentOffset:bottomOffset animated:NO];
    }
    [self.postTextInputView setDelegate:self];
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)buildPostsArray {
    const float maxLabelWidth = (1-2*INPUTBOXWIDTHOFFSETPERCENT)*self.view.frame.size.width;
    if(self.posts){
        for(int i = 0; i < [self.posts count]; i++){
            BOOL currentUsersPost = [[PFUser currentUser].username isEqualToString:[[self.posts objectAtIndex:i] objectForKey:@"creator"]];
            // add event info
            NSMutableAttributedString* body;
            CGRect textRectTitle;
            if(!currentUsersPost){
                body = [[NSMutableAttributedString alloc] initWithString:[[self.posts objectAtIndex:i] objectForKey:@"creator"]];
                [body appendAttributedString:[[NSAttributedString alloc] initWithString:@": \n"]];
                [body setAttributes:@{NSForegroundColorAttributeName:[colorAndFontUtility textColor],
                                      NSUnderlineStyleAttributeName:[NSNumber numberWithInt:1],
                                      NSFontAttributeName:FUTURA_SMALL_FONT}
                              range:(NSRange){0,[body length] }];
            } else {
                body = [[NSMutableAttributedString alloc] initWithString:@""];
                textRectTitle = CGRectMake(0, 0, 0, 0);
            }
            NSAttributedString* content = [AttributedStringCoderHelper decodeAttributedStringFromData:[[self.posts objectAtIndex:i] objectForKey:@"content"]];

            [body appendAttributedString:content];
            
            CGSize userPostViewSize;
            CGPoint userPostViewPoint; 
            if (i == 0){
                userPostViewSize = CGSizeMake(maxLabelWidth*MAXPOSTVIEWWIDTH, 0);
                if(currentUsersPost){
                    userPostViewPoint = CGPointMake(self.scrollView.frame.size.width-userPostViewSize.width-LABELSPACING, 0);
                } else {
                    userPostViewPoint = CGPointMake(LABELSPACING, 0);
                }
            } else {
                UITextView *lastView = [self.postFieldArray lastObject];
                userPostViewSize = CGSizeMake(maxLabelWidth*MAXPOSTVIEWWIDTH, 0);
                if([[PFUser currentUser].username isEqualToString:[[self.posts objectAtIndex:i] objectForKey:@"creator"]]){
                    userPostViewPoint = CGPointMake(self.scrollView.frame.size.width-userPostViewSize.width-LABELSPACING, lastView.frame.origin.y+lastView.frame.size.height+LABELSPACING);
                } else {
                    userPostViewPoint = CGPointMake(LABELSPACING, lastView.frame.origin.y+lastView.frame.size.height+LABELSPACING);
                }
                
            }
            //CGSizeMake(textRect.size.width, textRect.size.height);
            CGRect userPostViewRect = CGRectMake(0, 0, userPostViewSize.width, userPostViewSize.width);
            
            UITextView *userPostView = [[UITextView alloc] initWithFrame:userPostViewRect];
            if(currentUsersPost){
                [colorAndFontUtility postStyleSenderMe:userPostView];
            } else {
                [colorAndFontUtility postStyleSenderOther:userPostView];
            }
            userPostView.attributedText = (NSAttributedString*)body;
            [userPostView scrollRectToVisible:userPostViewRect animated:NO];
            [userPostView sizeToFit];
            [userPostView layoutIfNeeded];
            
            userPostView.frame = CGRectMake(0, 0, userPostView.frame.size.width, userPostView.frame.size.height);
            UILabel *dateLabel = [self insertPostDate:userPostView forDate:[self datePostWasCreated:[self.posts objectAtIndex:i]] withPostByCurrentUser:currentUsersPost];
            
            CGRect postFrame;
            if(currentUsersPost){
                postFrame = CGRectMake(dateLabel.frame.origin.x, userPostViewPoint.y, userPostView.frame.size.width+dateLabel.frame.size.width, userPostView.frame.size.height);
                userPostView.frame = CGRectMake(self.view.frame.size.width -userPostView.frame.size.width - SIDESPACING, 0, userPostView.frame.size.width, userPostView.frame.size.height);
            } else {
                postFrame = CGRectMake(userPostViewPoint.x, userPostViewPoint.y, userPostView.frame.size.width+dateLabel.frame.size.width, userPostView.frame.size.height);
                userPostView.frame = CGRectMake(0, 0, userPostView.frame.size.width, userPostView.frame.size.height);
                
            }
            
            [userPostView setUserInteractionEnabled:NO];
            UIView* totalView = [[UIView alloc] initWithFrame:postFrame];
            [totalView addSubview:userPostView];
            [totalView addSubview:dateLabel];
           
            [self.postFieldArray addObject:totalView];
        }
    }
}

- (UILabel*) insertPostDate:(UITextView*)postView forDate:(NSString*)date withPostByCurrentUser:(BOOL)currentUserPost {
    CGPoint postDatePoint;
    CGSize postDateSize = CGSizeMake(self.scrollView.frame.size.width/4, postView.frame.size.height);
    if(currentUserPost){
        postDatePoint = CGPointMake(-LABELSPACING/2, 0);
    } else {
        postDatePoint = CGPointMake(self.view.frame.size.width-postDateSize.width, 0);
    }
    CGRect postDateRect = {postDatePoint, postDateSize};
    
    UILabel* postDateLabel = [[UILabel alloc] initWithFrame:postDateRect];
    postDateLabel.textColor = [UIColor whiteColor];
    postDateLabel.font = FUTURA_EXTRA_SMALL_FONT;
    postDateLabel.text = date;
    postDateLabel.textAlignment = NSTextAlignmentCenter;
    
    return postDateLabel;
}
- (NSString*) datePostWasCreated:(PFObject*)post {
    NSDate* date = [post createdAt];
    NSLog(@"%@", post);
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyyMMdd]"];
    if( [[fmt stringFromDate:date] isEqualToString:[fmt stringFromDate:[NSDate date]]]){
        [dateFormat setDateFormat:@"HH:mm"];
    } else {
        [dateFormat setDateFormat:@"MMM dd HH:mm"];
    }
    
    return [dateFormat stringFromDate:date];
}

#pragma mark Text View and Field Delegates

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.activeField = textView;
    if ([textView.text isEqualToString:@"Enter a new posting..."]) {
        textView.text = @"";
        textView.textColor = [UIColor whiteColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.activeField = nil;
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter a new posting...";
        textView.textColor = [colorAndFontUtility opaqueWhiteColor];
    }
    [textView resignFirstResponder];
}

#pragma mark database managment
- (IBAction)submitPost:(id)sender {
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    post[@"creator"] = [PFUser currentUser].username;
    post[@"event"] = self.eventTitle;
    post[@"eventId"] = self.eventID;
    post[@"content"] = [AttributedStringCoderHelper encodeAttributedString:[self.postTextInputView attributedText]];
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self reloadPosts];
        } else {
            // error
        }
    }];
}

- (void)reloadPosts {
    [self downloadPostsAndRefreshScrollViewContent];
}

- (void)downloadPostsAndRefreshScrollViewContent {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"eventId" equalTo:self.eventID];
    [query addAscendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"The getFirstObject request failed.");
        } else {
            // The find succeeded.
            NSLog(@"Successfully retrieved the object.");
            [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            self.posts = objects;
            [self buildPostsArray];
            [self createScrollViewContents];
        }
    }];
}

- (void)downloadPostsAndCreateScrollViewContent{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"eventId" equalTo:self.eventID];
    [query addAscendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"The getFirstObject request failed.");
        } else {
            // The find succeeded.
            NSLog(@"Successfully retrieved the object.");
            self.posts = objects;
            [self buildPostsArray];
            [self createScrollViewContents];
            [self.spinner stopAnimating];
        }
    }];
}

- (void)refreshScrollView {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self buildPostsArray];
    [self createScrollViewContents];
}

#pragma mark Keyboard Auto Scrolling

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}



// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);

    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    
    CGRect aRect = self.scrollView.frame;
    aRect.size.height -= kbSize.height;
    if([self.activeField isEqual:self.postTextInputView]){
        if (!CGRectContainsPoint(aRect, self.submitPostButton.frame.origin) ) {
            [self.scrollView scrollRectToVisible:self.submitPostButton.frame animated:YES];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

@end
