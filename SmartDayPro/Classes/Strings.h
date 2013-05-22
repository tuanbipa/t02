//
//  Common.h
//  SmartPlan
//
//  Created by Huy Le on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark General Text

#define _okText NSLocalizedString(@"_okText" , @"OK")
#define _cancelText NSLocalizedString(@"_cancelText" , @"Cancel")
#define _dontShowText NSLocalizedString(@"_dontShowText" , @"Don't Show")
#define _saveText NSLocalizedString(@"_saveText" , "Save")
#define _titleGuideText NSLocalizedString(@"_titleGuideText" , @"Title                 Tap or Type")
#define _doneText NSLocalizedString(@"_doneText" , @"Done")
#define _scheduledText NSLocalizedString(@"_scheduledText" , @"Scheduled")
#define _gotoDateText NSLocalizedString(@"_gotoDateText" , @"Goto Date")
#define _filterText NSLocalizedString(@"_filterText" , @"Filter")
#define _noFilterText NSLocalizedString(@"_noFilterText" , @"No Filter") 
#define _needText NSLocalizedString(@"_needText" , @"Need") 
#define _resetText NSLocalizedString(@"_resetText" , @"Reset") 
#define _unDoneText NSLocalizedString(@"_unDoneText" , @"UnDone")
#define _pinText NSLocalizedString(@"_pinText" , @"Pin")
#define _unPinText NSLocalizedString(@"_unPinText" , @"UnPin")
#define _unPinAllText NSLocalizedString(@"_unPinAllText" , @"UnPin All")
#define _deleteAllText NSLocalizedString(@"_deleteAllText" , @"Delete All")
#define _moreText NSLocalizedString(@"_moreText" , @"More")
#define _linkMoreText NSLocalizedString(@"_linkMoreText" ,@"")
#define _multiSelectHintText NSLocalizedString(@"_multiSelectHintText" , @"You are now in Multi-select mode.  After selecting multiple items, choose an action from the Menu.")
#define _monthViewHintText NSLocalizedString(@"_monthViewHintText" , @"Busy days are darker than free days.")
#define _rtDoneHintText NSLocalizedString(@"_rtDoneHintText" , @"A new repeating task has been created.")
#define _aboutText NSLocalizedString(@"_aboutText" , @"About")
#define _aboutSCText NSLocalizedString(@"_aboutSCText" , @"About SmartCal")
#define _scGuideText NSLocalizedString(@"_scGuideText" , @"SmartCal Guide")
#define _smartAppsText NSLocalizedString(@"_smartAppsText" , @"SmartApps")
#define _hintText NSLocalizedString(@"_hintText" , @"Hint")
#define _taskText NSLocalizedString(@"_taskText" , @"Task")

#pragma mark CalendarWeekView

#define _monText NSLocalizedString(@"_monText" , @"Mon")
#define _tueText NSLocalizedString(@"_tueText" , @"Tue")
#define _wedText NSLocalizedString(@"_wedText" , @"Wed")
#define _thuText NSLocalizedString(@"_thuText" , @"Thu")
#define _friText NSLocalizedString(@"_friText" , @"Fri")
#define _satText NSLocalizedString(@"_satText" , @"Sat")
#define _sunText NSLocalizedString(@"_sunText" , @"Sun")

#define _mondayText NSLocalizedString(@"_mondayText" , @"")
#define _tuesdayText NSLocalizedString(@"_tuesdayText" , @"")
#define _wednesdayText NSLocalizedString(@"_wednesdayText" , @"")
#define _thursdayText NSLocalizedString(@"_thursdayText" , @"")
#define _fridayText NSLocalizedString(@"_fridayText" , @"")
#define _saturdayText NSLocalizedString(@"_saturdayText" , @"")
#define _sundayText NSLocalizedString(@"_sundayText" , @"")


#pragma mark CalendarViewController

#define _calendarText NSLocalizedString(@"_calendarText" , "Calendar")
#define _syncEventsText NSLocalizedString(@"_syncEventsText" , @"Sync Events")
#define _syncTasksText NSLocalizedString(@"_syncTasksText" , @"Sync Tasks")
#define _syncCompleteText NSLocalizedString(@"_syncCompleteText" , @"Sync Complete")

#pragma mark ShoppingListViewController
#define _checkListText NSLocalizedString(@"_checkListText" , @"Check List")
#define _setAsNeededText NSLocalizedString(@"_setAsNeededText" , @"Set As Needed")

#pragma mark SmartListViewController
#define _tasksText NSLocalizedString(@"_tasksText" , @"Tasks")
#define _viewAllText NSLocalizedString(@"_viewAllText" , @"View All")
#define _byDueText NSLocalizedString(@"_byDueText" , @"by Due")
#define _byRecurringText NSLocalizedString(@"_byRecurringText" , @"by Recurring")
#define _byActiveText NSLocalizedString(@"_byActiveText" , @"by Active")
#define _byInactiveText NSLocalizedString(@"_byInactiveText" , @"by InActive")
#define _byPinnedText NSLocalizedString(@"_byPinnedText" , @"by Pinned")
#define _multiSelectText NSLocalizedString(@"_multiSelectText" , @"Multi-Select")

#define _unSelectText NSLocalizedString(@"_unSelectText" , @"UnSelect")
#define _singleSelectText NSLocalizedString(@"_singleSelectText" , @"Single-Select")

#pragma mark TaskPortraitMovableController
#define _itemDeleteTitle NSLocalizedString(@"_itemDeleteTitle" , @"Item Delete")
#define _itemDeleteText NSLocalizedString(@"_itemDeleteText" , @"Are you sure you want to delete the selected item(s)?")


