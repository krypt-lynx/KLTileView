//
// Created by krypt on 31.03.13.
//



#import <Foundation/Foundation.h>


@interface ImagesModel : NSObject
{
    NSMutableArray *images;
}

+ (ImagesModel *)shared;

@end