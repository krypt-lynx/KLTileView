//
//  SlidesView.m
//  slidebeat
//
//  Created by Krypt on 24.03.13.
//  Copyright (c) 2013 home. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "KLTileView.h"

const float SCROLL_START_DELAY = 0.5f;
const float HOLD_ZONE = 10.0f;
const float SCROLL_ACCELERATION = 0.12;
const float SCROLL_MAX_SPEED = 6;
const float SCROLL_FIELD = 50;


@implementation KLTileView
@synthesize delegate;
@synthesize dataSource;

@synthesize contentAlignment;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor orangeColor];

        scroller = [[[UIScrollView alloc] init] autorelease];
        [self addSubview:scroller];

        UILongPressGestureRecognizer *lpgr = [[[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(startDrag:)] autorelease];
        dragGr = lpgr;
        [lpgr setEnabled:NO];
        [lpgr setDelegate:self];
        
        [lpgr setMinimumPressDuration:0.1];
        [self addGestureRecognizer:lpgr];
        
        activeCellIndex = -1;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *topView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:self] withEvent:nil];
    return [[topView class] isSubclassOfClass:[KLTileViewCell class]];
}

- (void) startDrag:(UILongPressGestureRecognizer*) lpgr
{
    CGPoint scPt = [lpgr locationInView:scroller];
    CGPoint rtPt = [lpgr locationInView:self];

    BOOL inScrollZone = ((rtPt.y < SCROLL_FIELD) || ((self.frame.size.height - rtPt.y) < SCROLL_FIELD));

    switch (lpgr.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *cellIndexPath = [self pointInCell:scPt];
            int cellIndex = [self indexPathToIndex:cellIndexPath];
            
            touchOffset = [self offsetForPoint:scPt relativeToCell:cellIndexPath];
            
            activeCellIndex = cellIndex;
            activeCell = (activeCellIndex>=0)?[cells objectAtIndex:cellIndex]:nil;
            [scroller bringSubviewToFront:activeCell];
            [activeCell setState:SlidesViewItemStateActive animated:YES];
            
            
            if (inScrollZone)
            {
                [self resetScroll];
                scrollDirection = (rtPt.y < SCROLL_FIELD)?-1:1;


                holdPoint = rtPt;
                scrollStartTimer = [NSTimer scheduledTimerWithTimeInterval:SCROLL_START_DELAY target:self selector:@selector(beginScroll:) userInfo:nil repeats:NO];
            }
            
        }   break;
        case UIGestureRecognizerStateChanged:
        {
            NSIndexPath *cellIndexPath = [self pointInCell:CGPointMake(scPt.x - touchOffset.width + cellSize.width/2, scPt.y - touchOffset.height + cellSize.height/2)];
            
            int cellIndex = [self indexPathToIndex:cellIndexPath];

            [activeCell setFrame:CGRectMake(scPt.x - touchOffset.width, scPt.y - touchOffset.height, cellSize.width, cellSize.height)];

            [self moveCellToIndex:cellIndex];

            BOOL isHolding = ((ABS(rtPt.x - holdPoint.x) < HOLD_ZONE) || (ABS(rtPt.y - holdPoint.y) < HOLD_ZONE));

            if (isHolding && inScrollZone)
            {
                scrollDirection = (rtPt.y < SCROLL_FIELD)?-1:1;

                if ((!isScrolling) && (!scrollStartTimer))
                    scrollStartTimer = [NSTimer scheduledTimerWithTimeInterval:SCROLL_START_DELAY target:self selector:@selector(beginScroll:) userInfo:nil repeats:NO];
            }
            else
            {
                holdPoint = rtPt;
                [self resetScroll];

            }
            
        }   break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [self resetScroll];
            
            [activeCell setState:SlidesViewItemStateNormal animated:YES];

            activeCellIndex = -1;
            activeCell = nil;
            [self updateLayoutAnimated:YES];

        }   break;
        default:
            break;
    }
}

- (void) moveCellToIndex:(int)cellIndex
{
    if (activeCellIndex != cellIndex)
    {
        NSLog(@"reorder: %d > %d", activeCellIndex, cellIndex);

        [dataSource tileView:self moveCellAtIndex:activeCellIndex toIndex:cellIndex];

        [cells removeObject:activeCell];
        [cells insertObject:activeCell atIndex:cellIndex];

        activeCellIndex = cellIndex;

        [self updateLayoutAnimated:YES];
    }
}

- (void) resetScroll
{
    isScrolling = NO;
    scrollSpeed = 0;
    
    [scrollStartTimer invalidate];
    scrollStartTimer = nil;
    [scrollLink invalidate];
    [scrollLink release];
    scrollLink = nil;    
}

