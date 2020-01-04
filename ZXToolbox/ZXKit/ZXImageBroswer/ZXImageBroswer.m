//
// ZXImageBroswer.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
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

@interface ZXImageBroswer () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
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
    self.imageSpacing = 10.f;
    //
    CGRect frame = self.bounds;
    frame.size.width += self.imageSpacing;
    // Configure the layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = self.imageSpacing;
    layout.minimumInteritemSpacing = self.imageSpacing;
    layout.itemSize = self.bounds.size;
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, self.imageSpacing);
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
    [self registerClass:ZXImageBroswerCell.class forCellWithReuseIdentifier:@"ZXImageBroswerCell"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    CGRect frame = self.bounds;
    frame.size.width += self.imageSpacing;
    self.collectionView.frame = frame;
}

#pragma mark Getter

- (NSInteger)currentIndex {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    return indexPath ? indexPath.row : NSNotFound;
}

#pragma mark Setter

- (void)setImageSources:(NSArray *)imageSources {
    _imageSources = [imageSources copy];
    [self.collectionView reloadData];
}

- (void)setImageSpacing:(CGFloat)itemSpacing {
    _imageSpacing = itemSpacing;
    [self setNeedsLayout];
    [self.collectionView reloadData];
}

- (void)setCurrentIndex:(NSInteger)index {
    [self setCurrentIndex:index animated:YES];
}

- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < self.imageSources.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionLeft
                                        animated:animated];
    }
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

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, self.imageSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.imageSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.imageSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

@end


@implementation ZXImageBroswer (ZXImageBroswerCell)

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

@end
