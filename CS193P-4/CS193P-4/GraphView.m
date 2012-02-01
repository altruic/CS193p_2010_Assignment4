//
//  GraphView.m
//  CS193P-3
//
//  Created by Ed Sibbald on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"


@interface GraphView()
@property (readonly) CGPoint center;
@property (nonatomic) BOOL isCentered;
@end


@implementation GraphView

#pragma mark - User defaults keys

#define ORIGIN_X_KEY @"origin.x"
#define ORIGIN_Y_KEY @"origin.y"
#define IS_CENTERED_KEY @"isCentered"
#define SCALE_KEY @"scale"


#pragma mark - Properties

@synthesize delegate = delegate_;
@synthesize panGestureRecognizer = panGestureRecognizer_;
@synthesize pinchGestureRecognizer = pinchGestureRecognizer_;
@synthesize tapGestureRecognizer = tapGestureRecognizer_;

- (CGPoint)origin
{ return origin_; }

- (void)setOrigin:(CGPoint)newOrigin
{
	if (CGPointEqualToPoint(newOrigin, origin_))
		return;
	origin_ = newOrigin;
	self.isCentered = NO;
	[self setNeedsDisplay];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:origin_.x forKey:ORIGIN_X_KEY];
	[userDefaults setDouble:origin_.y forKey:ORIGIN_Y_KEY];
	[userDefaults synchronize];
}


@synthesize scale = scale_;
- (void)setScale:(double)newScale
{
	if (newScale == scale_)
		return;
	scale_ = newScale;
	[self setNeedsDisplay];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:scale_ forKey:SCALE_KEY];
	[userDefaults synchronize];
}


// assumes self.bounds.origin == (0, 0) even though it's not invariant
- (CGPoint)center
{
	CGRect bounds = self.bounds;
	return CGPointMake(CGRectGetMidX(bounds),
					   CGRectGetMidY(bounds));
}


@synthesize isCentered = isCentered_;
- (void)setIsCentered:(BOOL)newIsCentered
{
	isCentered_ = newIsCentered;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:isCentered_ forKey:IS_CENTERED_KEY];
	[userDefaults synchronize];
}


#pragma mark - Coordinate translation

// coordinate translation functions assume self.bounds.origin == (0, 0) even though it's not invariant

- (double)horizontalPixelForPoint:(double)pt
{ return pt * self.contentScaleFactor; }

- (double)horizontalPointForPixel:(double)px
{ return px / self.contentScaleFactor; }

- (double)xValueForHorizontalPixel:(double)px
{
//	double absPt = [self horizontalPointForPixel:px];
//	double ptWRTOrigin = absPt - (CGRectGetWidth(self.bounds) / 2.0);
//	return ptWRTOrigin / self.scale;

	double pt = [self horizontalPointForPixel:px];
	double ptWRTOrigin = -(self.origin.x - pt);
	double unit = ptWRTOrigin / self.scale;
	return unit;
}

- (double)verticalPixelForPoint:(double)pt
{ return pt * self.contentScaleFactor; }

- (double)verticalPointForPixel:(double)px
{ return px / self.contentScaleFactor; }

- (double)verticalPointForYValue:(double)y
{
	//-y = (absPt - (CGRectGetHeight(self.bounds) / 2.0)) / scale
	//-y * scale = absPt - (CGRectGetHeight(self.bounds) / 2.0)
	//(-y * scale) + (CGRectGetHeight(self.bounds) / 2.0) = absPt
	
//	double ptWRTOrigin = -y * self.scale;
//	return ptWRTOrigin + (CGRectGetHeight(self.bounds) / 2.0);
	
	double ptWRTOrigin = -y * self.scale;
	double pt = self.origin.y + ptWRTOrigin;
	return pt;
}


- (void)drawRect:(CGRect)rect
{
	[[UIColor blueColor] set];
    [AxesDrawer drawAxesInRect:self.bounds
				 originAtPoint:self.origin
						 scale:self.scale];

	int minXPixel = [self horizontalPixelForPoint:self.bounds.origin.x];
	int maxXPixel = [self horizontalPixelForPoint:
					 self.bounds.origin.x + CGRectGetWidth(self.bounds)];

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextBeginPath(context);
	double x = [self xValueForHorizontalPixel:minXPixel];
	double y = [self.delegate yGivenX:x forGraphView:self];
	double vertPt = [self verticalPointForYValue:y];
	CGContextMoveToPoint(context,
						 [self horizontalPointForPixel:minXPixel],
						 vertPt);
	++minXPixel;
	for (int px = minXPixel; px < maxXPixel; ++px) {
		//double horzPt = [self horizontalPointForPixel:px];
		double horzPt = px / self.contentScaleFactor;

		//double x = [self xValueForHorizontalPixel:px];
		double horzPtWRTOrigin = -(self.origin.x - horzPt);
		double x = horzPtWRTOrigin / self.scale;

		double y = [self.delegate yGivenX:x forGraphView:self];

		//double vertPt = [self verticalPointForYValue:y];
		double vertPtWRTOrigin = -y * self.scale;
		double vertPt = self.origin.y + vertPtWRTOrigin;

		CGContextAddLineToPoint(context, horzPt, vertPt);
	}

	[[UIColor redColor] set];
	CGContextDrawPath(context, kCGPathStroke);
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	if (self.isCentered)
		[self recenter];
}


#pragma mark - Gesture actions

- (void)pan:(UIPanGestureRecognizer *)panGR
{
	if (panGR.state == UIGestureRecognizerStateChanged
		|| panGR.state == UIGestureRecognizerStateEnded) {
		CGPoint origin = self.origin;
		CGPoint translation = [panGR translationInView:self];
		origin.x += translation.x;
		origin.y += translation.y;
		self.origin = origin;
		[panGR setTranslation:CGPointMake(0, 0) inView:self];
	}
}


- (void)pinch:(UIPinchGestureRecognizer *)pinchGR
{
	if (pinchGR.state == UIGestureRecognizerStateChanged
		|| pinchGR.state == UIGestureRecognizerStateEnded) {
		self.scale *= pinchGR.scale;
		pinchGR.scale = 1;
	}
}



#pragma mark - Public operations

- (void)recenter
{
	self.origin = self.center;
	self.isCentered = YES;
}


- (void)retrieveOriginFromDefaults
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey:IS_CENTERED_KEY]) {
		[self recenter];
		return;
	}
	
	CGPoint savedOrigin = CGPointMake(0, 0);
	savedOrigin.x = [userDefaults doubleForKey:ORIGIN_X_KEY];
	savedOrigin.y = [userDefaults doubleForKey:ORIGIN_Y_KEY];
	if (!CGPointEqualToPoint(savedOrigin, CGPointMake(0, 0)))
		self.origin = savedOrigin;
}


- (void)retrieveScaleFromDefaults
{
	double newScale = [[NSUserDefaults standardUserDefaults] doubleForKey:SCALE_KEY];
	if (newScale > 0)
		self.scale = newScale;
}


#pragma mark - View lifecycle

- (void)setup
{
	// don't set these through properties because we don't want to save over previous user defaults during setup
	origin_ = self.center;
	isCentered_ = YES;
	scale_ = 20;
	
	panGestureRecognizer_ = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	pinchGestureRecognizer_ = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
	tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recenter)];
	tapGestureRecognizer_.numberOfTapsRequired = 2; 

	self.backgroundColor = [UIColor whiteColor];
	
	self.contentMode = UIViewContentModeRedraw;
}


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setup];
	}
	return self;
}


- (void)awakeFromNib
{
	[self awakeFromNib];
	[self setup];
}


@end
