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
#import "colorUtility.h"

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

- (void)viewDidLoad {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapRecognizer];
    
    self.navigationItem.title = @"Event Discussion";
    [self.view setBackgroundColor:[colorUtility backgroundColor]];
    
    self.postFieldArray = [[NSMutableArray alloc] init];
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,140,50,50)];
    self.spinner.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.spinner.color = [colorUtility textColor];
}

- (void)viewDidLayoutSubviews {
    [self createScrollView];
    [self.scrollView addSubview:self.spinner];
    [self.spinner startAnimating];
    
    [self downloadPostsAndCreateScrollViewContent];
    
    [self registerForKeyboardNotifications];
}

- (void)createScrollView {
    // create scrollview
    const float viewHeaderHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGPoint scrollViewPoint = CGPointMake(0, viewHeaderHeight+LABELSPACING/2);
    CGSize scrollViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-self.tabBarController.tabBar.frame.size.height-scrollViewPoint.y);
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
    [self.postTextInputView setBackgroundColor:[colorUtility textFieldColor]];
    self.postTextInputView.textColor = [colorUtility opaqueWhiteColor];
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
    self.submitPostButton.layer.cornerRadius = CORNERRADIUS;
    self.submitPostButton.clipsToBounds = YES;
    [self.submitPostButton setBackgroundColor:[colorUtility opaqueWhiteColor]];
    self.submitPostButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.submitPostButton setTitleColor:[colorUtility textColor] forState:UIControlStateNormal];
    [self.submitPostButton setTitle:@"Submit Post" forState:UIControlStateNormal];
    [self.submitPostButton setUserInteractionEnabled:YES];
    [self.submitPostButton addTarget:self action:@selector(submitPost:) forControlEvents: UIControlEventTouchUpInside];
    [[self.submitPostButton layer] setBorderWidth:2.0f];
    [[self.submitPostButton layer] setBorderColor:[colorUtility buttonColor].CGColor];

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

- (void)reloadPosts {
    [self downloadPostsAndRefreshScrollViewContent];
}

- (void)downloadPostsAndRefreshScrollViewContent {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"event" equalTo:self.eventTitle];
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
    [query whereKey:@"event" equalTo:self.eventTitle];
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
                [body setAttributes:@{NSForegroundColorAttributeName:[colorUtility textColor],
                                      NSUnderlineStyleAttributeName:[NSNumber numberWithInt:1],
                                      NSFontAttributeName:[UIFont fontWithName:@"Futura" size:14.0]}
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
            if([[PFUser currentUser].username isEqualToString:[[self.posts objectAtIndex:i] objectForKey:@"creator"]]){
                [userPostView setBackgroundColor:[colorUtility opaqueWhiteColor]];
                [[userPostView layer] setBorderWidth:2.0f];
                [[userPostView layer] setBorderColor:[colorUtility darkLabelColor].CGColor];
                
            } else {
                [userPostView setBackgroundColor:[colorUtility opaqueWhiteColor]];
                [[userPostView layer] setBorderWidth:2.0f];
                [[userPostView layer] setBorderColor:[colorUtility buttonColor].CGColor];
            }
            userPostView.attributedText = (NSAttributedString*)body;
            userPostView.layer.cornerRadius = CORNERRADIUS;
            [userPostView setUserInteractionEnabled:NO];
            [userPostView scrollRectToVisible:userPostViewRect animated:NO];
            [userPostView sizeToFit];
            [userPostView layoutIfNeeded];
            userPostView.frame = CGRectMake(0, 0, userPostViewSize.width, userPostView.frame.size.height);
            UILabel *dateLabel = [self insertPostDate:userPostView forDate:[self datePostWasCreated:[self.posts objectAtIndex:i]] withPostByCurrentUser:currentUsersPost];
            
            CGRect postFrame;
            if(currentUsersPost){
                postFrame = CGRectMake(dateLabel.frame.origin.x, userPostViewPoint.y, userPostView.frame.size.width+dateLabel.frame.size.width, userPostView.frame.size.height);
                userPostView.frame = CGRectMake(dateLabel.frame.size.width - SIDESPACING, 0, userPostViewSize.width, userPostView.frame.size.height);
            } else {
                postFrame = CGRectMake(userPostViewPoint.x, userPostViewPoint.y, userPostView.frame.size.width+dateLabel.frame.size.width, userPostView.frame.size.height);
                userPostView.frame = CGRectMake(0, 0, userPostViewSize.width, userPostView.frame.size.height);
                
            }
            UIView* totalView = [[UIView alloc] initWithFrame:postFrame];
            [totalView addSubview:userPostView];
            [totalView addSubview:dateLabel];
           
            [self.postFieldArray addObject:totalView];
        }
    }
}

- (UILabel*) insertPostDate:(UITextView*)postView forDate:(NSString*)date withPostByCurrentUser:(BOOL)currentUserPost {

    CGPoint postDatePoint;
    if(currentUserPost){
        postDatePoint = CGPointMake(0, postView.frame.size.height/2-LABELSPACING/2);
    } else {
        postDatePoint = CGPointMake(postView.frame.size.width-LABELSPACING, postView.frame.size.height/2-LABELSPACING/2);
    }
    CGSize postDateSize = CGSizeMake(self.scrollView.frame.size.width-postView.frame.size.width, 0);
    
    CGRect postDateRect = {postDatePoint, postDateSize};
    
    UILabel* postDateLabel = [[UILabel alloc] initWithFrame:postDateRect];
    postDateLabel.textColor = [UIColor whiteColor];
    postDateLabel.font = [UIFont fontWithName:@"Futura" size:8];
    postDateLabel.text = date;
    postDateLabel.textAlignment = NSTextAlignmentCenter;
    [postDateLabel sizeToFit];
    [postDateLabel layoutIfNeeded];
    
    postDateLabel.frame = CGRectMake(postDatePoint.x, postDatePoint.y, postDateSize.width, postDateLabel.frame.size.height);
    
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
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.activeField = nil;
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter a new posting...";
        textView.textColor = [colorUtility opaqueWhiteColor];
    }
    [textView resignFirstResponder];
}

- (IBAction)submitPost:(id)sender {
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    post[@"creator"] = [PFUser currentUser].username;
    post[@"event"] = self.eventTitle;
    post[@"content"] = [AttributedStringCoderHelper encodeAttributedString:[self.postTextInputView attributedText]];
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self reloadPosts];
        } else {
            // error
        }
    }];
}

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
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

@end