#pragma mark LandscapeView
#define _weekText NSLocalizedString(@"_weekText" , @"Week")

#pragma mark ProjectDetailTableViewController
#define _colorText NSLocalizedString(@"_colorText" , @"Color")

#pragma mark TaskDetailTableViewController
#define _startText NSLocalizedString(@"_startText" , @"Start")
#define _deadlineText NSLocalizedString(@"_deadlineText" , @"Deadline")
#define _locationGuideText NSLocalizedString(@"_locationGuideText" , @"Location")
#define _15minText NSLocalizedString(@"_15minText" , @"  15'")
#define _1hourText NSLocalizedString(@"_1hourText" , @"   1 hr")
#define _3hourText NSLocalizedString(@"_3hourText" , @"     3 hrs")
#define _durationText NSLocalizedString(@"_durationText" , @"Duration")
#define _noteText NSLocalizedString(@"_noteText" , @"Note")
#define _tagText NSLocalizedString(@"_tagText" , @"Tag")
#define _taskEditTitle NSLocalizedString(@"_taskEditTitle" , @"Task Edit")
#define _projectChangeText NSLocalizedString(@"_projectChangeText" , @"Are you sure to change the project of Task?")
#define _historyText NSLocalizedString(@"_historyText" , @"History")
#define _endText NSLocalizedString(@"_endText" , @"End")
#define _tagGuideText NSLocalizedString(@"_tagGuideText" , @"(Tap here to type)")

#define _dueText NSLocalizedString(@"_dueText" , @"Due")
#define _tomorrowText NSLocalizedString(@"_tomorrowText" , @"Tomorrow")
#define _nextWeekText NSLocalizedString(@"_nextWeekText" , @"Next Week")
#define _oneWeekText NSLocalizedString(@"_oneWeekText" , @"One Week")
#define _noneText NSLocalizedString(@"_noneText" , @"None")

#define _eventText NSLocalizedString(@"_eventText" , @"Event")
#define _repeatText NSLocalizedString(@"_repeatText" , @"Repeat")
#define _untilText NSLocalizedString(@"_untilText" , @"Until")

#define _onText NSLocalizedString(@"_onText" , @"ON")
#define _offText NSLocalizedString(@"_offText" , @"OFF")

#define _changeRETitleText NSLocalizedString(@"_changeRETitleText" , "Change Recurring Event")
#define _changeREInstanceText NSLocalizedString(@"_changeREInstanceText" , "Would you like to change only this event, all events in the series, or this and future events in the series?")

#define _deleteRETitleText NSLocalizedString(@"_deleteRETitleText" , "Delete Recurring Event")
#define _deleteREInstanceText NSLocalizedString(@"_deleteREInstanceText" , "Would you like to delete only this event, all events in the series, or this and future events in the series?")
#define _deleteAllInSeriesText NSLocalizedString(@"_deleteAllInSeriesText", "")

#define _onlyInstanceText NSLocalizedString(@"_onlyInstanceText" , "Only this instance")
#define _allEventsText NSLocalizedString(@"_allEventsText" , "All events in the series")
#define _allFollowingText NSLocalizedString(@"_allFollowingText" , "All following")
#define _alertsText NSLocalizedString(@"_alertsText" , "Alerts")

#define _repeatInstanceDueText NSLocalizedString(@"_repeatInstanceDueText" , "Repeat Instance Due")

#pragma mark WWWTableViewController
#define _titleLocationText NSLocalizedString(@"_titleLocationText" , "Title/Location")
#define _titleGuideWWWText NSLocalizedString(@"_titleGuideWWWText" , "Tap a shortcut, or just type")
#define _whatText NSLocalizedString(@"_whatText" , "What")
#define _whoText NSLocalizedString(@"_whoText" , "Who")
#define _whereText NSLocalizedString(@"_whereText" , "Where")
#define _gotoText NSLocalizedString(@"_gotoText" , "Go to ")
#define _contactText NSLocalizedString(@"_contactText" , "Contact ")
#define _getText NSLocalizedString(@"_getText" , "Get ")
#define _writeToText NSLocalizedString(@"_writeToText" , "Write to ")
#define _meetText NSLocalizedString(@"_meetText" , "Meet " )
#define _deleteText NSLocalizedString(@"_deleteText" , "Delete")
#define _cleanText NSLocalizedString(@"_cleanText" , "Clean")

#pragma mark ContactViewController
#define _contactsText NSLocalizedString(@"_contactsText" , "Contacts")
#define _aText NSLocalizedString(@"_aText" , "A")
#define _bText NSLocalizedString(@"_bText" , "B")
#define _ccText NSLocalizedString(@"_ccText" , "C")
#define _dText NSLocalizedString(@"_dText" , "D")
#define _eText NSLocalizedString(@"_eText" , "E")
#define _fText NSLocalizedString(@"_fText" , "F")
#define _gText NSLocalizedString(@"_gText" , "G")
#define _hText NSLocalizedString(@"_hText" , "H")
#define _iText NSLocalizedString(@"_iText" , "I")
#define _jText NSLocalizedString(@"_jText" , "J")
#define _kText NSLocalizedString(@"_kText" , "K")
#define _lText NSLocalizedString(@"_lText" , "L")
#define _mText NSLocalizedString(@"_mText" , "M")
#define _nText NSLocalizedString(@"_nText" , "N")
#define _oText NSLocalizedString(@"_oText" , "O")
#define _pText NSLocalizedString(@"_pText" , "P")
#define _qText NSLocalizedString(@"_qText" , "Q")
#define _rText NSLocalizedString(@"_rText" , "R")
#define _sText NSLocalizedString(@"_sText" , "S")
#define _tText NSLocalizedString(@"_tText" , "T")
#define _uText NSLocalizedString(@"_uText" , "U")
#define _vText NSLocalizedString(@"_vText" , "V")
#define _wText NSLocalizedString(@"_wText" , "W")
#define _xText NSLocalizedString(@"_xText" , "X")
#define _yText NSLocalizedString(@"_yText" , "Y")
#define _zText NSLocalizedString(@"_zText" , "Z")

