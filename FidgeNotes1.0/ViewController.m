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
@property NSMutableArray* notesOnServer;

-(void)didRecieveEditingNotification:(NSNotification*)notification;
-(void)createTable;

- (void)getNotesFromServer;
- (void)postNoteToServer:(int)noteId;
- (void)deleteNoteFromServer:(UNNote *)note;

@property NSString* tablename;
@property int boardId;

@end

@implementation ViewController

NSString *hostname = @"http://unotey.com/";
bool editing = false;
NSMutableData *receivedData;
NSURLConnection *getConnection;
NSURLConnection *postConnection;
NSURLConnection *deleteConnection;
UNNote *noteBeingPosted;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.noteTextViews = [[NSMutableArray alloc] init];
	self.notesOnServer = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveEditingNotification:) name:@"UITextViewTextDidBeginEditingNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveEditingNotification:) name:@"UITextViewTextDidEndEditingNotification" object:nil];
	self.tablename = @"My%20Notes";
	self.boardId = 9;
	//[self createTable];
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
		NSLog(@"%lu", (unsigned long)[self.noteTextViews count]);
		for(UNNote *note in self.noteTextViews) {
			[note endEditing:YES];
		}
		return;
	}
	
	UNNote* noteTextView = [[UNNote alloc] initWithFrame:CGRectMake(touchPoint.x-10.0, touchPoint.y-10.0, 100, 100) textContainer:nil withViewController:self];
	[self.noteTextViews addObject:noteTextView];
	
	[self postNoteToServer:[self.noteTextViews indexOfObject:noteTextView]];
}

-(void)didRecieveEditingNotification:(NSNotification*)notification {
	if ([notification.name isEqualToString:@"UITextViewTextDidBeginEditingNotification"]) {
		NSLog(@"did begin editing");
		editing = true;
	} else {
		NSLog(@"did end editing");
		editing = false;
		[self postNoteToServer:[self.noteTextViews indexOfObject:notification.object]];
	}
}

- (void)removeNote:(UNNote *)note {
	NSLog(@"removing note");
	[self.noteTextViews removeObject:note];
}

- (void)getNotesFromServer {
	NSString *request = [NSString stringWithFormat:@"%@api/boards/%d/notes/",hostname,self.boardId];
	NSLog(@"request = %@",request);
	
	NSURLRequest *getRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:request] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	receivedData = [NSMutableData dataWithCapacity:0];
	
	getConnection = [[NSURLConnection alloc] initWithRequest:getRequest delegate:self];
	if(!getConnection) {
		receivedData = nil;
		NSLog(@"The connection to the server failed");
	}
	//[self connectionDidFinishLoading:postConnection];
}

- (void)postNoteToServer:(int)noteId {
	UNNote *note = [self.noteTextViews objectAtIndex:noteId];
	noteBeingPosted = note;
	NSString *request;
	if([self.notesOnServer containsObject:noteBeingPosted]) {
		request = [NSString stringWithFormat:@"%@api/boards/%d/notes/%d",hostname,self.boardId,noteId+1];
	} else {
		request = [NSString stringWithFormat:@"%@api/boards/%d/notes/",hostname,self.boardId];
	}
	
	NSLog(@"request = %@",request);
	
	//get the note information into a string to POST

	//[bodyData appendString:[NSString stringWithFormat:@"(%f,%f,%@),", note.center.x, note.center.y, note.text]];
	NSString *bodyData = [NSString stringWithFormat:@"{\"notes\":[{\"id\":\"%d\", \"x_pos\":\"%d\", \"y_pos\":\"%d\",\"text\":\"%@\"}]}", noteId+1, (int)note.center.x, (int)note.center.y, note.text];
	NSData *bodyDataAsData = [bodyData dataUsingEncoding:NSASCIIStringEncoding];
	receivedData = [[NSMutableData alloc] initWithData:bodyDataAsData];
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request]];
	//[postRequest setValue:@"application/x-www-form-urlendcoded" forHTTPHeaderField:@"Content-Type"];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
	
	receivedData = [NSMutableData dataWithCapacity:0];
	
	NSLog(@"Request headers = %@", [postRequest allHTTPHeaderFields]);
	NSLog(@"Request body = %@", [[NSString alloc] initWithData:[postRequest HTTPBody] encoding:NSUTF8StringEncoding]);
	postConnection = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
	if(!postConnection) {
		receivedData = nil;
		NSLog(@"The connection to the server failed");
	}
}

