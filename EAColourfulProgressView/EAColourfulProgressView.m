//
//  EAColourfulProgressView.m
//  EAColourfulProgressViewExample
//
//  Created by Eddpt on 25/10/2014.
//  Copyright (c) 2014 xpto. All rights reserved.
//

#import "EAColourfulProgressView.h"

typedef NS_ENUM(NSInteger, EAColourfulProgressViewType) {
  EAColourfulProgressViewType0to33 = 33,
  EAColourfulProgressViewType33to66 = 66,
  EAColourfulProgressViewType66to100 = 100
};

static NSUInteger const EAColourfulProgressViewLabelTopMargin = 5;
static NSUInteger const EAColourfulProgressViewNumberOfSegments = 3;

@interface EAColourfulProgressView ()
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *fillingView;
@property (nonatomic, strong) UILabel *initialLabel;
@property (nonatomic, strong) UILabel *finalLabel;
@end

@implementation EAColourfulProgressView


#pragma mark - Lifecycle

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  [self setupBackgroundView];
  [self setupFillingView];
  [self setupInitialLabel];
  [self setupFinalLabel];
}

#pragma mark - Setup Methods

- (void)setupBackgroundView
{
  CGFloat height = ceilf((self.showLabels ? 0.65f : 1.0f) * self.bounds.size.height);
  self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, height)];
  self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
  self.backgroundView.backgroundColor = self.containerColor;
  
  [self addSubview:self.backgroundView];
  
  [self addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[_backgroundView(%@)]->=0-|", @(height)]
                        options:0 metrics:nil
                        views:NSDictionaryOfVariableBindings(_backgroundView)]];
  [self addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"H:|-0-[_backgroundView]-0-|"
                        options:0 metrics:nil
                        views:NSDictionaryOfVariableBindings(_backgroundView)]];
  
  self.backgroundView.layer.cornerRadius = self.cornerRadius;
  self.backgroundView.layer.masksToBounds = YES;
}

- (void)setupFillingView
{
  CGFloat borders = 2 * self.borderLineWidth;
  CGFloat width = ceilf((self.backgroundView.bounds.size.width - borders) * self.fractionLeft);
  CGFloat height = (self.backgroundView.bounds.size.height - borders);
  
  self.fillingView = [[UIView alloc] initWithFrame:CGRectMake(self.borderLineWidth, self.borderLineWidth,
                                                              width, height)];
  self.fillingView.translatesAutoresizingMaskIntoConstraints = NO;
  self.fillingView.backgroundColor = self.fillingColor;
  
  [self.backgroundView addSubview:self.fillingView];
  
  NSString *borderString = @(self.borderLineWidth).stringValue;
  
  [self.backgroundView addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%@-[_fillingView(%@)]->=%@-|", borderString, @(height), borderString]
                        options:0 metrics:nil
                        views:NSDictionaryOfVariableBindings(_fillingView)]];
  [self.backgroundView addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%@-[_fillingView(%@)]->=%@-|", borderString, @(width), borderString]
                        options:0 metrics:nil
                        views:NSDictionaryOfVariableBindings(_fillingView)]];
  
  self.fillingView.layer.cornerRadius = (width > self.cornerRadius) ? self.cornerRadius : 0;
  self.fillingView.layer.masksToBounds = YES;
}

- (void)setupInitialLabel
{
  if (!self.showLabels) {
    return;
  }
  
  self.initialLabel = [[UILabel alloc] init];
  self.initialLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.initialLabel.text = @"0";
  self.initialLabel.textColor = self.labelColor;
  self.initialLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
  self.initialLabel.textAlignment = NSTextAlignmentLeft;
  [self addSubview:self.initialLabel];
  [self addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[_backgroundView]-%@-[_initialLabel]|", @(EAColourfulProgressViewLabelTopMargin)]
                        options:0 metrics:nil
                        views:NSDictionaryOfVariableBindings(_backgroundView, _initialLabel)]];
  [self addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"H:|-0-[_initialLabel]->=0-|"
                        options:0 metrics:nil
                        views:NSDictionaryOfVariableBindings(_initialLabel)]];
}

- (void)setupFinalLabel
{
  if (!self.showLabels) {
    return;
  }
  
  self.finalLabel = [[UILabel alloc] init];
  self.finalLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.finalLabel.text = [NSString stringWithFormat:@"%zd", self.maximumValue];
  self.finalLabel.textColor = self.labelColor;
  self.finalLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
  self.finalLabel.textAlignment = NSTextAlignmentRight;
  [self addSubview:self.finalLabel];
  [self addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[_backgroundView]-%@-[_finalLabel]|", @(EAColourfulProgressViewLabelTopMargin)]
                        options:0
                        metrics:nil
                        views:NSDictionaryOfVariableBindings(_backgroundView, _finalLabel)]];
  [self addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"H:|-0-[_initialLabel]->=0-[_finalLabel]-0-|"
                        options:0
                        metrics:nil
                        views:NSDictionaryOfVariableBindings(_initialLabel, _finalLabel)]];
}


