//
// ZXImageView.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ZXImageView.h"

static NSString * const _reuseIdentifier = @"ZXImageViewCell";

@interface ZXImageView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ZXImageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    // Do any additional setup after loading the view.
    self.itemSpacing = 10.f;
    //
    CGRect frame = self.bounds;
    frame.size.width += self.itemSpacing;
    // Configure the layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = self.itemSpacing;
    layout.minimumInteritemSpacing = self.itemSpacing;
    layout.itemSize = self.bounds.size;
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, self.itemSpacing);
    // Configure the UICollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.collectionView.allowsSelection = NO;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.collectionView];
    // Register cell classes
    [self registerCellClass:[ZXImageViewCell class]];
}

- (void)registerCellClass:(Class)cellClass {
    if ([cellClass isSubclassOfClass:[ZXImageViewCell class]]) {
        [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:_reuseIdentifier];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    CGRect frame = self.bounds;
    frame.size.width += self.itemSpacing;
    self.collectionView.frame = frame;
}

#pragma mark Setter

- (void)setItemSpacing:(CGFloat)itemSpacing {
    _itemSpacing = itemSpacing;
    [self reloadData];
}

#pragma mark Functions

- (ZXImageViewCell *)dequeueReusableCellForItemAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [_collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
}

- (ZXImageViewCell *)cellForItemAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return (ZXImageViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
}

- (NSInteger)numberOfItems {
    return [self.collectionView numberOfItemsInSection:0];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (NSInteger)indexForVisibleItem {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    return indexPath ? indexPath.row : NSNotFound;
}

- (void)scrollToItemAtIndex:(NSUInteger)index animated:(BOOL)animated {
    if (index < self.numberOfItems) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:animated];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([_dataSource respondsToSelector:@selector(numberOfItemsInImageView:)]) {
        return [_dataSource numberOfItemsInImageView:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZXImageViewCell *cell;
    if ([_dataSource respondsToSelector:@selector(imageView:cellForItemAtIndex:)]) {
        cell = [_dataSource imageView:self cellForItemAtIndex:indexPath.item];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    }
    //
    [cell setValue:self forKey:@"internalImageView"];
    [cell setValue:indexPath forKey:@"internalIndexPath"];
    //
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, self.itemSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

@end