#pragma mark ContactManager
#define _nonameText NSLocalizedString(@"_nonameText" , "No Name")

#pragma mark LocationViewController
#define _locationText NSLocalizedString(@"_locationText" , "Location")
#define _sortedByAddressText NSLocalizedString(@"_sortedByAddressText" , "Sort By Address")
#define _sortedByContactText NSLocalizedString(@"_sortedByContactText" , "Sort By Contact")

#pragma mark TaskPortraitViewController
#define _taskMarkDoneTitle NSLocalizedString(@"_taskMarkDoneTitle" , @"Mark done Task")
#define _taskMarkDoneText NSLocalizedString(@"_taskMarkDoneText" , @"Are you sure you want to mark the selected task(s) as Done?")

#define _taskUnMarkDoneTitle NSLocalizedString(@"_taskUnMarkDoneTitle" , @"Un-mark done Task")
#define _taskUnMarkDoneText NSLocalizedString(@"_taskUnMarkDoneText" , @"Are you sure you want to un-mark done the Task?")

#pragma mark SettingTableViewController
#define _settingTitle NSLocalizedString(@"_settingTitle" , @"Settings")

#define _skinText NSLocalizedString(@"_skinText" , @"Skin Style")
#define _appleBlueText NSLocalizedString(@"_appleBlueText" , @"Apple Blue")
#define _blackOpaqueText NSLocalizedString(@"_blackOpaqueText" , @"Black Opaque")
#define _generalText NSLocalizedString(@"_generalText" , @"General")
#define _calendarsText NSLocalizedString(@"_calendarsText" , @"Calendars")

//#define _mondayText NSLocalizedString(@"_mondayText" , @"Monday")
//#define _sundayText NSLocalizedString(@"_sundayText" , @"Sunday")

#define _weekStartText NSLocalizedString(@"_weekStartText" , @"Week Start")
#define _blueText NSLocalizedString(@"_blueText" , @"Blue")
#define _blackText NSLocalizedString(@"_blackText" , @"Black")
#define _weekdayStartText NSLocalizedString(@"_weekdayStartText" , @"Weekday Start")
#define _weekdayEndText NSLocalizedString(@"_weekdayEndText" , @"Weekday End")
#define _weekendStartText NSLocalizedString(@"_weekendStartText" , @"Weekend Start")
#define _weekendEndText NSLocalizedString(@"_weekendEndText" , @"Weekend End")
#define _workingTimeText NSLocalizedString(@"_workingTimeText" , @"Working Time")
#define _weekdayText NSLocalizedString(@"_weekdayText" , @"Weekday")
#define _weekendText NSLocalizedString(@"_weekendText" , @"Weekend")
#define _showInCalendarText NSLocalizedString(@"_showInCalendarText" , @"Show in Calendar")
#define _moveInCalendarText NSLocalizedString(@"_moveInCalendarText" , @"Move in Calendar")
#define _minSplitSizeText NSLocalizedString(@"_minSplitSizeText" , @"Minimum Split Size")
#define _eventSyncText NSLocalizedString(@"_eventSyncText" , @"Event Sync")
#define _autoSyncText NSLocalizedString(@"_autoSyncText" , @"")
#define _timeWindowText NSLocalizedString(@"_timeWindowText" , @"Time Window")
#define _calendarMappingText NSLocalizedString(@"_calendarMappingText" , @"Calendar Mapping")
#define _1WText NSLocalizedString(@"_1WText" , @"1W")
#define _3WText NSLocalizedString(@"_3WText" , @"3W")
#define _3MText NSLocalizedString(@"_3MText" , @"3M")
#define _syncDirectionText NSLocalizedString(@"_syncDirectionText" , @"Sync Direction")
#define _syncText NSLocalizedString(@"_syncText" , @"Sync")

#define _hintsText NSLocalizedString(@"_hintsText" , @"Hints")
#define _confirmText NSLocalizedString(@"_confirmText" , @"Confirm")
#define _deleteWarningText NSLocalizedString(@"_deleteWarningText" , @"Delete Warning")
#define _doneWarningText NSLocalizedString(@"_doneWarningText" , @"Done Warning")

#pragma mark CalendarSelectionTableViewController
#define _iPhoneCalendarsText NSLocalizedString(@"_iPhoneCalendarsText" , @"iPhone Calendars")
#define _plsSelectCalToSyncText NSLocalizedString(@"_plsSelectCalToSyncText" , @"Please select calendars to sync")

#pragma mark SyncMappingTableViewController
#define _iCalMappingHeaderText NSLocalizedString(@"_iCalMappingHeaderText" , @"SC Calendar       iPhone Calendar")
#define _mapAllCalendarsText NSLocalizedString(@"_mapAllCalendarsText" , @"Map All Calendars")

#pragma mark SyncWindow2SettingViewController
#define _syncWindowText NSLocalizedString(@"_syncWindowText" , "Sync Window")
#define _syncFromToText NSLocalizedString(@"_syncFromToText" , "   Sync From               Sync To")
#define _syncFromTo4iPadText NSLocalizedString(@"_syncFromTo4iPadText" , "   Sync From                    Sync To")

