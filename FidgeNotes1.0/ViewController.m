//
//  ViewController.m
//  FidgeNotes1.0
//
//  Created by Alicia Pixton on 10/10/14.
//  Copyright (c) 2014 TheFridge. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property NSMutableArray* noteTextViews;

-(void)didRecieveEditingNotification:(NSNotification*)notification;

@property NSString* tablename;

@end

@implementation ViewController

NSString *hostname = @"http://unotey.com";
bool editing = false;
NSMutableData *receivedData;
NSURLConnection *getConnection;
NSURLConnection *postConnection;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.noteTextViews = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveEditingNotification:) name:@"UITextViewTextDidBeginEditingNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveEditingNotification:) name:@"UITextViewTextDidEndEditingNotification" object:nil];
	self.tablename = @"Alicia's Notes";
	[self getNotesFromServer];
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
	}
	
	UNNote* noteTextView = [[UNNote alloc] initWithFrame:CGRectMake(touchPoint.x-10.0, touchPoint.y-10.0, 100, 100) textContainer:nil withViewController:self];
	noteTextView.backgroundColor = [UIColor yellowColor];
	[self.noteTextViews addObject:noteTextView];
	
	[self.view addSubview:noteTextView];
}

-(void)didRecieveEditingNotification:(NSNotification*)notification {
	if ([notification.name isEqualToString:@"UITextViewTextDidBeginEditingNotification"]) {
		NSLog(@"did begin editing");
		editing = true;
	} else {
		NSLog(@"did end editing");
		editing = false;
		[self postNotesToServer];
	}
}

- (void)getNotesFromServer {
//	NSString *request = [hostname stringByAppendingString:self.tablename];
//	
//	NSURLRequest *getRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:request] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//	receivedData = [NSMutableData dataWithCapacity:0];
//	
//	getConnection = [[NSURLConnection alloc] initWithRequest:getRequest delegate:self];
//	if(!getConnection) {
//		receivedData = nil;
//		NSLog(@"The connection to the server failed");
//	}
	[self connectionDidFinishLoading:postConnection];
}

- (void)postNotesToServer {
	NSString *request = [hostname stringByAppendingString:self.tablename];
	
	//get the note information into a string to POST
	NSMutableString *bodyData = [NSMutableString stringWithString:@"{"];
	for(UNNote *note in self.noteTextViews) {
		[bodyData appendString:[NSString stringWithFormat:@"(%f,%f,%@),", note.center.x, note.center.y, note.text]];
	}
	NSLog(@"POSTing %@", bodyData);
	NSData *bodyDataAsData = [bodyData dataUsingEncoding:NSASCIIStringEncoding];
	receivedData = [[NSMutableData alloc] initWithData:bodyDataAsData];
	
//	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request]];
//	[postRequest setValue:@"application/x-www-form-urlendcoded" forHTTPHeaderField:@"Content-Type"];
//	[postRequest setHTTPMethod:@"POST"];
//	[postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
//	
//		receivedData = [NSMutableData dataWithCapacity:0];
//	
//	getConnection = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
//	if(!getConnection) {
//		receivedData = nil;
//		NSLog(@"The connection to the server failed");
//	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	receivedData = nil;
	NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if(receivedData == nil) { 
		return; 
	}
	
	NSLog(@"recieved data - %@", [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]);
	self.noteTextViews = nil;
	
	NSString *stringReturned = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
	NSString *prefix = @"{(";
	NSString *suffix = @")}"; 
	NSRange dataRange = NSMakeRange(prefix.length, stringReturned.length - prefix.length - suffix.length);
	NSString *notesData = [stringReturned substringWithRange:dataRange];
	NSArray *notesArray = [notesData componentsSeparatedByString:@"),("];
	for(NSString *noteString in notesArray) {
		NSArray *noteArray = [noteString componentsSeparatedByString:@","];
		CGFloat x = [[noteArray objectAtIndex:0] floatValue];
		CGFloat y = [[noteArray objectAtIndex:1] floatValue];
		NSString *text = [noteArray objectAtIndex:2];
		
		UNNote* noteTextView = [[UNNote alloc] initWithFrame:CGRectMake(x-10.0, y-10.0, 100, 100) textContainer:nil  withViewController:self];
		noteTextView.text = text;
		noteTextView.backgroundColor = [UIColor yellowColor];
		[self.noteTextViews addObject:noteTextView];
	}
	
	receivedData = nil;
}





@end