#pragma mark - Private Helpers

- (UIColor *)fillingColor
{
  EAColourfulProgressViewType segmentType = self.segmentTypeForCurrentValue;
  UIColor *initialSegmentColor = [self initialSegmentColorForSegmentType:segmentType];
  UIColor *finalSegmentColor = [self finalSegmentColorForSegmentType:segmentType];
  CGFloat initialRed, initialGreen, initialBlue;
  CGFloat finalRed, finalGreen, finalBlue;
  
  [initialSegmentColor getRed:&initialRed green:&initialGreen blue:&initialBlue alpha:nil];
  [finalSegmentColor getRed:&finalRed green:&finalGreen blue:&finalBlue alpha:nil];
  
  CGFloat redDelta = (initialRed - finalRed);
  CGFloat greenDelta = (initialGreen - finalGreen);
  CGFloat blueDelta = (initialBlue - finalBlue);
  float segmentFractionLeft = self.segmentFractionLeft;
  
  finalRed = initialRed - redDelta * segmentFractionLeft;
  finalGreen = initialGreen - greenDelta * segmentFractionLeft;
  finalBlue = initialBlue - blueDelta * segmentFractionLeft;
  
  return [UIColor colorWithRed:finalRed green:finalGreen blue:finalBlue alpha:0.8f];
}

- (EAColourfulProgressViewType)segmentTypeForCurrentValue
{
  float currentPercentage = self.fractionLeft * 100;
  float segmentSize = ((float)self.maximumValue) / EAColourfulProgressViewNumberOfSegments;
  float remainder = segmentSize - (((NSInteger)self.maximumValue) / ((NSUInteger)EAColourfulProgressViewNumberOfSegments));
  
  if (currentPercentage < (EAColourfulProgressViewType0to33 + remainder)) {
    return EAColourfulProgressViewType0to33;
  }
  
  if (currentPercentage < (EAColourfulProgressViewType33to66 + 2 * remainder)) {
    return EAColourfulProgressViewType33to66;
  }
  
  return EAColourfulProgressViewType66to100;
}


- (float)fractionLeft
{
  return [self fractionLeftWithCurrentValueIncluded:YES];
}

- (float)fractionLeftWithCurrentValueIncluded:(BOOL)shouldIncludeCurrentValue
{
  float maximumValue = (float)self.maximumValue;
  maximumValue = ((maximumValue > 0) ? maximumValue : 1);
  
  if (self.currentValue <= 0) {
    return 1;
  }
  
  if (self.currentValue > (maximumValue + 1)) {
    return 0;
  }
  
  return ((maximumValue - (self.currentValue - ((shouldIncludeCurrentValue) ? 1 : 0))) / maximumValue);
}

- (float)segmentFractionLeft
{
  float maximumValue = ((float)self.maximumValue) / EAColourfulProgressViewNumberOfSegments;
  maximumValue = ((maximumValue > 0) ? maximumValue : 1);
  
  float segmentValue = self.currentValue - 1;
  while (segmentValue > maximumValue) {
    segmentValue = segmentValue - maximumValue;
  }
  return ((maximumValue - segmentValue) / maximumValue);
}


#pragma mark - Color choosing

- (UIColor *)finalSegmentColorForSegmentType:(EAColourfulProgressViewType)segmentType
{
  switch (segmentType) {
    case EAColourfulProgressViewType0to33:
      return [self initialSegmentColorForSegmentType:EAColourfulProgressViewType33to66];
      
    case EAColourfulProgressViewType33to66:
      return [self initialSegmentColorForSegmentType:EAColourfulProgressViewType66to100];
      
    case EAColourfulProgressViewType66to100:
      return self.finalFillColor;
  }
  
  return nil;
}

- (UIColor *)initialSegmentColorForSegmentType:(EAColourfulProgressViewType)segmentType
{
  switch (segmentType) {
    case EAColourfulProgressViewType0to33:
      return self.initialFillColor;
      
    case EAColourfulProgressViewType33to66:
      return self.oneThirdFillColor;
      
    case EAColourfulProgressViewType66to100:
      return self.twoThirdsFillColor;
  }
  
  return nil;
}

@end