#define _thisWeekText NSLocalizedString(@"_thisWeekText" , "This Week")
#define _lastWeekText NSLocalizedString(@"_lastWeekText" , "Last Week")
#define _lastMonthText NSLocalizedString(@"_lastMonthText" , "Last Month")
#define _last3MonthText NSLocalizedString(@"_last3MonthText" , "Last 3 Months")
#define _lastYearText NSLocalizedString(@"_lastYearText" , "Last Year")
#define _allPreviousText NSLocalizedString(@"_allPreviousText" , "All Previous")

#define _nextMonthText NSLocalizedString(@"_nextMonthText" , "Next Month")
#define _next3MonthText NSLocalizedString(@"_next3MonthText" , "Next 3 Months")
#define _nextYearText NSLocalizedString(@"_nextYearText" , "Next Year")
#define _allForwardText NSLocalizedString(@"_allForwardText" , "All Forward")

#define _syncStartText NSLocalizedString(@"_syncStartText" , "Sync Start")
#define _syncEndText NSLocalizedString(@"_syncEndText" , "Sync End")

#pragma mark SyncDirectionTableViewController
#define _2wayText NSLocalizedString(@"_2wayText" , @"Two-Way")
#define _importText NSLocalizedString(@"_importText" , @"Import")
#define _exportText NSLocalizedString(@"_exportText" , @"Export")

#pragma mark DateJumpView
#define _goText NSLocalizedString(@"_goText" , @"Go")
#define _todayText NSLocalizedString(@"_todayText" , @"Today")

#pragma mark ProgressEditViewController
#define _tap2SelectText NSLocalizedString(@"_tap2SelectText" , @"(Tap either Start or End to select)")
#define _progressEditTitle NSLocalizedString(@"_progressEditTitle" , @"Progress Edit")

#pragma mark StartEndPickerViewController
#define _timeEditTitle NSLocalizedString(@"_timeEditTitle" , @"Time Edit")

#pragma mark RepeatTableViewController
#define _dailyText NSLocalizedString(@"_dailyText" , @"Daily")
#define _weeklyText NSLocalizedString(@"_weeklyText" , @"Weekly")
#define _monthlyText NSLocalizedString(@"_monthlyText" , @"Monthly")
#define _yearlyText NSLocalizedString(@"_yearlyText" , @"Yearly")

#define _everyText NSLocalizedString(@"_everyText" , @"every")
#define _dayUnitText NSLocalizedString(@"_dayUnitText" , @"day(s)")
#define _weekUnitText NSLocalizedString(@"_weekUnitText" , @"week(s)")
#define _monthUnitText NSLocalizedString(@"_monthUnitText" , @"month(s)")
#define _yearUnitText NSLocalizedString(@"_yearUnitText" , @"year(s)")
#define _dayOfMonthText NSLocalizedString(@"_dayOfMonthText" , @"Day of Month")
#define _dayOfWeekText NSLocalizedString(@"_dayOfWeekText" , @"Day of Week")

#define _foreverText NSLocalizedString(@"_foreverText" , @"Forever")
#define _onDateText NSLocalizedString(@"_onDateText" , @"On Date")
#define _afterText NSLocalizedString(@"_afterText" , @"after")
#define _timesText NSLocalizedString(@"_timesText" , @"times")
#define _repeatFromDueText NSLocalizedString(@"_repeatFromDueText" , @"Repeat From Due")
#define _repeatFromCompletionText NSLocalizedString(@"_repeatFromCompletionText" , @"Repeat From Completion")
#define _repeatFromDueHintText NSLocalizedString(@"_repeatFromDueHintText" , @"Please select a Due Date first.")

#pragma mark TaskView
#define _hoursText NSLocalizedString(@"_hoursText" , @"hr(s)")

#pragma mark ByLCLViewController
#define _byLCLTitle NSLocalizedString(@"_byLCLTitle" , @"By LCL")

#pragma mark HelpViewController
#define _helpTitle NSLocalizedString(@"_helpTitle" , @"Help")
#define _userGuideText NSLocalizedString(@"_userGuideText" , @"User Guide")

#pragma mark AboutUsViewController
#define _aboutUsTitle NSLocalizedString(@"_aboutUsTitle" , @"About Us")

#pragma mark ReportTableViewController
#define _reportTitle NSLocalizedString(@"_reportTitle" , @"Report")
#define _exportToCSVText NSLocalizedString(@"_exportToCSVText" , @"Export To CSV")
#define _saveSnapshotText NSLocalizedString(@"_saveSnapshotText" , @"Save Snapshot")
#define _mailTitle NSLocalizedString(@"_mailTitle" , @"Mail")

#pragma mark AlertEditViewController
#define _alertEditText NSLocalizedString(@"_alertEditText" , @"Alert Edit")
#define _atTimeText NSLocalizedString(@"_atTimeText" , @"At Time")
#define _beforeDueText NSLocalizedString(@"_beforeDueText" , @"Before Due")
#define _beforeStartText NSLocalizedString(@"_beforeStartText" , @"Before Start")

#pragma mark AlertListViewController
#define _alertListText NSLocalizedString(@"_alertListText" , @"Alert List")
#define _addText NSLocalizedString(@"_addText" , @"Add")
#define _alertText NSLocalizedString(@"_alertText" , @"Alert")
#define _beforeText NSLocalizedString(@"_beforeText" , @"before")
#define _taskAlertHintText NSLocalizedString(@"_taskAlertHintText" , @"Please select Due first to enable to define Alerts. Alert time will be relative to Due.")

