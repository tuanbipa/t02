//
//  Common.h
//  SmartPlan
//
//  Created by Huy Le on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Strings.h"
#import "Colors.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

extern void addRoundedRectToPath(CGContextRef context, CGRect rect,float ovalWidth,float ovalHeight);
extern void fillRoundedRect (CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);
extern void strokeRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight);
extern void gradientRoundedRect(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight, CGFloat components[], CGFloat locations[], size_t num_locations);
extern void gradientRect(CGContextRef context, CGRect rect, CGFloat components[], CGFloat locations[], size_t num_locations);

extern BOOL _isiPad;
extern BOOL _versionUpgrade;
extern BOOL _dbUpgrade;
extern BOOL _firstLaunch;

#define ToodledoAppID @"SmartCal"
#define ToodledoAppToken @"api4ce4d580c343e"

#define kTransitionDuration	0.5
#define kInfoViewAnimationKey @"infoViewAnimation"
#define kTimerViewAnimationKey @"timerViewAnimation"

#define kMaxIdleTimeSeconds 10.0

#define MAX_FAST_SCHEDULE_TASKS 30

#define LONG_TAP_DURATION 0.1

#define BOX_FULL_WIDTH 300
#define BOX_HALF_WIDTH 135
#define BOX_GROUP_HEIGHT 50
#define BOX_HEIGHT 40
#define BOX_EXPANDED_HEIGHT 95
#define BOX_EXPANDED_HALF_HEIGHT 50
#define BOX_PAD_HEIGHT 5
#define BOX_PAD_WIDTH 10
//#define SPACE_PAD 4

#define SPACE_PAD 4

//SmartList Task Box
#define TASK_FULL_WIDTH 314
//#define TASK_HEIGHT 30
//#define TASK_HEIGHT 38
#define TASK_HEIGHT 55
#define TASK_PAD_HEIGHT 2
#define TASK_PAD_WIDTH 10
//#define TASK_PAD_WIDTH 20
#define PLAN_PAD_WIDTH 0
#define TASK_CHECK_PAD_WIDTH 20
#define PLAN_EXPAND_WIDTH 30
#define TASK_INDENT_WIDTH 20

#define TAB_WIDTH 50
#define TAB_HEIGHT 70

#define DUE_SIZE 22
#define PIN_SIZE 14
//#define ALERT_SIZE 10
#define ALERT_SIZE 18
#define FLAG_SIZE 18
#define HAND_SIZE 16
#define LINK_SIZE 16
#define REPEAT_SIZE 13

#define PAD_WIDTH 10
#define SCROLL_CHECK_HEIGHT 30
#define SEPARATE_OFFSET 10
#define SEPARATE_ANIMATION_DURATION_SECONDS 0.1 
#define ZOOM_ANIMATION_DURATION_SECONDS 0.1
#define EXCHANGE_FRAME_ANIMATION_DURATION_SECONDS 0.3 

#define ADE_VIEW_HEIGHT 40

#define TIME_LINE_PAD 5
#define LEFT_MARGIN 3
#define TIME_SLOT_HEIGHT 24
#define CALENDAR_BOX_ALIGNMENT 100

//#define PROJECT_BOX_HEIGHT 126
#define PROJECT_BOX_HEIGHT 100
#define PROJECT_BOX_WIDTH 145
#define PROJECT_BOX_TEXT_HEIGHT 40

#define PLAN_HEADER_HEIGHT 30

#define GOAL_HEADER_HEIGHT 30
#define GOAL_SETTING_WIDTH 160
#define GOAL_WIDTH 80

#define HEAD_SIZE 40
#define SHADOW_PAD 2

#define HASHMARK_WIDTH 16
#define HASHMARK_HEIGHT 16

#define HASHMARK_TOP_MARGIN 12
#define HASHMARK_BETWEEN_SPACE 6

#define TARGET_WORK_BALANCE 40
#define DEFAULT_WORK_BALANCE 10 
#define DEFAULT_ESTIMATED_HOURS 80 
#define DEFAULT_TASK_DURATION 1800

