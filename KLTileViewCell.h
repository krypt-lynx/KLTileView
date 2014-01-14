//
//  SlidesViewItem.h
//  slidebeat
//
//  Created by Krypt on 24.03.13.
//  Copyright (c) 2013 home. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    SlidesViewItemStateNormal,
    SlidesViewItemStateActive
}   SlidesViewItemState;

@protocol KLTileViewItemDelegate;

@interface KLTileViewCell : UIView
{
    UIButton *removeButton;
    UIImageView *image;
    SlidesViewItemState state;
    BOOL removeIconVisible;

    id<KLTileViewItemDelegate> delegate;
}

@property (nonatomic, assign) id<KLTileViewItemDelegate> delegate;

@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, assign) SlidesViewItemState state;
@property (nonatomic, assign) BOOL removeIconVisible;


- (id) initWithImage:(UIImageView *)image;
+ (id) itemWithImage:(UIImageView *)image;

- (void) setState:(SlidesViewItemState)state animated:(BOOL)animated;
- (void) setEditing:(BOOL)editing animated:(BOOL)animated;

@end


@protocol KLTileViewItemDelegate
- (void) tileViewItemRemove:(KLTileViewCell*)slidesViewItem;

@end
