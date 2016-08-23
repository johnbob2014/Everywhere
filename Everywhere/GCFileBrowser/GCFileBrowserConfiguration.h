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


#define FileActionButtonEdgeLength ([UIScreen mainScreen].bounds.size.width * 0.1)
#define FileActionButtonSize CGSizeMake(FileActionButtonEdgeLength,FileActionButtonEdgeLength)
#define FileActionButtonOffset (FileActionButtonEdgeLength * 0.35)

#define FileActionLabelHeight 20
#define FileActionLabelFont [UIFont bodyFontWithSizeMultiplier:0.6]

#define TextViewHeight 100
#define BottomConstraintConstant (TextViewHeight + 10)
