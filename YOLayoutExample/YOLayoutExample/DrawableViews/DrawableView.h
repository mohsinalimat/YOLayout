//
//  DrawableView.h
//  YOLayoutExample
//
//  Created by John Boiles on 12/16/14.
//  Copyright (c) 2014 YOLayout. All rights reserved.
//

#import "YOLayout.h"

/*!
 UIViews can also use custom layouts even if they aren't in the view hierarchy (can't do that with Auto Layout!). This protocol presents a convention for how to create drawable views. To create a drawable view, simply create a YOView that implements drawInRect:. Then superviews can draw the view in their drawRect method.
 */
@protocol YODrawableView

/*!
 @result Draw the drawable
 */
- (void)drawInRect:(CGRect)rect;

@end

/*!
 A view that uses YOLayout to lay out drawable subviews in a grid based on the width.

 YOLayout is unique in that it doesn't require views to be in the view hierarchy in order to lay them out. This means you can create layouts using YOLayout like normal, then render your drawable 'subviews' in `drawRect:`. This makes for a super easy way to mix and match views in the view hierarchy and views drawn in `drawRect:`. In scroll views, using `drawRect:` can sometimes perform better when you have many subviews.

 One bonus of rendering your drawable 'subviews' is that you can use the IB_DESIGNABLE tag to have your views rendered live in Interface Builder. Check out DrawableView.xib to see how DrawableView gets rendered dynamically in Interface Builder. Try making in skinnier and wider and see what happens.
 */
IB_DESIGNABLE
@interface DrawableView : YOView

@end
