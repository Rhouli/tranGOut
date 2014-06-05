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

@interface EventPostsViewController () <UITextViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *postTextInputView;
@property (strong, nonatomic) UIButton *submitPostButton;
@property (strong, nonatomic) NSMutableArray *postFieldArray;
@end

@implementation EventPostsViewController 

- (void)viewDidLoad {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapRecognizer];
    
    self.navigationItem.title = @"Event Discussion";
    [self.view setBackgroundColor:[colorUtility backgroundColor]];
    
    self.postFieldArray = [[NSMutableArray alloc] init];
    
    [self createScrollView];
    [self downloadPosts];
}

- (void)createScrollView {
    // create scrollview
    CGPoint scrollViewPoint = CGPointMake(0, LABELSPACING/2);
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
        postTextInputViewPoint = CGPointMake(lastView.frame.origin.x, lastView.frame.origin.y+lastView.frame.size.height+LABELSPACING);
        postTextInputViewSize = CGSizeMake(maxLabelWidth, maxLabelWidth/4.0);
    } else {
        postTextInputViewPoint = CGPointMake(self.scrollView.frame.origin.x+LABELSPACING, self.scrollView.frame.origin.y+LABELSPACING);
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
    //[self.postTextInputView becomeFirstResponder];

    // end time input label
    CGPoint submitPostButtonPoint = CGPointMake(LABELSPACING + maxLabelWidth/4, postTextInputViewPoint.y+postTextInputViewSize.height+LABELSPACING);
    CGSize submitPostButtonSize = CGSizeMake(maxLabelWidth/2.0, standardLabelHeight);
    CGRect submitPostButtonRect = {submitPostButtonPoint, submitPostButtonSize};
    
    self.submitPostButton = [[UIButton alloc] initWithFrame:submitPostButtonRect];
    self.submitPostButton.layer.cornerRadius = CORNERRADIUS;
    self.submitPostButton.clipsToBounds = YES;
    [self.submitPostButton setBackgroundColor:[colorUtility backgroundColor]];
    self.submitPostButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.submitPostButton setTitleColor:[colorUtility textColor] forState:UIControlStateNormal];
    [self.submitPostButton setTitle:@"Submit Post" forState:UIControlStateNormal];
    [self.submitPostButton setUserInteractionEnabled:YES];
    [self.submitPostButton addTarget:self action:@selector(submitPost:) forControlEvents: UIControlEventTouchUpInside];
    [[self.submitPostButton layer] setBorderWidth:2.0f];
    [[self.submitPostButton layer] setBorderColor:[colorUtility buttonColor].CGColor];

    [self.scrollView addSubview:self.postTextInputView];
    [self.scrollView addSubview:self.submitPostButton];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, submitPostButtonPoint.y+submitPostButtonSize.height+LABELSPACING*3);
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)reloadPosts {
    [self downloadPosts];
    [self createScrollView];
}

- (void)downloadPosts {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"event" equalTo:self.eventTitle];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects) {
            NSLog(@"The getFirstObject request failed.");
        } else {
            // The find succeeded.
            NSLog(@"Successfully retrieved the object.");
            [self buildPostsArray:objects];
            [self reloadScrollView];
        }
    }];
}

- (void)buildPostsArray:(NSArray*)posts {
    const float maxLabelWidth = (1-2*INPUTBOXWIDTHOFFSETPERCENT)*self.view.frame.size.width;
    if(posts){
        for(int i = 0; i < [posts count]; i++){
            if (i == 0){
                // add event info
                NSMutableAttributedString* body = [[NSMutableAttributedString alloc] initWithString:[[posts objectAtIndex:i] objectForKey:@"creator"]];
                NSAttributedString* content = [AttributedStringCoderHelper decodeAttributedStringFromData:[[posts objectAtIndex:i] objectForKey:@"content"]];
                [body appendAttributedString:content];
                
                CGFloat width = maxLabelWidth*0.6;
                CGRect textRect = [body boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                
                CGPoint userPostViewPoint = CGPointMake(LABELSPACING, self.scrollView.frame.origin.y);
                CGSize userPostViewSize = CGSizeMake(maxLabelWidth, maxLabelWidth/3);
                //CGSizeMake(textRect.size.width, textRect.size.height);
                CGRect userPostViewRect = {userPostViewPoint, userPostViewSize};
                
                UITextView *userPostView = [[UITextView alloc] initWithFrame:userPostViewRect];
                [userPostView setBackgroundColor:[colorUtility opaqueLabelColor]];
                userPostView.attributedText = (NSAttributedString*)body;
                userPostView.layer.cornerRadius = CORNERRADIUS;
                [userPostView setUserInteractionEnabled:NO];
                [userPostView scrollRectToVisible:userPostViewRect animated:NO];
                [self.postFieldArray addObject:userPostView];
            } else {
                // add event info
                NSMutableAttributedString* body = [[NSMutableAttributedString alloc] initWithString:[[posts objectAtIndex:i] objectForKey:@"creator"]];
                NSAttributedString* content = [AttributedStringCoderHelper decodeAttributedStringFromData:[[posts objectAtIndex:i] objectForKey:@"content"]];
                [body appendAttributedString:content];
                
                CGFloat width = maxLabelWidth*0.6;
                CGRect textRect = [body boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                UITextView *lastView = [self.postFieldArray lastObject];
                CGPoint userPostViewPoint = CGPointMake(LABELSPACING, lastView.frame.origin.y+lastView.frame.size.height+LABELSPACING);
                CGSize userPostViewSize = CGSizeMake(maxLabelWidth, maxLabelWidth/3);//CGSizeMake(textRect.size.width, textRect.size.height+LABELSPACING);
                CGRect userPostViewRect = {userPostViewPoint, userPostViewSize};
                
                UITextView *userPostView = [[UITextView alloc] initWithFrame:userPostViewRect];
                [userPostView setBackgroundColor:[colorUtility opaqueLabelColor]];
                userPostView.attributedText = (NSAttributedString*)body;
                userPostView.layer.cornerRadius = CORNERRADIUS;
                [userPostView setUserInteractionEnabled:NO];
                [userPostView scrollRectToVisible:userPostViewRect animated:NO];
                [self.postFieldArray addObject:userPostView];
            }
        }
    }
    [self createScrollViewContents];
}

- (void)reloadScrollView {
    
}

#pragma mark Text View and Field Delegates

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Enter information about event..."]) {
        textView.text = @"";
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter information about event...";
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

@end