#define MONTHVIEW_WIDTH 336
#define LISTVIEW_WIDTH (480 - MONTHVIEW_WIDTH)
#define MONTH_TITLE_HEIGHT 26
#define DAY_TITLE_HEIGHT 16
#define WEEKVIEW_TITLE_HEIGHT 40
#define WEEKVIEW_ADE_HEIGHT 40
#define WEEKVIEW_CELL_WIDTH 68
#define WEEKVIEW_FREETIME_WIDTH 10
#define MONTHVIEW_FREETIME_WIDTH 10

#define MINI_MONTH_HEADER_HEIGHT (_isiPad?100:60)
#define MINI_MONTH_WEEK_HEADER_WIDTH 28

#define MINI_BAR_HEIGHT 20

#define MAX_LAYOUT_NUM 30

#define PROJECT_COLOR_NUM 32

//*** planner section ***
// width of timeline title
#define TIMELINE_TITLE_WIDTH 40.0
// end planner section

#define ANCHOR_CHARACTER @"\U00002693"

//#define URL_HELP            @"http://www.leftcoastlogic.com/smartday/for-iphone/guide/"
#define URL_HELP_iPhone     @"http://www.leftcoastlogic.com/smartday/for-ios/iphone-guide/"
#define URL_HELP_iPad       @"http://www.leftcoastlogic.com/smartday/for-ios/ipad-guide/"
#define URL_ABOUTUS			@"http://www.leftcoastlogic.com/sp/aboutus"
#define URL_ALSOLCL			@"http://www.leftcoastlogic.com/lclproducts/"
#define URL_SYNC            @"http://www.leftcoastlogic.com/smartday/synchronizing/"

typedef enum
{
    DO_TODAY = 0,
    DO_NEXT_WEEK,
    DO_NEXT_MONTH,
    DO_ANYTIME
} QuickAddOption;

typedef enum
{
	BUSY_NO = 0,
	BUSY_CAL_REFRESH_TASKLIST = 1,
	BUSY_CAL_REFRESH_CALENDAR = 2,
	BUSY_WEEKPLANNER_INIT_CALENDAR = 4,
	BUSY_TASK_LAYOUT_SUBSET = 8,
	BUSY_TASK_LAYOUT = 16,
	BUSY_TASK_SCHEDULE = 32,
	BUSY_TASK_SORT_ORDER = 64,
	BUSY_EK_SYNC = 128,
	BUSY_TD_SYNC = 256,
    BUSY_SDW_SYNC = 512,
    BUSY_REMINDER_SYNC = 1024,
    BUSY_SEARCH_LOCATION = 2048
	
} BusyCode;

typedef enum 
{
	SYNC_MANUAL_2WAY, //sync 2 ways manually via menu
    SYNC_MANUAL_2WAY_BACK,
	SYNC_AUTO_1WAY,
    SYNC_AUTO_2WAY, //sync 2 ways when start-up and auto-sync is on
    SYNC_MANUAL_1WAY_TD2SD,
    SYNC_MANUAL_1WAY_mSD2SD,
    SYNC_MANUAL_1WAY_SD2mSD   
} SyncMode;

typedef enum 
{
	TYPE_TASK,
	TYPE_GROUP,
	TYPE_SUBTASK,
	TYPE_TBD,
	TYPE_EVENT,
	TYPE_ADE,
	TYPE_RE_DELETED_EXCEPTION,
	TYPE_SHOPPING_ITEM,
    TYPE_NOTE
} TaskType;

typedef enum 
{
	TASK_STATUS_NONE,
	TASK_STATUS_ACTIVE,
	TASK_STATUS_INPROGRESS,
	TASK_STATUS_DONE,
	TASK_STATUS_INTERRUPT,
	TASK_STATUS_TBD_INVALID,
	TASK_STATUS_TBD_DURATION_CHANGED,
	TASK_STATUS_INITIAL_ACTIVE,
	TASK_STATUS_INITIAL_INPROGRESS,
	TASK_STATUS_PINNED, //shopping list 'as needed'
	TASK_STATUS_DELETED
} TaskStatus;

