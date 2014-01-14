//
//  DemoViewController.h
//  KLTileReorderView
//
//  Created by Krypt on 30.03.13.
//  Copyright (c) 2013 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLTileView.h"

@interface DemoViewController : UIViewController<KLTileViewDataSource, KLTileViewDelegate>
{
    KLTileView *tileView;
    NSMutableArray *images;
    
    BOOL editingEnabled;
}

@end
