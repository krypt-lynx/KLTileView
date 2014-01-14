//
//  SlidesViewItem.m
//  slidebeat
//
//  Created by Krypt on 24.03.13.
//  Copyright (c) 2013 home. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "KLTileViewCell.h"

@implementation KLTileViewCell
@synthesize state;
@synthesize removeIconVisible;
@synthesize delegate;

const float ZOOM_EFFECT = 1.4;
const float BTN_SIZE = 25;

- (id)init
{
    if (self = [super init])
    {
        // Initialization code

        //self.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3f];

        removeButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [removeButton setCenter:CGPointMake(BTN_SIZE/2, BTN_SIZE/2)];
        [removeButton setBounds:CGRectMake(0, 0, BTN_SIZE, BTN_SIZE)];
        [removeButton addTarget:self action:@selector(removePressed:)
               forControlEvents:UIControlEventTouchUpInside];
        [removeButton setAlpha:0];
        [self addSubview:removeButton];
    }
    return self;
}

- (void) removePressed:(id)sender
{
    [delegate tileViewItemRemove:self];
}

- (id) initWithImage:(UIImageView *)image_ // todo: WTF?
{
    self = [self init];
    if (self)
    {
        self.image = image_;
    }

    return self;
}

+ (id) itemWithImage:(UIImage *)image_ // todo: WTF?
{
    return [[[self alloc] initWithImage:image_] autorelease];
}


- (void) setImage:(UIImageView *)image_
{
    [image removeFromSuperview];
    [image autorelease];

    image = [image_ retain];
    [self addSubview:image];
    [self bringSubviewToFront:removeButton];

    [self updateLayout];
}

- (void) setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    
    [super setFrame:frame];
    if (!(CGRectIsEmpty(frame) || CGSizeEqualToSize(oldFrame.size, frame.size)))
        [self updateLayout];
}

- (void) updateLayout
{
    [image setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void) setState:(SlidesViewItemState)state_
{
    [self setState:state_ animated:NO];
}

- (void) setState:(SlidesViewItemState)state_ animated:(BOOL)animated_
{
    state = state_;

    if (animated_)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    switch (state)
    {
        case SlidesViewItemStateNormal:
        {
            [removeButton setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [removeButton setCenter:CGPointMake(BTN_SIZE/2, BTN_SIZE/2)];
            [image setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        }   break;
        case SlidesViewItemStateActive:
        {
            float dx = (self.frame.size.width - BTN_SIZE) / self.frame.size.width;
            float dy = (self.frame.size.height - BTN_SIZE) / self.frame.size.height;

            [removeButton setTransform:CGAffineTransformMakeScale(ZOOM_EFFECT, ZOOM_EFFECT)];
            [removeButton setCenter:CGPointMake((self.frame.size.width-self.frame.size.width*dx*ZOOM_EFFECT)/2,
                    (self.frame.size.height-self.frame.size.height*dy*ZOOM_EFFECT)/2)];
            [image setTransform:CGAffineTransformMakeScale(ZOOM_EFFECT, ZOOM_EFFECT)];
        }   break;
    }
    if (animated_)
    {
        [UIView commitAnimations];
    }

}

- (void) setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated_;
{
    if (animated_)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    
    [removeButton setAlpha:editing?1:0];
    
    if (animated_)
    {
        [UIView commitAnimations];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
