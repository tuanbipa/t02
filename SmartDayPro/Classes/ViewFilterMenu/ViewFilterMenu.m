//
//  ViewFilterMenu.m
//  SmartDayPro
//
//  Created by Tuan Pham on 6/10/18.
//  Copyright © 2018 Left Coast Logic. All rights reserved.
//

#import "ViewFilterMenu.h"
#import "FontManager.h"

#define CELL_IDENTIFIER @"CELL_IDENTIFIER"

@interface ViewFilterMenu() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *tblView;
@property (nonatomic) TaskListSource currentScreen;

@end

@implementation ViewFilterMenu

- (instancetype)initWithFrame:(CGRect)frame andCurrentScreen:(TaskListSource)screen {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.currentScreen = screen;
        self.backgroundColor = [UIColor clearColor];
        
        self.tblView = [[UITableView alloc] initWithFrame:CGRectMake(8, 0, self.frame.size.width-8, self.frame.size.height)
                                                    style:UITableViewStylePlain];
        self.tblView.backgroundColor = [UIColor clearColor];
        self.tblView.scrollEnabled = NO;
        self.tblView.tableHeaderView = [UIView new];
        self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tblView.frame.size.width, 1)];
        self.tblView.dataSource = self;
        self.tblView.delegate = self;
        [self addSubview:self.tblView];
        [self.tblView release];
        
        self.tblView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    
    return self;
}

#pragma mark - Methods
- (UIColor *)colorIconWithSelected:(BOOL)isSelected {
    return (isSelected ? COLOR_BACKGROUND_ICON_FILTER_SEL : COLOR_ICON_OBJECT_DETAIL);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.listFilters && self.listFilters.count > 0) {
        return self.listFilters.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row < self.listFilters.count) {
        FilterObject *object = (FilterObject *)[self.listFilters objectAtIndex:indexPath.row];
        if (object) {
            cell.imageView.image = [FontManager flowasticImageWithIconName:object.iconName
                                                                   andSize:SIZE_ICON_MENU_FILTER
                                                                 iconColor:[self colorIconWithSelected:object.isSelected]];
            cell.textLabel.text = object.title;
            cell.textLabel.textColor = object.isSelected ? COLOR_BACKGROUND_ICON_FILTER_SEL : [UIColor blackColor];
            cell.accessoryType = object.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.listFilters.count) {
        if (self.currentScreen == SOURCE_SMARTLIST || self.currentScreen == SOURCE_NOTE || self.currentScreen == SOURCE_CATEGORY) {
            for (NSInteger i=0; i<self.listFilters.count; i++) {
                FilterObject *object = (FilterObject *)[self.listFilters objectAtIndex:i];
                if (indexPath.row == i) {
                    object.isSelected = YES;
                }
                else {
                    object.isSelected = NO;
                }
            }
        }
        
        if (self.viewFilterMenuDelegage && [self.viewFilterMenuDelegage respondsToSelector:@selector(didSelectFilterWithFilterType:atScreen:)]) {
            [self.viewFilterMenuDelegage didSelectFilterWithFilterType:indexPath.row atScreen:self.currentScreen];
        }
        
        if (self.currentScreen == SOURCE_SMARTLIST || self.currentScreen == SOURCE_NOTE || self.currentScreen == SOURCE_CATEGORY) {
            [tableView reloadData];
        }
    }
}

@end
