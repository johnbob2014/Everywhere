//
//  GCFileBrowserConfiguration.h
//  Everywhere
//
//  Created by 张保国 on 16/8/13.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#ifndef GCFileBrowserConfiguration_h
#define GCFileBrowserConfiguration_h

#endif /* GCFileBrowserConfiguration_h */

#pragma mark - ContentAttributeDictionary Key

#define kContentName @"kContentName"
#define kContentPath @"kContentPath"
#define kContentIsDirectory @"kContentIsDirectory"
#define kContentSubitemCount @"kContentSubitemCount"
#define kContentAttributesFromFileManager @"kContentAttributesFromFileManager"
#define kContentIsSelected @"kContentIsSelected"

#define kWaitToCopyContentAttributeDictionaryMutableArray @"kWaitToCopyContentAttributeDictionaryMutableArray"
#define kWaitToMoveContentAttributeDictionaryMutableArray @"kWaitToMoveContentAttributeDictionaryMutableArray"


#define FileActionButtonEdgeLength ([UIScreen mainScreen].bounds.size.width * 0.12)
#define FileActionButtonSize CGSizeMake(FileActionButtonEdgeLength,FileActionButtonEdgeLength)
#define FileActionButtonOffset (FileActionButtonEdgeLength * 0.35)

#define TextViewHeight 100
#define BottomConstraintConstant (TextViewHeight + 10)

//#define GCCOLOR_FILES_TITLE [UIColor colorWithRed:0.4 green:0.357 blue:0.325 alpha:1] /*#665b53*/
//#define GCCOLOR_FILES_TITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/
//#define GCCOLOR_FILES_COUNTER [UIColor colorWithRed:0.608 green:0.376 blue:0.251 alpha:1] /*#9b6040*/
//#define GCCOLOR_FILES_COUNTER_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:0.35] /*#ffffff*/
//#define GCCOLOR_FILES_SUBTITLE [UIColor colorWithRed:0.694 green:0.639 blue:0.6 alpha:1] /*#b1a399*/
//#define GCCOLOR_FILES_SUBTITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/
//#define GCCOLOR_FILES_SUBTITLE_VALUE [UIColor colorWithRed:0.694 green:0.639 blue:0.6 alpha:1] /*#b1a399*/
//#define GCCOLOR_FILES_SUBTITLE_VALUE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/
//
//#define GCFONT_FILES_TITLE [UIFont fontWithName:@"HelveticaNeue" size:(ScreenWidth > 375 ? 20.0f : 16.0f)]
//#define GCFONT_FILES_COUNTER [UIFont fontWithName:@"HelveticaNeue-Bold" size:(ScreenWidth > 375 ? 14.0f : 10.0f)]
//#define GCFONT_FILES_SUBTITLE [UIFont fontWithName:@"HelveticaNeue-Bold" size:(ScreenWidth > 375 ? 14.0f : 10.0f)]
//#define GCFONT_FILES_SUBTITLE_VALUE [UIFont fontWithName:@"HelveticaNeue" size:(ScreenWidth > 375 ? 14.0f : 10.0f)]
