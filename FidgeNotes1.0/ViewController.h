//
//  ViewController.h
//  FidgeNotes1.0
//
//  Created by Alicia Pixton on 10/10/14.
//  Copyright (c) 2014 TheFridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UNNote.h"

@interface ViewController : UIViewController<NSURLConnectionDelegate>

- (IBAction)didReceiveTap:(UITapGestureRecognizer *)recognizer;

- (void)getNotesFromServer;
- (void)postNotesToServer;

- (void)removeNote:(UNNote *)note;

@end