- (void)deleteNoteFromServer:(UNNote *)note {
	int noteId = [self.noteTextViews indexOfObject:note];
	noteBeingPosted = note;
	NSString *request = [NSString stringWithFormat:@"%@api/boards/%d/notes/%d",hostname,self.boardId,noteId+1];
	
	NSLog(@"request = %@",request);
	
	NSMutableURLRequest *deleteRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request]];
	//[postRequest setValue:@"application/x-www-form-urlendcoded" forHTTPHeaderField:@"Content-Type"];
	[deleteRequest setHTTPMethod:@"DELETE"];
	
	receivedData = [NSMutableData dataWithCapacity:0];

	deleteConnection = [[NSURLConnection alloc] initWithRequest:deleteRequest delegate:self];
	if(!deleteConnection) {
		receivedData = nil;
		NSLog(@"The connection to the server failed");
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
	NSLog(@"reponse code = %ld with headerfields = %@", (long)[r statusCode],[r allHeaderFields]);


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
	} else if(connection == getConnection) {
	
		NSLog(@"recieved data - %@", [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]);
		
		//{"notes":[{"id":"10","x_pos":"122","y_pos":"211","text":""}]}
	
		NSString *stringReturned = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
		if([stringReturned length] == 0) {
			receivedData = nil;
			return;
		}
		
		NSString *prefix = @"{\"notes\":[";
		NSString *suffix = @"]}"; 
		NSRange dataRange = NSMakeRange(prefix.length, stringReturned.length - prefix.length - suffix.length);
		NSString *notesData = [stringReturned substringWithRange:dataRange];
		
		NSArray *noteArray = [notesData componentsSeparatedByString:@"\""];
		[self.noteTextViews removeAllObjects];
		[self.noteTextViews removeAllObjects];
		NSLog(@"notesArray = %@", [noteArray componentsJoinedByString:@"*"]);
		if([noteArray count] >= 15) {
			// id = 3, x = 7, y = 11, text = 15
			//for(NSString *noteString in notesArray) {
				//NSArray *noteArray = [noteString componentsSeparatedByString:@","];
				//int noteID = [[noteArray objectAtIndex:3] integerValue];
				CGFloat x = [[noteArray objectAtIndex:7] floatValue];
				CGFloat y = [[noteArray objectAtIndex:11] floatValue];
				NSString *text = @"";
				if([noteArray count] > 15) {
					text = [noteArray objectAtIndex:15];
				}
				
				UNNote* noteTextView = [[UNNote alloc] initWithFrame:CGRectMake(x-10.0, y-10.0, 100, 100) textContainer:nil  withViewController:self];
				noteTextView.text = text;
				
				[self.noteTextViews addObject:noteTextView];
				[self.notesOnServer addObject:noteTextView];
			//}
		}
	} else if(connection == postConnection) {
		NSLog(@"recieved data - %@", [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]);
		if(![self.notesOnServer containsObject:noteBeingPosted]) {
			[self.notesOnServer addObject:noteBeingPosted];
		}
	} else if(connection == deleteConnection) {
		NSLog(@"recieved data - %@", [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]);
	}
	
	receivedData = nil;
}

-(void)createTable {
	NSString *request = @"http://unotey.com/api/boards/";
	
	//get the note information into a string to POST
	NSString *bodyData = @"{\"boards\":[{\"id\":\"9\", \"name\":\"My Notes\"}]}";
	NSLog(@"POSTing %@", bodyData);
	NSData *bodyDataAsData = [bodyData dataUsingEncoding:NSASCIIStringEncoding];
	receivedData = [[NSMutableData alloc] initWithData:bodyDataAsData];
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request]];
	[postRequest setValue:@"application/x-www-form-urlendcoded" forHTTPHeaderField:@"Content-Type"];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
	
	receivedData = [NSMutableData dataWithCapacity:0];
	
	NSLog(@"Request body %@", [[NSString alloc] initWithData:[postRequest HTTPBody] encoding:NSUTF8StringEncoding]);
	postConnection = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
	if(!postConnection) {
		receivedData = nil;
		NSLog(@"The connection to the server failed");
	}
}



@end
