//
//  KLTileView.h
//  slidebeat
//
//  Created by Krypt on 24.03.13.
//  Copyright (c) 2013 home. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "debuglog.h"
#import "KLTileViewCell.h"
#import <QuartzCore/QuartzCore.h>
@protocol KLTileViewDelegate;
@protocol KLTileViewDataSource;
@class KLTileViewCell;

typedef enum
{
    KLTileViewContentAlignmentLeftTop,
    KLTileViewContentAlignmentCenterTop,
    KLTileViewContentAlignmentCenter,
    KLTileViewContentAlignmentScaleToFill
    
} KLTileViewContentAlignment;


@interface KLTileView : UIView  <KLTileViewItemDelegate, UIGestureRecognizerDelegate>
{
    NSObject<KLTileViewDelegate> *delegate;
    NSObject<KLTileViewDataSource> *dataSource;

    UIScrollView *scroller;

    CGSize cellSize;
    CGPoint offset;
    NSMutableArray *cells;

    int activeCellIndex;
    KLTileViewCell *activeCell;
    KLTileViewCell *floatingActiveCell;
    CGSize touchOffset;
    
    CGPoint holdPoint;
    
    NSTimer *scrollStartTimer;
    CADisplayLink *scrollLink;
    float scrollSpeed;
    float scrollDirection;
    BOOL isScrolling;
    
    int columnCount;
    int rowCount;
    
    UILongPressGestureRecognizer *dragGr;
    
    KLTileViewContentAlignment contentAlignment;
    
    BOOL isEditing;
}

@property (nonatomic, assign) NSObject<KLTileViewDelegate> *delegate;
@property (nonatomic, assign) NSObject<KLTileViewDataSource> *dataSource;

@property (nonatomic, assign) KLTileViewContentAlignment contentAlignment;
@property (nonatomic, assign) float itemMoveDelay;

- (void) reloadData;
- (void) setEditing:(BOOL)editing animated:(BOOL)animated;

@end

@protocol KLTileViewDataSource

@required

- (int) tileViewNumberOfCells:(KLTileView *)tileView;
- (KLTileViewCell *) tileView:(KLTileView *)tileView cellForIndex:(int)index;
- (CGSize) tileViewSizeForCells:(KLTileView *)tileView;

@optional

- (BOOL) tileView:(KLTileView *)tileView canEditCellAtIndex:(int)index;
- (BOOL) tileView:(KLTileView *)tileView canMoveCellAtIndex:(int)index;
- (void) tileView:(KLTileView *)tileView moveCellAtIndex:(int)from toIndex:(int)to;

@end

@protocol KLTileViewDelegate

@optional


@end

/*
 @protocol UITableViewDataSource<NSObject>
 
 @required
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
 
 // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
 // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
 
 @optional
 
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented
 
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
 - (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
 
 // Editing
 
 // Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
 
 // Moving/reordering
 
 // Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
 
 // Index
 
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
 - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;  // tell table which section corresponds to section title/index (e.g. "B",1))
 
 // Data manipulation - insert and delete support
 
 // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
 
 // Data manipulation - reorder / moving support
 
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
 
 @end
 
*/


/*

 @protocol UITableViewDelegate<NSObject, UIScrollViewDelegate>
 
 @optional
 
 // Display customization
 
 - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
 - (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
 - (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
 - (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0);
 - (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
 - (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
 
 // Variable height support
 
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
 - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
 
 // Section header & footer information. Views are preferred over title should you decide to provide both
 
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
 - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;   // custom view for footer. will be adjusted to default or specified footer height
 
 // Accessories (disclosures).
 
 - (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath NS_DEPRECATED_IOS(2_0, 3_0);
 - (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
 
 // Selection
 
 // -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
 // Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
 - (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
 - (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
 - (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0);
 
 // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
 - (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
 - (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);
 // Called after the user changes the selection.
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
 - (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);
 
 // Editing
 
 // Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
 - (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
 - (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);
 
 // Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
 - (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;
 
 // The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
 - (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath;
 - (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath;
 
 // Moving/reordering
 
 // Allows customization of the target row for a particular row as it is being moved/reordered
 - (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
 
 // Indentation
 
 - (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath; // return 'depth' of row for hierarchies
 
 // Copy/Paste.  All three methods must be implemented by the delegate.
 
 - (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(5_0);
 - (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender NS_AVAILABLE_IOS(5_0);
 - (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender NS_AVAILABLE_IOS(5_0);
 
 @end

*/