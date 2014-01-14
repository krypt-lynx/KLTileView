//
// Created by krypt on 31.03.13.
//



#import "ImagesModel.h"


@implementation ImagesModel

static ImagesModel* shared = nil;

+ (ImagesModel *)shared;
{
    if (!shared)
        shared = [[[ImagesModel alloc] init] autorelease];

}

- (id) init
{
    if (self = [super init])
    {
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


@end