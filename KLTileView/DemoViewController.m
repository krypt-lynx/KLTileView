//
//  DemoViewController.m
//  KLTileReorderView
//
//  Created by Krypt on 30.03.13.
//  Copyright (c) 2013 home. All rights reserved.
//

#import "DemoViewController.h"
#import <UIKit/UIKit.h>

@interface DemoViewController ()

@end

@implementation DemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization


        NSString *previewsRoot = [[NSBundle mainBundle] pathForResource:@"previews" ofType:@"bundle"];
        NSError *error = nil;
        NSArray *previewPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:previewsRoot error:&error];
        images = [[NSMutableArray arrayWithCapacity:[previewPaths count]] retain];

        for (NSString *fileName in previewPaths)
        {
            NSString *path = [previewsRoot stringByAppendingPathComponent:fileName];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            [images addObject:image];
        }

    }
    return self;
}

- (void) loadView
{
    [super loadView];

    UIBarButtonItem *editBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(switchEditing)] autorelease];
    
    [self.navigationItem setRightBarButtonItem:editBtn];
    
    tileView = [[[KLTileView alloc] init] autorelease];
    tileView.delegate = self;
    tileView.dataSource = self;

    self.view = tileView;

    [tileView reloadData];
}

- (void) switchEditing
{
    editingEnabled = !editingEnabled;
    [tileView setEditing:editingEnabled animated:YES];
}

- (int) tileViewNumberOfCells:(KLTileView *)tileView1
{
    return [images count];
    
    
}

- (KLTileViewCell *) tileView:(KLTileView *)tileView1 cellForIndex:(int)index
{
    KLTileViewCell *cell = [[[KLTileViewCell alloc] init] autorelease];
    [cell setImage:[[[UIImageView alloc] initWithImage:[images objectAtIndex:index]] autorelease]];
    return cell;
}

- (CGSize) tileViewSizeForCells:(KLTileView *)tileView1
{
    return CGSizeMake(80, 80);
}

- (BOOL) tileView:(KLTileView *)tileView1 canEditCellAtIndex:(int)index
{
    return YES; //index != 10;
}

- (void) tileView:(KLTileView *)tileView1 moveCellAtIndex:(int)from toIndex:(int)to
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
