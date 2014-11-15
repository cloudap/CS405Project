//
//  ViewController.m
//  FidgeNotes1.0
//
//  Created by Alicia Pixton on 10/10/14.
//  Copyright (c) 2014 TheFridge. All rights reserved.
//

#import "ViewController.h"
#import "UNNote.h"

@interface ViewController ()

@property NSMutableArray* noteTextViews;

-(void)didRecieveEditingNotification:(NSNotification*)notification;

@end

@implementation ViewController

bool editing = false;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.noteTextViews = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveEditingNotification:) name:@"UITextViewTextDidBeginEditingNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveEditingNotification:) name:@"UITextViewTextDidEndEditingNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)didReceiveTap:(UITapGestureRecognizer *)recognizer {
	NSLog(@"touch received");
	
	CGPoint touchPoint = [recognizer locationInView:self.view];
	NSLog(@"%@", NSStringFromCGPoint(touchPoint));
	
	if(editing) {
		for(UNNote *note in self.noteTextViews) {
			[note endEditing:YES];
		}
		return;
	}
	
	UNNote* noteTextView = [[UNNote alloc] initWithFrame:CGRectMake(touchPoint.x-10.0, touchPoint.y-10.0, 100, 100) textContainer:nil];
	noteTextView.backgroundColor = [UIColor yellowColor];
	[self.noteTextViews addObject:noteTextView];
	
	[self.view addSubview:noteTextView];
}

-(void)didRecieveEditingNotification:(NSNotification*)notification {
	if ([notification.name isEqualToString:@"UITextViewTextDidBeginEditingNotification"]) {
		NSLog(@"did begin editing");
		editing = true;
	} else {
		NSLog(@"did end begin editing");
		editing = false;
	}
		
}

@end