typedef enum
{
	TASK_EXTRA_STATUS_NONE,
    TASK_EXTRA_STATUS_SHARED = 1,
    TASK_EXTRA_STATUS_ANCHORED = 2,
    TASK_EXTRA_STATUS_MEETING_INVITED = 4,
    TASK_EXTRA_STATUS_ACCEPTED = 8
} TaskExtraStatus;

typedef enum
{
    LINK_STATUS_NONE,
    LINK_STATUS_DELETED
} TaskLinkStatus;

typedef enum
{
    URL_STATUS_NONE,
    URL_STATUS_DELETED
} URLStatus;

typedef enum
{
    COMMENT_STATUS_NONE,
    COMMENT_STATUS_UNREAD,
    COMMENT_STATUS_DELETED
} CommentStatus;

typedef enum
{
    COMMENT_TYPE_ITEM = 0,
    COMMENT_TYPE_PROJECT
} CommentType;

typedef enum
{
    ASSET_ITEM = 0,
    ASSET_URL
} AssetType;

typedef enum
{
    TASK_CREATE,
    TASK_UPDATE,
    TASK_DELETE
} TaskAction;

typedef enum
{
    SOURCE_NONE,
    SOURCE_SMARTLIST,
    SOURCE_CATEGORY,
    SOURCE_NOTE,
    SOURCE_FOCUS,
    SOURCE_PREVIEW,
    SOURCE_CALENDAR,
    SOURCE_TIMER,
    SOURCE_PLANNER_CALENDAR
} TaskListSource;

typedef enum {
    TASK_TIMER_STATUS_NONE,
    TASK_TIMER_STATUS_START, 
    TASK_TIMER_STATUS_PAUSE,
    TASK_TIMER_STATUS_INTERRUPT
} TimerStatus;

typedef enum 
{
	PROJECT_STATUS_NONE,
	PROJECT_STATUS_DELETED,
	PROJECT_STATUS_INVISIBLE,
    PROJECT_STATUS_TRANSPARENT
} ProjectStatus;

typedef enum
{
	PROJECT_EXTRA_STATUS_NONE,
    PROJECT_EXTRA_STATUS_SHARED,
    PROJECT_EXTRA_STATUS_OWNER,
} ProjectExtraStatus;

typedef enum
{
    CATEGORY_SOURCE_LOCAL,
    CATEGORY_SOURCE_SDW,
    CATEGORY_SOURCE_ICAL,
    CATEGORY_SOURCE_REMINDER
} CategorySource;

typedef enum 
{
	TASK_FILTER_ALL,
	TASK_FILTER_RECURRING,
	TASK_FILTER_ACTIVE,
	TASK_FILTER_INACTIVE,
	TASK_FILTER_DUE,
	TASK_FILTER_STAR,
	TASK_FILTER_TOP,
	TASK_FILTER_GLOBAL,
    TASK_FILTER_DONE,
    TASK_FILTER_PINNED,
    TASK_FILTER_LONG,
    TASK_FILTER_SHORT
} TaskTypeFilter;

typedef enum
{
	NOTE_FILTER_ALL,
    NOTE_FILTER_CURRENT,
    NOTE_FILTER_WEEK
} NoteTypeFilter;

typedef enum 
{
	TAB_FILTER_ALL,
	TAB_FILTER_EVENT,
	TAB_FILTER_TASK,
	TAB_FILTER_NOTE,
} TabFilter;

typedef enum 
{
	TYPE_PLAN,
	TYPE_LIST
} ProjectType;

typedef enum
{
    ACTION_ITEM_EDIT,
    ACTION_NOTE_EDIT,
    ACTION_TASK_EDIT,
    ACTION_CATEGORY_EDIT
    
} MenuAction;