#pragma mark AlertSelectionTableViewController
#define _15minBeforeText NSLocalizedString(@"_15minBeforeText" , @"15 minutes before")
#define _30minBeforeText NSLocalizedString(@"_30minBeforeText" , @"30 minutes before")
#define _45minBeforeText NSLocalizedString(@"_45minBeforeText" , @"45 minutes before")
#define _1hourBeforeText NSLocalizedString(@"_1hourBeforeText" , @"1 hour before")
#define _2hourBeforeText NSLocalizedString(@"_2hourBeforeText" , @"2 hours before")
#define _3hourBeforeText NSLocalizedString(@"_3hourBeforeText" , @"3 hours before")
#define _1dayBeforeText NSLocalizedString(@"_1dayBeforeText" , @"1 day before")
#define _2dayBeforeText NSLocalizedString(@"_2dayBeforeText" , @"2 days before")
#define _onDateOfEventText NSLocalizedString(@"_onDateOfEventText" , @"On date of Event")
#define _onDueOfTaskText NSLocalizedString(@"_onDueOfTaskText" , @"On due of Task")

#define _8hoursAfterText NSLocalizedString(@"_8hoursAfterText" , @"")
#define _0hoursBeforeText NSLocalizedString(@"_0hoursBeforeText" , @"")
#define _4hoursBeforeText NSLocalizedString(@"_4hoursBeforeText" , @"")
#define _8hoursBeforeText NSLocalizedString(@"_8hoursBeforeText" , @"")
#define _12hoursBeforeText NSLocalizedString(@"_12hoursBeforeText" , @"")
#define _16hoursBeforeText NSLocalizedString(@"_16hoursBeforeText" , @"")
#define _1dot5daysBeforeText NSLocalizedString(@"_1dot5daysBeforeText" , @"")
#define _2dot5daysBeforeText NSLocalizedString(@"_2dot5daysBeforeText" , @"")

#pragma mark FilterView

#define _nameText NSLocalizedString(@"_nameText" , "Name")
#define _typeText NSLocalizedString(@"_typeText" , "Type")
#define _applyText NSLocalizedString(@"_applyText" , "Apply")

#pragma mark Toodledo Sync
#define _toodledoSyncText NSLocalizedString(@"_toodledoSyncText" , "")
#define _toodledoAccountText NSLocalizedString(@"_toodledoAccountText" , "")
#define _emailText NSLocalizedString(@"_emailText" , "")
#define _passwordText NSLocalizedString(@"_passwordText" , "")
#define _checkValidityText NSLocalizedString(@"_checkValidityText" , "")
#define _accountValidText NSLocalizedString(@"_accountValidText" , "")
#define _accountInvalidText NSLocalizedString(@"_accountInvalidText" , "")
#define _errorText NSLocalizedString(@"_errorText" , "")
#define _syncErrorText NSLocalizedString(@"_syncErrorText" , "")
#define _noInternetConnectionText NSLocalizedString(@"_noInternetConnectionText" , "")

