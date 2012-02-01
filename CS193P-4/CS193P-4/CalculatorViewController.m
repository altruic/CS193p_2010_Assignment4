//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Ed Sibbald on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#include <stdlib.h>


@implementation CalculatorViewController


#pragma mark - Properties

@synthesize expressionRecvVC = expressionRecvVC_;

@synthesize display = display_;

- (CGSize)contentSizeForViewInPopover
{
	NSArray *subviews = self.view.subviews;
	if ([subviews count] == 0)
		return self.view.frame.size;
	
	CGRect subviewsRect = ((UIView *)[subviews objectAtIndex:0]).frame;
	for (UIView *subview in subviews)
		subviewsRect = CGRectUnion(subviewsRect, subview.frame);
	CGSize contentSizeWithMargins = subviewsRect.size;
	contentSizeWithMargins.width += subviewsRect.origin.x * 2;
	contentSizeWithMargins.height += subviewsRect.origin.y * 2;
	return contentSizeWithMargins;
}


#pragma mark - Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	brain = [[CalculatorBrain alloc] init];
	self.title = @"Calculator";
}


- (IBAction)digitPressed:(UIButton *)sender
{
	NSString* digit = sender.titleLabel.text;
	
	if (userIsTypingANumber)
		self.display.text = [self.display.text stringByAppendingString:digit];
	else {
		self.display.text = digit;
		userIsTypingANumber = YES;
	}
}


- (IBAction)operationPressed:(UIButton *)sender
{
	if (userIsTypingANumber) {
		brain.operand = [self.display.text doubleValue];
		userIsTypingANumber = NO;
	}
	NSString *operation = sender.titleLabel.text;
	double result = [brain performOperation:operation];
	id expression = brain.expression;
	if ([CalculatorBrain variablesInExpression:expression])
		self.display.text = [CalculatorBrain descriptionOfExpression:expression];
	else
		self.display.text = [NSString stringWithFormat:@"%g", result];
}


- (IBAction)variablePressed:(UIButton *)sender
{
	// it doesn't make any sense to type a variable right after a number, but our brain should handle it gracefully.
	if (userIsTypingANumber) {
		brain.operand = [self.display.text doubleValue];
		userIsTypingANumber = NO;
	}
	[brain setVariableAsOperand:sender.titleLabel.text];
	self.display.text = [CalculatorBrain descriptionOfExpression:brain.expression];
}


- (IBAction)decimalPointPressed
{
	if (userIsTypingANumber) {
		NSRange range = [self.display.text rangeOfString:@"."];
		if (range.location == NSNotFound)
			self.display.text = [self.display.text stringByAppendingString:@"."];
	}
	else {
		self.display.text = @"0.";
		userIsTypingANumber = YES;
	}
}


- (void)graphPressedImpl
{
	self.expressionRecvVC.expression = brain.expression;
	if (!self.expressionRecvVC.view.window)
		[self.navigationController pushViewController:self.expressionRecvVC animated:YES];
}


- (IBAction)graphPressed
{
	if (!userIsTypingANumber) {
		[self graphPressedImpl];
		return;
	}

	NSString *msgText = [NSString stringWithFormat:@"Would you like to include the current operand (%@)?", self.display.text];
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Use Operand?"
														 message:msgText
														delegate:self
											   cancelButtonTitle:@"Ignore"
											   otherButtonTitles:@"Include", nil]
								autorelease];
	[alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex) {
		brain.operand = [self.display.text doubleValue];
		userIsTypingANumber = NO;
	}
	[self graphPressedImpl];
}


- (void)releaseOutlets
{
	self.display = nil;
}


- (void)viewDidUnload
{
	[self viewDidUnload];
	[self releaseOutlets];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return self.splitViewController != nil || UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


- (void)dealloc
{
	[expressionRecvVC_ release];
	[brain release];
	[self releaseOutlets];
	[super dealloc];
}


@end