- (void) beginScroll:(id)sender
{
    isScrolling = YES;
    scrollStartTimer = nil;
    scrollLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(doScroll:)] retain];
    [scrollLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) doScroll:(id)sender
{
    scrollSpeed = scrollDirection*MIN(ABS(scrollSpeed) + SCROLL_ACCELERATION, SCROLL_MAX_SPEED);
    
    scroller.contentOffset = CGPointMake(0, MAX(0,MIN(scroller.contentOffset.y + scrollSpeed, scroller.contentSize.height - scroller.frame.size.height)));

    CGPoint scPt = [dragGr locationInView:scroller];
    NSIndexPath *cellIndexPath = [self pointInCell:CGPointMake(scPt.x - touchOffset.width + cellSize.width/2, scPt.y - touchOffset.height + cellSize.height/2)];
    int cellIndex = [self indexPathToIndex:cellIndexPath];

    [activeCell setFrame:CGRectMake(scPt.x - touchOffset.width, scPt.y - touchOffset.height, cellSize.width, cellSize.height)];

    [self moveCellToIndex:cellIndex];
}

- (NSIndexPath *) pointInCell:(CGPoint)pt
{
    NSUInteger indp[] = {(NSUInteger) MIN(MAX(0, ((pt.x - offset.x)/cellSize.height)), columnCount-1),
                        (NSUInteger) MIN(MAX(0, ((pt.y - offset.y)/cellSize.width)), rowCount-1)};
    return [NSIndexPath indexPathWithIndexes:indp length:2];
}

- (CGSize) offsetForPoint:(CGPoint)pt relativeToCell:(NSIndexPath*)cell
{
    return CGSizeMake(pt.x - offset.x - cellSize.width*[cell indexAtPosition:0], pt.y - offset.y - cellSize.height*[cell indexAtPosition:1]);
}

- (int) indexPathToIndex:(NSIndexPath *)indp
{
    return [cells count]?MAX(0, MIN([indp indexAtPosition:0] + [indp indexAtPosition:1] * columnCount, [cells count]-1)):-1;
}

- (void) reloadData
{
    int itemsCount = [dataSource tileViewNumberOfCells:self];
    cellSize = [dataSource tileViewSizeForCells:self];

    for (UIView *cell in cells)
    {
        [cell removeFromSuperview];
    }

    activeCellIndex = -1;
    
    [cells release];
    cells = [[NSMutableArray array] retain];


    for (int i = 0; i < itemsCount; i++)
    {
        KLTileViewCell *cell = [dataSource tileView:self cellForIndex:i];
        cell.delegate = self;
        [cells addObject:cell];

        [scroller addSubview:cell];
    }

    [self updateLayout];

//    [self setNeedsLayout];
//    [self layoutSubviews];
}

- (void) tileViewItemRemove:(KLTileViewCell *)slidesViewItem
{
    int index = [cells indexOfObject:slidesViewItem];

    
    if ([dataSource respondsToSelector:@selector(tileView:canEditCellAtIndex:)] && ![dataSource tileView:self canEditCellAtIndex:index])
        return;

    [cells removeObject:slidesViewItem];
    [self updateLayoutAnimated:YES];

    [UIView animateWithDuration:0.3f
                     animations:^
                     {
                         CGRect frame = slidesViewItem.frame;
                         [slidesViewItem setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height/2,
                                 frame.size.width, frame.size.height)];
                         [slidesViewItem setAlpha:0];
                     }
                     completion:^(BOOL finished)
                     {
                         [slidesViewItem removeFromSuperview];
                     }];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];

    [self updateLayout];
}

- (void) updateLayout
{
    [self updateLayoutAnimated:NO];
}

- (void) updateLayoutAnimated:(BOOL)animated
{
    if (!cells)
        return;
    if (cellSize.width > self.frame.size.width)
        return;

    offset = CGPointMake(fmod(self.frame.size.width, cellSize.width)/2, fmod(self.frame.size.width, cellSize.width)/2);

    columnCount = (int)floor(self.frame.size.width / cellSize.width);
    rowCount = MAX((int)ceil((float)[cells count]/columnCount), (int)ceil(self.frame.size.height / cellSize.height));

    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }


    [scroller setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [scroller setContentSize:CGSizeMake(self.frame.size.width,
            (CGFloat)(ceil([cells count] / (float)columnCount) * cellSize.height) + offset.y*2)];


    [self updateCells];

    if (animated)
    {
        [UIView commitAnimations];
    }
}

- (void) updateCells
{

    int col = 0;
    int row = 0;

    for (KLTileViewCell *view in cells)
    {
        if (view != activeCell)
            [view setFrame:CGRectMake(offset.x + cellSize.width * col, offset.y + cellSize.height * row, cellSize.width, cellSize.height)];
        
        col++;
        if (col >= columnCount)
        {
            col = 0;
            row++;
        }
    }
    

}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    isEditing = editing;
    
    for (int i = 0; i < [cells count]; i++)
    {
        KLTileViewCell *cell = [cells objectAtIndex:i];
        
        if (!editing || ![dataSource respondsToSelector:@selector(tileView:canEditCellAtIndex:)] || [dataSource tileView:self canEditCellAtIndex:i])
        {
            [cell setEditing:editing animated:animated];
        }
    }

    [dragGr setEnabled:editing];
}

- (void)setItemMoveDelay:(float)itemMoveDelay
{
    [dragGr setMinimumPressDuration:itemMoveDelay];
}

- (float)itemMoveDelay
{
    return [dragGr minimumPressDuration];
}

- (void) dealloc
{
    [scrollStartTimer invalidate];
    scrollStartTimer = nil;
    
    [super dealloc];
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