#define _newCalendarText NSLocalizedString(@"_newCalendarText" , "")
#define _calendarDeleteTitle NSLocalizedString(@"_calendarDeleteTitle" , "")
#define _calendarDeleteText NSLocalizedString(@"_calendarDeleteText" , "")
#define _eventSyncHintText NSLocalizedString(@"_eventSyncHintText" , "")
#define _taskSyncHintText NSLocalizedString(@"_taskSyncHintText" , "")
#define _toodledoSyncingText NSLocalizedString(@"_toodledoSyncingText", "")
#define _icalSyncingText NSLocalizedString(@"_icalSyncingText", "")
#define _editText NSLocalizedString(@"_editText", "")
#define _projectDeleteText NSLocalizedString(@"_projectDeleteText", "")
#define _projectDoneText NSLocalizedString(@"_projectDoneText", "")
#define _projectText NSLocalizedString(@"_projectText", "")
#define _projectsText NSLocalizedString(@"_projectsText", "")
#define _noMatchEventCalendarText NSLocalizedString(@"_noMatchEventCalendarText", "")
#define _noMatchTaskFolderText NSLocalizedString(@"_noMatchTaskFolderText", "")
#define _toMatchEventCalendarText NSLocalizedString(@"_toMatchEventCalendarText", "")
#define _toMatchTaskCalendarText NSLocalizedString(@"_toMatchTaskCalendarText", "")
#define _matchEventCalendarText NSLocalizedString(@"_matchEventCalendarText", "")
#define _matchTaskCalendarText NSLocalizedString(@"_matchTaskCalendarText", "")
#define _quickAddNewTask NSLocalizedString(@"_quickAddNewTask", "")
#define _projectDetailHintText NSLocalizedString(@"_projectDetailHintText", "")
#define _cannotDeleteDefaultProjectText NSLocalizedString(@"_cannotDeleteDefaultProjectText", "")
#define _cannotDeleteExternalProjectText NSLocalizedString(@"_cannotDeleteExternalProjectText", "")
#define _closeText NSLocalizedString(@"_closeText", "")
#define _showText NSLocalizedString(@"_showText", "")
#define _hideText NSLocalizedString(@"_hideText", "")
#define _activeText NSLocalizedString(@"_activeText", "")
#define _topText NSLocalizedString(@"_topText", "")
#define _starText NSLocalizedString(@"_starText", "")
#define _allText NSLocalizedString(@"_allText", "")
#define _newTaskPlaceText NSLocalizedString(@"_newTaskPlaceText", "")
#define _bottomText NSLocalizedString(@"_bottomText", "")
#define _toodledoFoldersText NSLocalizedString(@"_toodledoFoldersText", "")
#define _itemHideTitle NSLocalizedString(@"_itemHideTitle", "")
#define _itemHideText NSLocalizedString(@"_itemHideText", "")
#define _gtdoText NSLocalizedString(@"_gtdoText", "")
#define _deleteAllConfirmationText NSLocalizedString(@"_deleteAllConfirmationText", "")
#define _1stTimeEventSyncHintText NSLocalizedString(@"_1stTimeEventSyncHintText", "")
#define _startOnText NSLocalizedString(@"_startOnText", "")
#define _dueByText NSLocalizedString(@"_dueByText", "")
#define _doOnText NSLocalizedString(@"_doOnText", "")
#define _dueTasksText NSLocalizedString(@"_dueTasksText", "")
#define _startTasksText NSLocalizedString(@"_startTasksText", "")
#define _allDayText NSLocalizedString(@"_allDayText", "")
#define _changeOrderText NSLocalizedString(@"_changeOrderText", "")
#define _convertIntoEventText NSLocalizedString(@"_convertIntoEventText", "")
#define _moveToPastText NSLocalizedString(@"_moveToPastText", "")
#define _warningText NSLocalizedString(@"_warningText", "")
#define _presetsText NSLocalizedString(@"_presetsText", "")
#define _customText NSLocalizedString(@"_customText", "")
#define _tagListText NSLocalizedString(@"_tagListText", "")
#define _tapToAddTagText NSLocalizedString(@"_tapToAddTagText", "")
#define _normalText NSLocalizedString(@"_normalText", "")
#define _listText NSLocalizedString(@"_listText", "")
#define _titleText NSLocalizedString(@"_titleText", "")
#define _showAllText NSLocalizedString(@"_showAllText", "")
#define _hideAllText NSLocalizedString(@"_hideAllText", "")
#define _showProjectsText NSLocalizedString(@"_showProjectsText", "")
#define _clearAllText NSLocalizedString(@"_clearAllText", "")
#define _categoryText NSLocalizedString(@"_categoryText", "")
#define _categoriesText NSLocalizedString(@"_categoriesText", "")
#define _readmeText NSLocalizedString(@"_readmeText", "")
#define _workingTimeHintText NSLocalizedString(@"_workingTimeHintText", "")
#define _toodledoSignupText NSLocalizedString(@"_toodledoSignupText", "")
#define _toodledoSignupHintText NSLocalizedString(@"_toodledoSignupHintText", "")
#define _toodledoSignupURLText NSLocalizedString(@"_toodledoSignupURLText", "")
#define _landscapeModeEnableText NSLocalizedString(@"_landscapeModeEnableText", "")
#define _starTabHintText NSLocalizedString(@"_starTabHintText", "")
#define _gtdoTabHintText NSLocalizedString(@"_gtdoTabHintText", "")
#define _tagHintText NSLocalizedString(@"_tagHintText", "")
#define _loadingText NSLocalizedString(@"_loadingText", "")
#define _deleteCategoryWarningText NSLocalizedString(@"_deleteCategoryWarningText", "")
#define _keepDataText NSLocalizedString(@"_keepDataText", "")
#define _yesText NSLocalizedString(@"_yesText", "")
#define _noText NSLocalizedString(@"_noText", "")
#define _tabBarText NSLocalizedString(@"_tabBarText", "")
#define _textText NSLocalizedString(@"_textText", "")
#define _iconText NSLocalizedString(@"_iconText", "")
#define _navigationText NSLocalizedString(@"_navigationText", "")
#define _categoryNameExistsText NSLocalizedString(@"_categoryNameExistsText", "")

#define _v3_1_welcomeTitle NSLocalizedString(@"_v3_1_welcomeTitle", "")
#define _v3_1_welcomeText NSLocalizedString(@"_v3_1_welcomeText", "")
#define _v3_2_welcomeTitle NSLocalizedString(@"_v3_2_welcomeTitle", "")
#define _v3_2_welcomeText NSLocalizedString(@"_v3_2_welcomeText", "")

#define _whatNewText NSLocalizedString(@"_whatNewText", "")
#define _seeDetails NSLocalizedString(@"_seeDetails", "")
#define _paidUpgradeText NSLocalizedString(@"_paidUpgradeText", "")

#define _upgradeText NSLocalizedString(@"_upgradeText", "")
#define _laterText NSLocalizedString(@"_laterText", "")
#define _getNowText NSLocalizedString(@"_getNowText", "")
#define _scPaidOfferText NSLocalizedString(@"_scPaidOfferText", "")
#define _backupText NSLocalizedString(@"_backupText", "")
#define _databaseText NSLocalizedString(@"_databaseText", "")
#define _transparentText NSLocalizedString(@"_transparentText", "")
#define _transparentHintText NSLocalizedString(@"_transparentHintText", "")
#define _syncNowText NSLocalizedString(@"_syncNowText", "")
#define _syncNowTitle NSLocalizedString(@"_syncNowTitle", "")
#define _showHideCategoryText NSLocalizedString(@"_showHideCategoryText", "")

#define _restoreDBTitle NSLocalizedString(@"_restoreDBTitle", "")
#define _restoreDBText NSLocalizedString(@"_restoreDBText", "")
#define _restoreDBFinishedTitle NSLocalizedString(@"_restoreDBFinishedTitle", "")
#define _restoreDBFinishedText NSLocalizedString(@"_restoreDBFinishedText", "")

#define _sdwSyncText NSLocalizedString(@"_sdwSyncText", "")
#define _mySDAccountText NSLocalizedString(@"_mySDAccountText", "")
#define _signupText NSLocalizedString(@"_signupText", "")
#define _sdwSyncingText NSLocalizedString(@"_sdwSyncingText", "")
#define _sdwAccountValidText NSLocalizedString(@"_sdwAccountValidText", "")
#define _sdwAccountInvalidText NSLocalizedString(@"_sdwAccountInvalidText", "")
#define _sdwSignupSuccessText NSLocalizedString(@"_sdwSignupSuccessText", "")
#define _sdwSignupFailedText NSLocalizedString(@"_sdwSignupFailedText", "")
#define _sdwSyncFailedText NSLocalizedString(@"_sdwSyncFailedText", "")
#define _emailInvalidText NSLocalizedString(@"_emailInvalidText", "")
#define _wifiConnectionOffText NSLocalizedString(@"_wifiConnectionOffText", "")

