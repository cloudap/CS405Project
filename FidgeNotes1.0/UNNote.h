//
//  Note.h
//  FidgeNotes1.0
//
//  Created by Alicia Pixton on 11/5/14.
//  Copyright (c) 2014 TheFridge. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SUBVIEW_TAG 9361 

@interface UNNote : UITextView

-(id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer withViewController:(id)controller;

@end
