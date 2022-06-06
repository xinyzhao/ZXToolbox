//
// ZXImageBroswer.m
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

#import "ZXImageBroswer.h"

@interface ZXImageBroswerFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) NSInteger contentIndex;

@end

@interface ZXImageBroswer () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZXImageBroswerFlowLayout *flowLayout;
@property (nonatomic, copy) NSString *reuseIdentifier;

@end

@implementation ZXImageBroswer

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithImages:(NSArray *)images {
    self = [self init];
    if (self) {
        self.imageSources = images;
    }
    return self;
}

- (void)setupViews {
    // Do any additional setup after loading the view.
    _imageSpacing = 10.f;
    //
    CGRect frame = self.bounds;
    frame.size.width += self.imageSpacing;
    // Configure the layout
    _flowLayout = [[ZXImageBroswerFlowLayout alloc] init];
    _flowLayout.minimumLineSpacing = _imageSpacing;
    _flowLayout.minimumInteritemSpacing = _imageSpacing;
    _flowLayout.itemSize = self.bounds.size;
    _flowLayout.headerReferenceSize = CGSizeZero;
    _flowLayout.footerReferenceSize = CGSizeZero;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, _imageSpacing);
    // Configure the UICollectionView
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:_flowLayout];
    _collectionView.allowsSelection = NO;
    _collectionView.allowsMultipleSelection = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:_collectionView];
    // Register cell classes
    [self registerClass:ZXImageBroswerCell.class forCellWithReuseIdentifier:@"ZXImageBroswerCell"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    CGRect frame = self.bounds;
    self.flowLayout.itemSize = frame.size;
    frame.size.width += self.imageSpacing;
    self.collectionView.frame = frame;
}

#pragma mark Display index

- (NSInteger)visibleIndex {
    NSIndexPath *indexPath = nil;
    CGFloat distance = _collectionView.bounds.size.width;
    CGFloat centerX = _collectionView.contentOffset.x + distance / 2;
    NSArray *list = [_collectionView indexPathsForVisibleItems];
    for (NSIndexPath *item in list) {
        UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:item];
        CGFloat dist = ABS(attr.center.x - centerX);
        if (distance > dist) {
            distance = dist;
            indexPath = item;
        }
    }
    return indexPath ? indexPath.item : NSNotFound;
}

- (void)setCurrentIndex:(NSInteger)index {
    [self setCurrentIndex:index animated:YES];
}

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated {
    _currentIndex = index;
    if (_collectionView.visibleCells.count > 0 && index < self.imageSources.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:animated];
    } else {
        _flowLayout.contentIndex = _currentIndex;
    }
}

#pragma mark Image Sources

- (void)setImageSources:(NSArray *)imageSources {
    _imageSources = [imageSources copy];
    [self.collectionView reloadData];
}

- (void)setImageSpacing:(CGFloat)itemSpacing {
    _imageSpacing = itemSpacing;
    [self setNeedsLayout];
    [self.collectionView reloadData];
}

#pragma mark ZXImageBroswerCell

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    if ([cellClass isSubclassOfClass:[ZXImageBroswerCell class]]) {
        _reuseIdentifier = [identifier copy];
        [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:_reuseIdentifier];
    }
}

- (ZXImageBroswerCell *)dequeueReusableCellForImageAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [_collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
}

- (ZXImageBroswerCell *)cellForImageAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return (ZXImageBroswerCell *)[_collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZXImageBroswerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    //
    id obj = _imageSources[indexPath.item];
    if ([obj isKindOfClass:NSURL.class]) {
        cell.image = nil;
        cell.imageURL = obj;
    } else if ([obj isKindOfClass:UIImage.class]) {
        cell.image = obj;
        cell.imageURL = nil;
    }
    //
    __weak typeof(self) weakSelf = self;
    if (_onSingleTap) {
        cell.onSingleTap = ^{
            weakSelf.onSingleTap(indexPath.item, obj);
        };
    }
    if (_onDoubleTap) {
        cell.onDoubleTap = ^{
            weakSelf.onDoubleTap(indexPath.item, obj);
        };
    }
    if (_onLongPress) {
        cell.onLongPress = ^{
            weakSelf.onLongPress(indexPath.item, obj);
        };
    }
    //
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_didDisplay) {
        NSInteger index = [self visibleIndex];
        if (index == NSNotFound) {
            index = indexPath.row;
        }
        if (index < _imageSources.count) {
            id obj = _imageSources[index];
            _didDisplay(index, obj);
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:ZXImageBroswerCell.class]) {
        ZXImageBroswerCell *ibc = (ZXImageBroswerCell *)cell;
        [ibc restore:NO];
    }
    if (_didDisplay) {
        NSInteger index = [self visibleIndex];
        if (index < _imageSources.count) {
            id obj = _imageSources[index];
            _didDisplay(index, obj);
        }
    }
}

@end

@implementation ZXImageBroswerFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    CGFloat x = _contentIndex * (self.itemSize.width + self.minimumInteritemSpacing);
    self.collectionView.contentOffset = CGPointMake(x, 0);
}

@end
