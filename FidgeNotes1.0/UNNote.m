//
//  Note.m
//  FidgeNotes1.0
//
//  Created by Alicia Pixton on 11/5/14.
//  Copyright (c) 2014 TheFridge. All rights reserved.
//

#import "UNNote.h"

@interface UNNote ()

-(void)handleExit;

@end


@implementation UNNote

-(id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {

	if([super initWithFrame:frame textContainer:textContainer]) {
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[cancelButton addTarget:self action:@selector(handleExit) forControlEvents:UIControlEventTouchUpInside];
		[cancelButton setFrame:CGRectMake(0, 0, 10, 10)];
		[cancelButton setTitle:@"x" forState:UIControlStateNormal];

		[self addSubview:cancelButton];
		[self setTag:SUBVIEW_TAG];
	}
	
	return self;
	
}

- (void) handleExit {
    UIView * subview = [self viewWithTag:SUBVIEW_TAG];
    [subview removeFromSuperview];
}

@end
