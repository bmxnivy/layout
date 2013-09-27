//
//  MMFGridViewLayout.h
//  layout
//
//  Created by Nikolay Vyshynskyi on 27.09.13.
//  Copyright (c) 2013 Nikolay Vyshynskyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMFGridViewLayout : UICollectionViewFlowLayout

@property (nonatomic, copy) NSArray *layouts;

- (instancetype)initWithLayouts:(NSArray *)layouts;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

@end
