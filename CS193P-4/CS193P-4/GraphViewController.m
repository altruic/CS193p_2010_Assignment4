//
//  GraphViewController.m
//  CS193P-3
//
//  Created by Ed Sibbald on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController()
@property (retain) GraphView *graphView;
@end

@implementation GraphViewController
@synthesize graphView;

- (id)expression
{
	return expression;
}


- (void)setExpression:(id)anExpression
{
	if (anExpression != expression) {
		[expression release];
		expression = anExpression;
		[expression retain];
		[self.graphView setNeedsDisplay];
	}
}


- (double)yGivenX:(double)xValue forGraphView:(GraphView *)requestor
{
	double yValue = 0.0;
	if (requestor == graphView) {
		NSNumber *xNumber = [NSNumber numberWithDouble:xValue];
		NSDictionary *varDict = [NSDictionary dictionaryWithObject:xNumber
															forKey:@"x"];
		id exp = self.expression;
		yValue = [CalculatorBrain evaluateExpression:exp
								 usingVariableValues:varDict];
	}
	return yValue;
}

#pragma mark - Split View delegate methods

- (void)splitViewController:(UISplitViewController *)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem
	   forPopoverController:(UIPopoverController *)pc
{
	barButtonItem.title = aViewController.title;
	self.navigationItem.leftBarButtonItem = barButtonItem;
}


- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)button
{
	self.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - View lifecycle

- (void)loadView
{
	[super loadView];

	self.graphView = [[GraphView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[self.graphView retrieveOriginFromDefaults];
	[self.graphView retrieveScaleFromDefaults];
	
	[self.graphView addGestureRecognizer:self.graphView.panGestureRecognizer];
	[self.graphView addGestureRecognizer:self.graphView.pinchGestureRecognizer];
	[self.graphView addGestureRecognizer:self.graphView.tapGestureRecognizer];

	self.view = self.graphView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.graphView.delegate = self;
	self.title = @"Graph";
}


- (void)viewDidUnload
{
    [super viewDidUnload];
	self.graphView = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return self.splitViewController != nil || UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


- (void)dealloc
{
	[expression release];
	[graphView release];
	[super dealloc];
}

@end
