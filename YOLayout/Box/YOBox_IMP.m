//
//  YOBox.m
//  YOLayoutExample
//
//  Created by Gabriel on 3/13/15.
//  Copyright (c) 2015 YOLayout. All rights reserved.
//

#import "YOBox.h"

@interface YOBox (View)
@property NSString *identifier;
@end

@implementation YOBox

- (void)viewInit {
  [super viewInit];

  // Default box layout, sizes to fit left to right, top to bottom
  YOSelf yself = self;
  self.viewLayout = [YOLayout layoutWithLayoutBlock:^(id<YOLayout> layout, CGSize size) {
    CGFloat x = yself.insets.left;
    CGFloat y = yself.insets.top;
    NSInteger index = 0;
    BOOL wrap = NO;
    CGSize itemSize;
    CGFloat rowHeight = 0;
    CGFloat columnWidth = 0;
    NSArray *subviews = [self subviewsForLayout];
    for (id subview in subviews) {
      if (self.ignoreLayoutForHidden && [subview isHidden]) continue;
      itemSize = [subview sizeThatFits:CGSizeMake(size.width - yself.insets.right - x, size.height)];
      NSAssert(itemSize.width > 0, @"Item returned <= 0 width");

      NSString *identifier = [subview respondsToSelector:@selector(identifier)] ? [subview identifier] : nil;
      CGSize minSize = yself.minSize;
      if (identifier) {
        NSDictionary *viewOptions = yself.options[[subview identifier]];
        if (!!viewOptions[@"minSize"]) minSize = [self parseMinSize:viewOptions];
      }

      CGSize maxSize = yself.maxSize;
      if (identifier) {
        NSDictionary *viewOptions = yself.options[[subview identifier]];
        if (!!viewOptions[@"maxSize"]) maxSize = [self parseMaxSize:viewOptions];
      }

      itemSize.width = MAX(itemSize.width, minSize.width);
      itemSize.height = MAX(itemSize.height, minSize.height);
      if (maxSize.width != 0) itemSize.width = MIN(itemSize.width, maxSize.width);
      if (maxSize.height != 0) itemSize.height = MIN(itemSize.height, maxSize.height);
      rowHeight = MAX(rowHeight, itemSize.height);

      wrap = (x + itemSize.width) > size.width;
      if (wrap) {
        columnWidth = MAX(columnWidth, x);
        x = yself.insets.left;
        y += rowHeight + yself.spacing;
      }

      [layout setFrame:CGRectMake(x, y, itemSize.width, itemSize.height) view:subview];

      // If we didn't wrap on last item, then wrap
      x += itemSize.width;
      index++;

      if (index < [subviews count]) x += yself.spacing;
    }
    y += rowHeight + yself.insets.bottom;
    columnWidth = MAX(columnWidth, x);
    return CGSizeMake(columnWidth, y);
  }];
}

+ (instancetype)box {
  return [[self alloc] init];
}

+ (instancetype)box:(NSDictionary *)options {
  YOBox *box = [[self alloc] init];
  [box setOptions:options];
  return box;
}

+ (instancetype)boxWithSize:(CGSize)size {
  YOBox *box = [YOBox box];
  box.viewLayout = [YOLayout layoutWithLayoutBlock:^(id<YOLayout> layout, CGSize s) {
    return size;
  }];
  return box;
}

- (NSArray *)parseOption:(NSString *)option isFloat:(BOOL)isFloat minCount:(NSInteger)minCount {
  if (!option) return nil;

  NSMutableArray *options = [NSMutableArray array];
  if ([option isKindOfClass:NSString.class]) {
    NSArray *split = [option componentsSeparatedByString:@","];
    for (NSString *o in split) {
      if (isFloat) {
        [options addObject:@([o floatValue])];
      } else {
        [options addObject:@([o integerValue])];
      }
    }
  } else {
    [options addObject:option];
  }
  if ([options count] < minCount) return nil;
  return options;
}

- (void)setOptions:(NSDictionary *)options {
  _options = options;
  NSArray *insets = [self parseOption:options[@"insets"] isFloat:YES minCount:1];
  if (insets) {
    if ([insets count] == 4) {
      self.insets = UIEdgeInsetsMake([insets[0] floatValue], [insets[1] floatValue], [insets[2] floatValue], [insets[3] floatValue]);
    } else {
      self.insets = UIEdgeInsetsMake([insets[0] floatValue], [insets[0] floatValue], [insets[0] floatValue], [insets[0] floatValue]);
    }
  }
  self.spacing = [options[@"spacing"] floatValue];

  self.minSize = [self parseMinSize:_options];
  self.maxSize = [self parseMaxSize:_options];

  NSString *ha = options[@"horizontalAlignment"];
  if ([ha isEqualToString:@"right"]) self.horizontalAlignment = YOHorizontalAlignmentRight;
  else if ([ha isEqualToString:@"center"]) self.horizontalAlignment = YOHorizontalAlignmentCenter;
  else if ([ha isEqualToString:@"left"]) self.horizontalAlignment = YOHorizontalAlignmentLeft;
}

- (CGSize)parseMaxSize:(NSDictionary *)options {
  NSArray *maxSize = [self parseOption:options[@"maxSize"] isFloat:YES minCount:2];
  if (!maxSize) return CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  return CGSizeMake([maxSize[0] floatValue], [maxSize[1] floatValue]);
}

- (CGFloat)parseFloat:(NSString *)str value:(CGFloat)value {
  if (!str) return value;
  if ([str hasSuffix:@"%"]) {
    return [[str substringToIndex:str.length-1] floatValue] * 0.01 * value;
  } else {
    return [str floatValue];
  }
}

- (CGSize)parseSize:(NSDictionary *)options viewSize:(CGSize)viewSize inSize:(CGSize)inSize {
  if (!options) return viewSize;
  viewSize.width = [self parseFloat:options[@"width"] value:viewSize.width];
  viewSize.height = [self parseFloat:options[@"height"] value:viewSize.height];
  return viewSize;
}

- (CGSize)parseMinSize:(NSDictionary *)options {
  NSArray *minSize = [self parseOption:options[@"minSize"] isFloat:YES minCount:2];
  if (!minSize) return CGSizeZero;
  return CGSizeMake([minSize[0] floatValue], [minSize[1] floatValue]);
}

- (NSArray *)subviewsForLayout {
  if (!self.ignoreLayoutForHidden) return [self subviews];
  NSMutableArray *subviews = [NSMutableArray arrayWithCapacity:self.subviews.count];
  for (id subview in self.subviews) {
    if (![subview isHidden]) [subviews addObject:subview];
  }
  return subviews;
}

@end
