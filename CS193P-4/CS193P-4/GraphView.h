//
//  GraphView.h
//  CS193P-3
//
//  Created by Ed Sibbald on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDelegate
- (double)yGivenX:(double)xValue forGraphView:(GraphView *)requestor;
@end


@interface GraphView : UIView {
	id <GraphViewDelegate> delegate_;
	CGPoint origin_;
	BOOL isCentered_;
	double scale_;
	UIPanGestureRecognizer* panGestureRecognizer_;
	UIPinchGestureRecognizer* pinchGestureRecognizer_;
	UITapGestureRecognizer* tapGestureRecognizer_;
}
@property (assign) id <GraphViewDelegate> delegate;
@property (nonatomic) CGPoint origin;
@property (nonatomic) double scale;
@property (readonly) UIPanGestureRecognizer* panGestureRecognizer;
@property (readonly) UIPinchGestureRecognizer* pinchGestureRecognizer;
@property (readonly) UITapGestureRecognizer* tapGestureRecognizer;

- (void)recenter;
- (void)retrieveOriginFromDefaults;
- (void)retrieveScaleFromDefaults;

@end
