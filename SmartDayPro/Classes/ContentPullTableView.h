//
//  ContentPullTableView.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "ContentTableView.h"

@interface ContentPullTableView : ContentTableView<UIScrollViewDelegate>
{
    UIActivityIndicatorView *activityView;
    UIImageView *arrowImage;
    
    BOOL checkForRefresh;
    BOOL reloading;
    BOOL isFlipped;

}

- (void)scrollViewWillBeginDragging;
- (void)scrollViewDidScroll;
- (void)scrollViewDidEndDragging;

@end
