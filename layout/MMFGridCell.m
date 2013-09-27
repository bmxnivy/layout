//
//  MMFGridCell.m
//  layout
//
//  Created by Nikolay Vyshynskyi on 27.09.13.
//  Copyright (c) 2013 Nikolay Vyshynskyi. All rights reserved.
//

#import "MMFGridCell.h"
#import <QuartzCore/QuartzCore.h>

@interface MMFGridCell ()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;

- (void)commonInit;

@end

@implementation MMFGridCell

- (void)commonInit
{
    self.titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24.f];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    self.titleLabel.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

@end