typedef enum 
{
	PROJECT_EDIT_STYLE,
	PROJECT_EDIT_NAME,
	PROJECT_EDIT_COLOR,
	PROJECT_EDIT_START,
	PROJECT_EDIT_DEADLINE,
	PROJECT_EDIT_ESTIMATED_HOURS,
	PROJECT_EDIT_WORK_BALANCE,
	PROJECT_EDIT_TARGET_WORK_BALANCE,
	PROJECT_EDIT_END
} ProjectEdit;

typedef enum 
{
	TASK_EDIT_DEADLINE = PROJECT_EDIT_END + 1,
	TASK_EDIT_START,
    TASK_EDIT_END,
    TASK_EDIT_UNTIL
} TaskEdit;

typedef enum 
{
	EVENT_MAPPING_EDIT,
	TASK_MAPPING_EDIT
} MappingEdit;

typedef enum 
{
	SETTING_EDIT_DEFAULT_DURATION,
	SETTING_EDIT_MIN_SPLIT_SIZE,
    SETTING_EDIT_MUSTDO_DAYS
} SettingEdit;

typedef enum 
{
	SELECTION_SINGLE,
	SELECTION_MULTI
} SelectionMode;

typedef enum 
{
	TIMER_RECOVER_ENABLED,
	TIMER_RECOVER_DISABLED
} TimerRecover;

typedef enum 
{
	SOUND_TIMER_ON,
	SOUND_TIMER_OFF,
	SOUND_START,
	SOUND_PAUSE,
	SOUND_STOP,
	SOUND_REPORT,
    SOUND_ALARM
} SoundType;

typedef enum 
{
	GOAL_SCALE_WEEK,
	GOAL_SCALE_MONTH
} GoalScale;

typedef enum 
{
	PLAN_SCALE_WEEK,	
	PLAN_SCALE_QUATER,
	PLAN_SCALE_6MONTH
} PlanScale;

typedef enum 
{
	REPEAT_DAILY,
	REPEAT_WEEKLY,
	REPEAT_MONTHLY,
	REPEAT_YEARLY
} RepeatType;

typedef enum 
{
	REPEAT_FROM_DUE,
	REPEAT_FROM_COMPLETION
} RepeatFrom;

typedef enum 
{
	ON_SUNDAY = 1,
	ON_MONDAY = 2,
	ON_TUESDAY = 4,
	ON_WEDNESDAY = 8,
	ON_THURSDAY = 16,
	ON_FRIDAY = 32,
	ON_SATURDAY = 64
} RepeatWeekOption;

typedef enum 
{
	BY_DAY_OF_MONTH,
	BY_DAY_OF_WEEK
} RepeatMonthOption;

typedef enum 
{
	SYNC_2WAY = 0,
	SYNC_IMPORT,
	SYNC_EXPORT
} SyncDirection;

typedef enum 
{
	ICON_CIRCLE = 0,
	ICON_RECT,
    ICON_SQUARE,
    ICON_ROUNDED_SQUARE,
	ICON_LIST,
    ICON_TASK,
    ICON_NOTE,
    ICON_EVENT,
    ICON_ANCHORED
} IconType;

typedef enum
{
    LIST_FOCUS = 0,
    LIST_BY_DATE,
    LIST_BY_TYPE,
    LIST_BY_CATEGORY
    
} ListViewOption;

typedef enum
{
    LOCATION_NONE = 0,
    LOCATION_ARRIVE,
    LOCATION_LEAVE
} LocationDataStatus;

typedef struct 
{
	NSInteger sourceIndex;
	NSInteger sourceGroupIndex;
} TaskIndex;

typedef struct 
{
	CGFloat totalDuration;	
	CGFloat actualDuration;
	CGFloat planDuration;
} ProgressInfo;

typedef struct 
{
	CGFloat goal0;	
	CGFloat goal1;
	CGFloat goal2;
	CGFloat goal3;	
	CGFloat goal4;
	CGFloat goal5;
} GoalInfo;