#define _notePlaceHolderText NSLocalizedString(@"_notePlaceHolderText", "")
#define _linksText NSLocalizedString(@"_linksText", "")

#define _addNewLinkText NSLocalizedString(@"_addNewLinkText", "")

#define _focusText NSLocalizedString(@"_focusText", "")
#define _listByDateText NSLocalizedString(@"_listByDateText", "")
#define _listByTypeText NSLocalizedString(@"_listByTypeText", "")
#define _listByCategoryText NSLocalizedString(@"_listByCategoryText", "")

#define _copyLinkText NSLocalizedString(@"_copyLinkText", "")
#define _pasteLinkText NSLocalizedString(@"_pasteLinkText", "")
#define _editLinksText NSLocalizedString(@"_editLinksText", "")

#define _newDeadlineCreatedText NSLocalizedString(@"_newDeadlineCreatedText", "")
#define _newDateIsText NSLocalizedString(@"_newDateIsText", "")
#define _noteAssociatedText NSLocalizedString(@"_noteAssociatedText", "")
#define _visitText NSLocalizedString(@"_visitText", "")

#define _newPresetText NSLocalizedString(@"_newPresetText", "")
#define _presetText NSLocalizedString(@"_presetText", "")
#define _mustDoRangeText NSLocalizedString(@"_mustDoRangeText", "")

#define _dateText NSLocalizedString(@"_dateText", "")
#define _backText NSLocalizedString(@"_backText", "")

#define _eventsText NSLocalizedString(@"_eventsText", "")
#define _notesText NSLocalizedString(@"_notesText", "")

#define _smartTasksText NSLocalizedString(@"_smartTasksText", "")

#define _noADETodayText NSLocalizedString(@"_noADETodayText", "")
#define _noNoteTodayText NSLocalizedString(@"_noNoteTodayText", "")
#define _mustdoText NSLocalizedString(@"_mustdoText", "")

#define _syncMySmartDayText NSLocalizedString(@"_syncMySmartDayText", "")
#define _syncToodledoText NSLocalizedString(@"_syncToodledoText", "")

#define _calendarNameDuplicationText NSLocalizedString(@"_calendarNameDuplicationText", "")
#define _duplicationResolveSuggestionText NSLocalizedString(@"_duplicationResolveSuggestionText", "")
#define _proceedText NSLocalizedString(@"_proceedText", "")

#define _mergeText NSLocalizedString(@"_mergeText", "")
#define _defaultProjectText NSLocalizedString(@"_defaultProjectText", "")
#define _defaultCategoryText NSLocalizedString(@"_defaultCategoryText", "")

#define _iOSCalSyncText NSLocalizedString(@"_iOSCalSyncText", "")
#define _mySmartDayToodledoSyncText NSLocalizedString(@"_mySmartDayToodledoSyncText", "")
#define _mySmartDayText NSLocalizedString(@"_mySmartDayText", "")
#define _toodledoText NSLocalizedString(@"_toodledoText", "")

#define _descriptionText NSLocalizedString(@"_descriptionText", "")

#define _convertREIntoTaskConfirmation NSLocalizedString(@"_convertREIntoTaskConfirmation", "")
#define _convertIntoEventConfirmation NSLocalizedString(@"_convertIntoEventConfirmation", "")
#define _convertIntoTaskConfirmation NSLocalizedString(@"_convertIntoTaskConfirmation", "")
#define _convertIntoSTaskConfirmation NSLocalizedString(@"_convertIntoSTaskConfirmation", "")

#define _linkSearchHintText NSLocalizedString(@"_linkSearchHintText", "")

#define _syncSetupText NSLocalizedString(@"_syncSetupText", "")
#define _accountText NSLocalizedString(@"_accountText", "")
#define _verifiedText NSLocalizedString(@"_verifiedText", "")
#define _unverifiedText NSLocalizedString(@"_unverifiedText", "")

#define _replaceDataText NSLocalizedString(@"_replaceDataText", "")
#define _fromSmartDay NSLocalizedString(@"_fromSmartDay", "")
#define _toSmartDay NSLocalizedString(@"_toSmartDay", "")

#define _iOSCalText NSLocalizedString(@"_iOSCalText", "")

#define _mySmartDaySyncHint NSLocalizedString(@"_mySmartDaySyncHint", "")
#define _toodledoSyncHint NSLocalizedString(@"_toodledoSyncHint", "")

#define _syncOffWarningText NSLocalizedString(@"_syncOffWarningText", "")
#define _deleteSyncDuplicationText NSLocalizedString(@"_deleteSyncDuplicationText", "")
#define _deleteSuspectedDuplicationCompleteText NSLocalizedString(@"_deleteSuspectedDuplicationCompleteText", "")
#define _syncAgainText NSLocalizedString(@"_syncAgainText", "")

#define _hintResetCompleteText NSLocalizedString(@"_hintResetCompleteText", "")
#define _mustDoHint NSLocalizedString(@"_mustDoHint", "")

#define _deleteAllMySDDataConfirmation NSLocalizedString(@"_deleteAllMySDDataConfirmation", "")
#define _deleteAllSDDataConfirmation NSLocalizedString(@"_deleteAllSDDataConfirmation", "")

#define _duplicateText NSLocalizedString(@"_duplicateText", "")
#define _doTodayText NSLocalizedString(@"_doTodayText", "")

