//
//  MMFGridViewLayout.m
//  layout
//
//  Created by Nikolay Vyshynskyi on 27.09.13.
//  Copyright (c) 2013 Nikolay Vyshynskyi. All rights reserved.
//

#import "MMFGridViewLayout.h"

@interface MMFGridViewLayout ()

@property (nonatomic, copy) NSArray *layoutsInfo;
@property (nonatomic, strong) NSMutableArray *sectionFrames;
@property (nonatomic, strong) NSMutableArray *itemFrames;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation MMFGridViewLayout

- (instancetype)initWithLayouts:(NSArray *)layouts
{
    self = [super init];
    if (self) {
        self.layouts = layouts;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layouts = @[@"FrontPage1Grid Berlingske Evening"/*, @"FrontPage1Grid Forside", @"FrontPage2Grid"*/];
    }
    return self;
}

- (void)setLayouts:(NSArray *)layouts
{
    if (_layouts != layouts) {
        _layouts = layouts;
        
        NSURL *layoutsFileURL = [[NSBundle mainBundle] URLForResource:@"Layouts" withExtension:@"plist"];
        NSDictionary *layoutsInfoDictionary = [[NSDictionary alloc] initWithContentsOfURL:layoutsFileURL];
        NSMutableArray *layoutsInfo = [[NSMutableArray alloc] init];
        for (NSString *layoutName in _layouts) {
            NSDictionary *layoutInfo = layoutsInfoDictionary[layoutName];
            if (layoutsInfo)
                [layoutsInfo addObject:layoutInfo];
        }
        
        self.layoutsInfo = layoutsInfo;
    }
}

- (void)setLayoutsInfo:(NSArray *)layoutsInfo
{
    if (_layoutsInfo != layoutsInfo) {
        _layoutsInfo = layoutsInfo;

        [self invalidateLayout];
//        [self.collectionView reloadData];
    }
}

- (NSInteger)numberOfSections
{
    return _layouts.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
//    return 1;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSString *orientationKey = (UIInterfaceOrientationIsPortrait(orientation) ? @"Portrait" : @"Landscape");
    NSDictionary *sectionInfo = _layoutsInfo[section % [self numberOfSections]][orientationKey];
    NSArray *cellsInfo = sectionInfo[@"Cells"];

    if ([_layouts[section] isEqualToString:@"FrontPage1Grid Forside"])
        return (UIInterfaceOrientationIsPortrait(orientation)? 6 : 5);

    return [cellsInfo count];
}

#pragma mark UICollectionViewLayout (SubclassingHooks)

- (void)prepareLayout
{
    DLog();
    [super prepareLayout];
    
    if (_layouts.count == 1 && [_layouts[0] isEqualToString:@"FrontPage1Grid Berlingske Evening"]) {
        self.collectionView.pagingEnabled = NO;
    }
    
    BOOL pagingEnabled = self.collectionView.pagingEnabled;
    
    
    NSString *orientationKey = (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? @"Portrait" : @"Landscape");

    self.sectionFrames = [[NSMutableArray alloc] init];
    self.itemFrames = [[NSMutableArray alloc] init];
    
    CGFloat height = 0;
    
    for (int section = 0; section < [self.collectionView numberOfSections]; section++) {
        NSDictionary *sectionInfo = _layoutsInfo[section % [self numberOfSections]][orientationKey];
        CGRect sectionFrame = CGRectZero;
        if (pagingEnabled)
            sectionFrame = CGRectMake(0, height, [sectionInfo[@"width"] floatValue], [sectionInfo[@"height"] floatValue]);
        else
            sectionFrame = CGRectMake(0, height, [(sectionInfo[@"contentWidth"]?:sectionInfo[@"width"]) floatValue], [(sectionInfo[@"contentHeight"]?:sectionInfo[@"height"]) floatValue]);

        sectionFrame.origin.x += floorf(self.collectionView.frame.size.width/2 - sectionFrame.size.width/2);
//        sectionFrame.origin.y += floorf(self.collectionView.frame.size.height/2 - sectionFrame.size.height/2);
        [self.sectionFrames addObject:[NSValue valueWithCGRect:sectionFrame]];
        
        NSArray *cellsInfo = sectionInfo[@"Cells"];
        
        CGFloat sectionMaxHeight = 0;
        NSMutableArray *sectionItemFrames = [[NSMutableArray alloc] init];
        for (int item = 0; item < MIN(cellsInfo.count, [self numberOfItemsInSection:section]); item++) {
            NSDictionary *cellInfo = cellsInfo[item];
            CGRect itemFrame = CGRectMake([cellInfo[@"x"] floatValue], [cellInfo[@"y"] floatValue], [cellInfo[@"width"] floatValue], [cellInfo[@"height"] intValue]);
            [sectionItemFrames addObject:[NSValue valueWithCGRect:itemFrame]];
            sectionMaxHeight = MAX(sectionMaxHeight, CGRectGetMaxY(itemFrame));
        }
        
        sectionFrame.origin.y += floorf(self.collectionView.frame.size.height/2 - sectionMaxHeight/2);

        if (pagingEnabled)
            height += self.collectionView.frame.size.height;
        else
            height += sectionFrame.size.height;
        [self.itemFrames addObject:sectionItemFrames];
    }
    
    self.contentSize = CGSizeMake(self.collectionView.frame.size.width, MAX(self.collectionView.frame.size.height, height));
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

#pragma mark - UICollectionViewLayout (SubclassingHooks)

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    DLog(@"%@", NSStringFromCGRect(rect));
    
    NSMutableArray* attributes = [[NSMutableArray alloc] init];
    for (NSInteger section = 0; section < _sectionFrames.count; section++)
    {
        CGRect sectionFrame = [_sectionFrames[section] CGRectValue];
        if (CGRectIntersectsRect(sectionFrame, rect))
        {
            NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
            for (int item = 0; item < itemCount; item++)
            {
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            }
        }
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"%@", indexPath);
    
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    CGRect frame = [_itemFrames[indexPath.section][indexPath.item % [self numberOfItemsInSection:indexPath.section]] CGRectValue];
    frame.origin.x += [_sectionFrames[indexPath.section] CGRectValue].origin.x;
    frame.origin.y += [_sectionFrames[indexPath.section] CGRectValue].origin.y;
    attributes.frame = frame;
    DLog(@"%@", [NSValue valueWithCGRect:attributes.frame]);
    
    return attributes;
}


@end