typedef struct 
{
	NSInteger beginHour;	
	NSInteger endHour;
	NSInteger beginMinute;	
	NSInteger endMinute;
} WorkingTimeInfo;

typedef struct 
{
	CGFloat progress;	
	NSInteger doneTotal;
	NSInteger total;
	NSInteger totalDuration;
} PlanInfo;

@interface Common : NSObject {
}
/*
+ (NSInteger) timeIntervalNoDST:(NSDate *)date sinceDate:(NSDate *)sinceDate;
+ (CGSize) getTimeSize: (CGFloat) size;
+ (NSInteger)getWeekday:(NSDate *)date;
+ (NSInteger)getWeekdayOrdinal:(NSDate *)date;
+ (NSInteger)getHour:(NSDate *)date;
+ (NSInteger)getMinute:(NSDate *)date;
*/

+ (UIButton *)createButton:(NSString *)title 
				buttonType:(UIButtonType)buttonType
					 frame:(CGRect)frame
				titleColor:(UIColor *)titleColor
					target:(id)target
				  selector:(SEL)selector
		  normalStateImage:(NSString *)normalStateImage
		selectedStateImage:(NSString*)selectedStateImage;

+ (NSString *)getDurationString:(NSInteger)value;
+ (NSString *)getTimerDurationString:(NSInteger)value;
+ (UIColor *) getColorByID: (int) colorID colorIndex:(int) colorIndex;
+ (UIColor *) getGoalColor: (int) goal colorIndex:(int) colorIndex;
+ (UIColor *) getShadowColor;
+ (UIColor *) getHighlightColor;
+ (NSComparisonResult)compareDate:(NSDate*) date1 withDate:(NSDate*) date2;
+ (NSComparisonResult)compareDateNoTime:(NSDate*) date1 withDate:(NSDate*) date2;
+ (NSDate *) dateByWeekday:(NSInteger)wkday;
+ (NSDate *) dateByAddNumYear:(NSInteger)argYear toDate:(NSDate *)argDate;
+ (NSDate *) dateByAddNumMonth:(NSInteger)argMonth toDate:(NSDate *)argDate;
+ (NSDate *) dateByAddNumDay:(NSInteger)argDay toDate:(NSDate *)argDate;
+ (NSDate *) dateByAddNumSecond:(NSInteger)argSecond toDate:(NSDate *)argDate;
+ (NSDate *) dateByRoundMinute:(NSInteger)increment toDate:(NSDate *)argDate;
+ (NSDate *)copyTimeFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSDate *)clearTimeForDate:(NSDate *)date;
+ (NSDate *)getEndDate:(NSDate *)date;
+ (NSDate *)dateNoDST:(NSDate *)date;
+ (NSDate *)toDBDate:(NSDate *)localDate;
+ (NSDate *)fromDBDate:(NSDate *)dbDate;
+ (NSInteger)daysBetween:(NSDate *)dt1 sinceDate:(NSDate *)dt2;
+ (NSInteger)timeIntervalNoDST:(NSDate *)date sinceDate:(NSDate *)sinceDate;
+ (NSDate *)getFirstWeekDate:(NSDate *)date mondayAsWeekStart:(BOOL)mondayAsWeekStart;
+ (NSDate *)getLastWeekDate:(NSDate *)date mondayAsWeekStart:(BOOL)mondayAsWeekStart;
+ (NSDate *)getEndWeekDate:(NSDate *)startTime withWeeks:(NSInteger)weeks mondayAsWeekStart:(BOOL)mondayAsWeekStart;
+ (NSDate *)getFirstMonthDate:(NSDate *)startTime;
+ (NSDate *)getFirstYearDate:(NSDate *)startTime;
+ (NSDate *)getEndMonthDate:(NSDate *)startTime withMonths:(NSInteger) months;
+ (NSInteger)getMonth:(NSDate *)date;
+ (NSInteger)getDay:(NSDate *)date;
+ (NSInteger)getHour:(NSDate *)date;
+ (NSInteger)getMinute:(NSDate *)date;
+ (NSInteger)getWeekday:(NSDate *)date;
+ (NSInteger)getWeekday:(NSDate *)date timeZoneID:(NSInteger)timeZoneID;
+ (NSInteger)getWeekdayOrdinal:(NSDate *)date;
+ (NSInteger) getWeeksInMonth:(NSDate *)date;
+ (NSInteger) getWeeksInMonth:(NSDate *)date mondayAsWeekStart:(BOOL)mondayAsWeekStart;
+ (NSInteger) getWeekOfYear:(NSDate *)date;
+ (BOOL)isWeekend:(NSDate *)date;
+ (NSDate *) getDateByFullString:(NSString *)strDate;
+ (NSDate *) getDateByFullString2:(NSString *)strDate;
+ (NSDate *) getDateByString:(NSString *)strDate;
+ (NSString *) getShortDateString:(NSDate *)argDate;
+ (NSString *) getFullDateString:(NSDate *)argDate;
+ (NSString *) getFullDateString2:(NSDate *)argDate;
+ (NSString *) getFullDateString3:(NSDate *)argDate;
+ (NSString *) getFullDateString4:(NSDate *)argDate;
+ (NSString *) getFullDateTimeString:(NSDate *)argDate;
+ (NSString *) getFullDateTimeString2:(NSDate *)argDate;
+ (NSString *) getCalendarDateString:(NSDate *)argDate;
+ (NSString *) getFullTimeString:(NSDate *)argDate;
+ (NSString *) get24TimeString:(NSDate *)argDate;
+ (NSString *) getTimeString:(NSDate *)argDate;
+ (NSString *) getShortTimeString:(NSDate *)argDate;
+ (NSString *) getDateTimeString:(NSDate *)argDate;
+ (NSString *) getMonthYearString:(NSDate *)argDate;
+ (NSString *) getFullMonthYearString:(NSDate *)argDate;
+ (NSString *) getMonthDayString:(NSDate *)argDate;
+ (NSString *) getDayLineString:(NSDate *)argDate;
+ (NSString *) getMonthString:(NSDate *)argDate;
+ (NSString *) getDayString:(NSDate *)argDate;
+ (NSString *) getFullWeekdayString:(NSDate *)argDate;
+ (NSString *) getWeekdayString:(NSDate *)argDate;
+ (NSString *) getNoteTitle:(NSString *)content;
+ (NSString *) toTime12String:(NSString *)time24String;
+ (NSString *)convertWorkingTimeString:(NSString *)time24String;
+ (NSInteger) getSecondsFromTimeZoneID:(NSInteger)tzID;
+ (NSInteger) createTimeZoneIDByOffset:(NSInteger) offset;
+ (CGSize) getTimeSize: (CGFloat) size;
+ (CGSize) getScreenSize;
+ (CGRect) getFrame;
+ (CGFloat) getKeyboardHeight;
+ (UIImage *) takeSnapshot:(UIView *)view size:(CGSize) size;
+ (void) linkAppStore;
+ (void) sortList:(NSMutableArray *)list byKey:(NSString *)key ascending:(BOOL)ascending;
+ (NSArray *) getSortedList:(NSArray *)list byKey:(NSString *)key ascending:(BOOL)ascending;
+ (NSInteger) countLines:(NSString *)text boundWidth:(CGFloat)boundWidth withFont:(UIFont *)withFont;
+ (void)animateGrowViewFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint forView:(UIView *)theView;
+ (void)animateShrinkView:(UIView *)theView toPosition:(CGPoint) thePosition target:(id)target shrinkEnd:(SEL)selector;
+ (BOOL)validateEmail:(NSString *)candidate;
+ (NSString *)md5:(NSString *)str;
+ (NSString *)getFilePath: (NSString *) path;
+ (void) reloadRowOfTable:(UITableView *)tableView row:(NSInteger)row section:(NSInteger)section;

@end