#define _tabBarAutoHideText NSLocalizedString(@"_tabBarAutoHideText", "")
#define _defaultDurationText NSLocalizedString(@"_defaultDurationText", "")

#define _saveAndMoreText NSLocalizedString(@"_saveAndMoreText", "")

#define _1DayText NSLocalizedString(@"_1DayText", "")
#define _monthText NSLocalizedString(@"_monthText", "")

#define _showMoreText NSLocalizedString(@"_showMoreText", "")
#define _overviewText NSLocalizedString(@"_overviewText", "")
#define _synchronizationText NSLocalizedString(@"_synchronizationText", "")
#define _enableText NSLocalizedString(@"_enableText", "")

#define _confirmSyncOnText NSLocalizedString(@"_confirmSyncOnText", "")
#define _syncWizardText NSLocalizedString(@"_syncWizardText", "")

//#define _goText NSLocalizedString(@"_goText", "")
#define _msdSyncFailed NSLocalizedString(@"_msdSyncFailed", "")
#define _msdBackupFailed NSLocalizedString(@"_msdBackupFailed", "")
#define _msdBackupHint NSLocalizedString(@"_msdBackupHint", "")

#define _mySmartDayDotCom NSLocalizedString(@"_mySmartDayDotCom", "")
#define _others NSLocalizedString(@"_others", "")

#define _syncAtStartUp NSLocalizedString(@"_syncAtStartUp", "")
#define _syncAtStartUpHint NSLocalizedString(@"_syncAtStartUpHint", "")
#define _pushChanges NSLocalizedString(@"_pushChanges", "")
#define _dataRecovery NSLocalizedString(@"_dataRecovery", "")
#define _dataRecoveryHint NSLocalizedString(@"_dataRecoveryHint", "")

#define _multiSourceWarningText NSLocalizedString(@"_multiSourceWarningText", "")
#define _noSourceFoundText NSLocalizedString(@"_noSourceFoundText", "")
#define _sourceLocalText NSLocalizedString(@"_sourceLocalText", "")
#define _sourceiCloudText NSLocalizedString(@"_sourceiCloudText", "")
#define _dontSyncNewCalendars NSLocalizedString(@"_dontSyncNewCalendars", "")
#define _ekFatalError NSLocalizedString(@"_ekFatalError", "")
#define _contactLCLHelp NSLocalizedString(@"_contactLCLHelp", "")
#define _chooseSyncSourceText NSLocalizedString(@"_chooseSyncSourceText", "")

#define _hideFutureTasks NSLocalizedString(@"_hideFutureTasks", "")

#define _infoText NSLocalizedString(@"_infoText", "")

#define _seekOrCreate NSLocalizedString(@"_seekOrCreate", "")
#define _createNew NSLocalizedString(@"_createNew", "")
#define _searchResult NSLocalizedString(@"_searchResult", "")

#define _inProgressTasksText NSLocalizedString(@"_inProgressTasksText", "")
#define _activeTasksText NSLocalizedString(@"_activeTasksText", "")
#define _timerTaskMarkDoneText NSLocalizedString(@"_timerTaskMarkDoneText", "")
#define _holdAllAndStartText NSLocalizedString(@"_holdAllAndStartText", "")
#define _propertiesEditText NSLocalizedString(@"_propertiesEditText", "")

#define _timerRecoverTitle NSLocalizedString(@"_timerRecoverTitle", "")
#define _timerRecoverText NSLocalizedString(@"_timerRecoverText", "")
#define _timerResumeText NSLocalizedString(@"_timerResumeText", "")
#define _timerContinueText NSLocalizedString(@"_timerContinueText", "")
#define _tbdTaskText NSLocalizedString(@"_tbdTaskText", "")
#define _newPlanText NSLocalizedString(@"_newPlanText", "")
#define _newItemText NSLocalizedString(@"_newItemText", "")

#define _timerHistoryText NSLocalizedString(@"_timerHistoryText", "")
#define _totalDurationText NSLocalizedString(@"_totalDurationText", "")

#define _reportSuccess NSLocalizedString(@"_reportSuccess", "")
#define _reportFailure NSLocalizedString(@"_reportFailure", "")

#define _createTask NSLocalizedString(@"_createTask", "")

#define _currentText NSLocalizedString(@"_currentText", "")
#define _snoozeDuration NSLocalizedString(@"_snoozeDuration", "")
#define _snooze NSLocalizedString(@"_snooze", "")
#define _postpone NSLocalizedString(@"_postpone", "")

#define _1DayText NSLocalizedString(@"_1DayText", "")
#define _1WeekText NSLocalizedString(@"_1WeekText", "")
#define _1MonthText NSLocalizedString(@"_1MonthText", "")

#define _reminderSync NSLocalizedString(@"_reminderSync", "")
#define _reminderText NSLocalizedString(@"_reminderText", "")
#define _sourceText NSLocalizedString(@"_sourceText", "")

#define _reminderNameDuplicationText NSLocalizedString(@"_reminderNameDuplicationText", "")
#define _reminderDuplicationResolveSuggestionText NSLocalizedString(@"_reminderDuplicationResolveSuggestionText", "")

#define _reminderMultiSourceWarningText NSLocalizedString(@"_reminderMultiSourceWarningText", "")
#define _noReminderSourceFoundText NSLocalizedString(@"_noReminderSourceFoundText", "")
#define _reminderFatalError NSLocalizedString(@"_reminderFatalError", "")
#define _reminderAccessHint NSLocalizedString(@"_reminderAccessHint", "")

#define _taskSyncText NSLocalizedString(@"_taskSyncText", "")

#define _timeZoneSupport NSLocalizedString(@"_timeZoneSupport", "")
#define _timeZone NSLocalizedString(@"_timeZone", "")



