//
//  NoteView.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/8/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "NoteView.h"

#import "Common.h"
#import "Task.h"

#import "ImageManager.h"
#import "DBManager.h"

#import "CustomTextView.h"
#import "LinkPreviewPane.h"
#import "SimpleCoreTextView.h"

#import "SmartDayViewController.h"

extern SmartDayViewController *_sdViewCtrler;

@implementation NoteView

@synthesize note;
//@synthesize inCheckMode;
@synthesize checkDict;
@synthesize editEnabled;
@synthesize touchEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.checkDict = [NSMutableDictionary dictionaryWithCapacity:10];
        
        self.editEnabled = YES;
        self.touchEnabled = NO;
        
        noteBgScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        noteBgScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"noteBG.png"]];
        
        [self addSubview:noteBgScrollView];
        [noteBgScrollView release];

        
        CGRect frm = self.bounds;
        frm.origin.x += 20;
        frm.size.width -= 20;
        
        noteTextView = [[CustomTextView alloc] initWithFrame:frm];

        noteTextView.delegate = self;
        noteTextView.text = self.note.note;
        
        [self addSubview:noteTextView];
        [noteTextView release];
        
        [self createDoneBarView];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tapRecognizer.numberOfTapsRequired = 2;
        tapRecognizer.numberOfTouchesRequired = 1;
        [noteTextView addGestureRecognizer:tapRecognizer];
    }
    
    return self;
}

- (void) doubleTap:(id)sender
{
    [self cancelEdit];
    
    doneBarView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteDoubleTapNotification" object:nil];
}

- (void) createDoneBarView
{
	doneBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 40)];
	doneBarView.backgroundColor = [UIColor clearColor];
	doneBarView.hidden = YES;
	
	[self addSubview:doneBarView];
	[doneBarView release];
	
	UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, doneBarView.bounds.size.width, 40)];
	backgroundView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	backgroundView.alpha = 0.7;
	
	[doneBarView addSubview:backgroundView];
	[backgroundView release];
    
    checkButton=[Common createButton:@""
                          buttonType:UIButtonTypeCustom
                               frame:CGRectMake(10, 5, 30, 30)
                          titleColor:[UIColor whiteColor]
                              target:self
                            selector:@selector(check:)
                    normalStateImage:@"CheckOn30.png"
                  selectedStateImage:@"CheckOn30_blue.png"];
    checkButton.backgroundColor=[UIColor clearColor];
    
    [doneBarView addSubview:checkButton];
    
    
    UIButton *uncheckAllButton=[Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(60, 5, 30, 30)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(uncheckAll:)
                                   normalStateImage:@"CheckNone.png"
                                 selectedStateImage:nil];
    uncheckAllButton.backgroundColor=[UIColor clearColor];
    
    [doneBarView addSubview:uncheckAllButton];
    
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	doneButton.frame = CGRectMake(doneBarView.bounds.size.width-70, 5, 60, 30);
	doneButton.alpha=1;
	[doneButton setTitle:_doneText forState:UIControlStateNormal];
	doneButton.titleLabel.font=[UIFont systemFontOfSize:14];
	[doneButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"blue-small.png"] forState:UIControlStateNormal];
	
	[doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
	[doneBarView addSubview:doneButton];
}

- (void) changeFrame:(CGRect)frame
{
    self.frame = frame;
    
    CGRect frm = self.bounds;
    
    noteBgScrollView.frame = frm;
    
    frm.origin.x += 20;
    frm.size.width -= 20;
    
    noteTextView.frame = frm;
}

- (void) dealloc
{
    self.checkDict = nil;
    
    noteBgScrollView = nil;
    
    [super dealloc];
}

- (void) doCheck:(id) sender
{
    UIButton *btn = (UIButton *) sender;
    
    NSInteger idx = btn.tag;
    
    NSMutableString *text = [NSMutableString stringWithString: noteTextView.text];
    
    NSString *str = [self getLinesFromString:text lineNum:idx];
    
    //printf("string until %d: %s\n", idx, [str UTF8String]);
    
    unichar checkChar = (btn.selected?0x2705:0x274E);
    NSRange checkRange = [str rangeOfString:[NSString stringWithFormat:@"%C", checkChar] options:NSBackwardsSearch];
    
    if (checkRange.location == NSNotFound)
    {
        checkRange.location = 0;
    }
    
    btn.selected = !btn.selected;
    
    checkChar = (btn.selected?0x2705: 0x274E);
    
    [text replaceCharactersInRange:checkRange withString:[NSString stringWithFormat:@"%C", checkChar]];
    
    noteTextView.text = text;
    
    self.note.note = text;
    
    if (self.touchEnabled) //in Preview pane
    {
        [self.note updateIntoDB:[[DBManager getInstance] getDatabase]];
        
        [_sdViewCtrler.previewPane markNoteChange];
    }
    
    //NSLog(@"text: %@", text);
}

- (void) changeCheckMode:(BOOL)inCheck
{
    NSMutableString *text = [NSMutableString stringWithString: noteTextView.text];
    
    NSRange cursorRange = [noteTextView selectedRange];
    
    NSRange range = cursorRange;
    
    range.length = range.location;
    range.location = 0;
    
    NSString *subString = [noteTextView.text substringWithRange:range];
    
    range = [subString rangeOfString:@"\n" options:NSBackwardsSearch]; //find the begin line of current text
    
    if (range.location != NSNotFound)
    {
        NSRange startRange = range;
        
        startRange.length = startRange.location+1;
        startRange.location = 0;
        
        subString = [noteTextView.text substringWithRange:startRange];
    }
    else
    {
        range.location = 0;
        range.length = 0;
    }
    
    int lineIdx = [self getLineNo:subString];
    
    UIButton *btn = [self.checkDict objectForKey:[NSNumber numberWithInt:lineIdx]];
    
    if (btn != nil && !inCheck)
    {
        //find end line string to assure to remove check character if cursor is in front of it
        
        NSRange range = cursorRange;
        
        range.length = range.location;
        range.location = 0;
        
        int len = 0;
        
        for (int idx = range.length; idx < noteTextView.text.length; idx ++)
        {
            if ([noteTextView.text characterAtIndex:idx] == 0x000A)
            {
                break;
            }
            else
            {
                len += 1;
            }
        }
        
        range.length += len;
        
        NSString *endLineStr = [noteTextView.text substringWithRange:range];
        
        //remove check
        range = [endLineStr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%C%C",0x2705,0x274E]] options:NSBackwardsSearch];
        
        if (range.location != NSNotFound)
        {
            [text replaceCharactersInRange:range withString:@""];
            [btn removeFromSuperview];
            [self.checkDict removeObjectForKey:[NSNumber numberWithInt:lineIdx]];
            
            if (range.location <= text.length - 1)
            {
                unichar c = [text characterAtIndex:range.location];
                
                if (c == 0x0020) //white space -> remove
                {
                    [text replaceCharactersInRange:range withString:@""];
                }
            }
            
            noteTextView.text = text;
            
            cursorRange.location -= 2;
            noteTextView.selectedRange = cursorRange;
            
        }
        
    }
    else if (btn == nil && inCheck)
    {
        //add check
        
        UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        checkBtn.tag = lineIdx;
        
        CGRect frm = [self getCheckFrameAtLine:lineIdx];
        
        checkBtn.frame = frm;
        
        [checkBtn setImage:[UIImage imageNamed:@"Note_CheckOff.png"] forState:UIControlStateNormal];
        [checkBtn setImage:[UIImage imageNamed:@"Note_CheckOn.png"] forState:UIControlStateSelected];
        [checkBtn addTarget:self action:@selector(doCheck:) forControlEvents:UIControlEventTouchUpInside];
        
        [noteTextView addSubview:checkBtn];
        
        [self.checkDict setObject:checkBtn forKey:[NSNumber numberWithInt:lineIdx]];
        
        unichar checkChar = 0x274E;
        NSString *checkString = [NSString stringWithFormat:lineIdx == 0?@"%C ":@"\n%C ", checkChar,checkChar];
        
        [text replaceCharactersInRange:range withString:checkString];
        
        noteTextView.text = text;
        
        cursorRange.location += checkString.length-1;
        [noteTextView setSelectedRange:cursorRange];
    }
}

- (void) finishEdit
{
    [noteTextView resignFirstResponder];
    
    noteTextView.contentOffset = CGPointZero;

    NSString *text = [noteTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
    if (self.note != nil)
    {
        self.note.note = text;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteFinishEditNotification" object:nil];    
}

- (void) startEdit
{
    [noteTextView becomeFirstResponder];
}

- (void) cancelEdit
{
    [noteTextView resignFirstResponder];
}

- (void) setNote:(Task *)noteParam
{
    note = noteParam;
    
    noteTextView.text = (self.note == nil?@"":self.note.note);
    
    [self removeAllChecks];
    
    if (self.note != nil)
    {
        [self createCheckButtons:self.note.note];
    }
}

- (NSString *) getNoteText
{
    return noteTextView.text;
}

- (void) refreshNoteBackground
{
    if (noteBgScrollView != nil)
    {
        [noteBgScrollView setContentSize:noteTextView.contentSize];
        [noteBgScrollView setContentOffset:noteTextView.contentOffset];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark Note

- (CGRect) getCheckFrameAtLine:(NSInteger)lineIdx
{
    return CGRectMake(5, lineIdx*24+5, 30, 30);
}

- (void) createCheckButtons:(NSString *)text
{
    ////NSLog(@"note text: %@", text);
    
    NSRange searchRange;
    
    searchRange.location = 0;
    searchRange.length = text.length;
    
    int lineIdx = 0;
    
    while (searchRange.location != NSNotFound)
    {
        NSRange range = [text rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:searchRange];
        
        if (range.location != NSNotFound)
        {
            int searchLocation = searchRange.location;
            
            range.length = range.location - searchLocation + 1;
            
            searchRange.location = range.location + 1;
            searchRange.length = text.length - range.location - 1;
            
            range.location = searchLocation;
            
            NSString *lineStr = [text substringWithRange:range];
            
            range = [lineStr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%C%C",0x2705,0x274E]]];
            
            if (range.location != NSNotFound) //check found
            {
                unichar c = [lineStr characterAtIndex:range.location];
                
                UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                checkBtn.tag = lineIdx;
                
                CGRect frm = [self getCheckFrameAtLine:lineIdx];
                
                checkBtn.frame = frm;
                
                [checkBtn setImage:[UIImage imageNamed:@"Note_CheckOff.png"] forState:UIControlStateNormal];
                [checkBtn setImage:[UIImage imageNamed:@"Note_CheckOn.png"] forState:UIControlStateSelected];
                [checkBtn addTarget:self action:@selector(doCheck:) forControlEvents:UIControlEventTouchUpInside];
                
                checkBtn.selected = (c == 0x2705);
                
                [noteTextView addSubview:checkBtn];
                
                [self.checkDict setObject:checkBtn forKey:[NSNumber numberWithInt:lineIdx]];
            }
            
            lineIdx += [self getLines:lineStr];
            
        }
        else
        {
            break;
        }
    }
    
    if (searchRange.length > 0)
    {
        NSString *lineStr = [text substringWithRange:searchRange];
        
        NSRange range = [lineStr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%C%C",0x2705,0x274E]]];
        
        if (range.location != NSNotFound)
        {
            unichar c = [lineStr characterAtIndex:range.location];
            
            UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            checkBtn.tag = lineIdx;
            
            CGRect frm = [self getCheckFrameAtLine:lineIdx];
            
            checkBtn.frame = frm;
            
            [checkBtn setImage:[UIImage imageNamed:@"Note_CheckOff.png"] forState:UIControlStateNormal];
            [checkBtn setImage:[UIImage imageNamed:@"Note_CheckOn.png"] forState:UIControlStateSelected];
            [checkBtn addTarget:self action:@selector(doCheck:) forControlEvents:UIControlEventTouchUpInside];
            
            checkBtn.selected = (c == 0x2705);
            
            [noteTextView addSubview:checkBtn];
            
            [self.checkDict setObject:checkBtn forKey:[NSNumber numberWithInt:lineIdx]];
            
        }
    }
}

- (int) countString:(NSString *)stringToCount inText:(NSString *)text{
    int foundCount=0;
    NSRange range = NSMakeRange(0, text.length);
    range = [text rangeOfString:stringToCount options:NSCaseInsensitiveSearch range:range locale:nil];
    while (range.location != NSNotFound) {
        foundCount++;
        range = NSMakeRange(range.location+range.length, text.length-(range.location+range.length));
        range = [text rangeOfString:stringToCount options:NSCaseInsensitiveSearch range:range locale:nil];
    }
    
    return foundCount;
}

- (NSString *) getLinesFromString:(NSString *)text lineNum:(NSInteger)lineNum
{
    int len = 0;
    
    NSRange searchRange;
    
    searchRange.location = 0;
    searchRange.length = text.length;
    
    int retLen = text.length;
    
    int lineIdx = 0;
    
    while (searchRange.location != NSNotFound)
    {
        NSRange range = [text rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:searchRange];
        
        if (range.location != NSNotFound)
        {
            int searchLocation = searchRange.location;
            
            range.length = range.location - searchLocation;
            
            searchRange.location = range.location + 1;
            searchRange.length = text.length - range.location - 1;
            
            range.location = searchLocation;
            
            NSString *lineStr = [text substringWithRange:range];
            
            CGSize sz = [lineStr sizeWithFont:noteTextView.font];
            
            int lines = sz.width/noteTextView.bounds.size.width;
            
            if (sz.width > lines*noteTextView.bounds.size.width)
            {
                lines += 1;
            }
            
            lineIdx += lines;
            
            if (lineIdx > lineNum)
            {
                retLen = searchRange.location;
                
                break;
            }
        }
        else
        {
            break;
        }
    }
    
    searchRange.location = 0;
    searchRange.length = retLen;
    
    return [text substringWithRange:searchRange];
}

- (NSInteger) getLines:(NSString *)text
{
    return [Common countLines:text boundWidth:noteTextView.bounds.size.width withFont:noteTextView.font];
}

- (NSInteger) getLineNo:(NSString *)text
{
    NSArray *array = [text componentsSeparatedByString:@"\n"];
    
    int count = 0;
    
    for (int i=0;i<array.count-1;i++)
    {
        NSString *str = [array objectAtIndex:i];
        
        if ([str isEqualToString:@""])
        {
            count ++; //empty line (\n)
        }
        else
        {
            count += [self getLines:str];            
        }
    }
    
    if (array.count > 0)
    {
        NSString *str = [array lastObject];
        
        if ([str isEqualToString:@""])
        {
            //last character is \n
            count += 1;
        }
    }
    
    if (count > 0)
    {
        return count - 1; //return index of line
    }
    
    return count;
}

- (void) removeAllChecks
{
    NSEnumerator *objEnum = self.checkDict.objectEnumerator;
    
    UIButton *btn;
    
    while ((btn = [objEnum nextObject]) != nil)
    {
        [btn removeFromSuperview];
    }
    
    self.checkDict = [NSMutableDictionary dictionaryWithCapacity:10];
}

- (void) uncheckAll:(id) sender
{
    [self removeAllChecks];
    
    NSString *note = [noteTextView.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%C", 0x2705] withString:[NSString stringWithFormat:@"%C", 0x274E]];
    
    noteTextView.text = note;
    
    [self createCheckButtons:note];
}

#pragma mark Actions
- (void) check:(id) sender
{
    checkButton.selected = !checkButton.selected;
    
    [self changeCheckMode:checkButton.selected];
}

- (void) done:(id)sender
{
    doneBarView.hidden = YES;
    
    [self finishEdit];
}

#pragma mark TextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!self.editEnabled)
    {
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteBeginEditNotification" object:nil]; //notify observers to resize NoteView
    
    CGRect frm = noteTextView.frame;
    
    frm.size.height -= 40;
    
    noteTextView.frame = frm;
    
    frm = doneBarView.frame;
    
    frm.origin.y = self.bounds.size.height-40;
    doneBarView.frame = frm;
    
    doneBarView.hidden = NO;
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.note.name = [Common getNoteTitle:noteTextView.text];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteContentChangeNotification" object:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL createChecks = NO;
    
    NSString *subString = [textView.text substringWithRange:range];
    
    NSRange checkRange = [subString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%C%C\n",0x2705,0x274E]] options:NSBackwardsSearch];
    
    if (checkRange.location != NSNotFound)
    {
        //replace any check characters -> refresh all check boxes
        
        createChecks = YES;
    }
    
    
    NSRange searchRange;
    
    searchRange.location = 0;
    searchRange.length = text.length;
    
    checkRange = [text rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:searchRange];
    
    if (checkRange.location != NSNotFound) //user inputs new line
    {
        if (checkButton.selected)
        {
            text = [text stringByReplacingCharactersInRange:checkRange withString:[NSString stringWithFormat:@"\n%C ", 0x274E]];
        }
        
        createChecks = YES;
    }
    
    NSString *textStr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (!createChecks)
    {
        int lineNo = [self getLineNo:textView.text];
        
        int lineNo2 = [self getLineNo:textStr];
        
        ////printf("line#1:%d - line#2:%d\n", lineNo, lineNo2);
        
        if (lineNo != lineNo2) //user inputs long text to take >= 2 lines
        {
            createChecks = YES;
        }
    }
    
    if (createChecks)
    {
        textView.text = textStr;
        
        [self removeAllChecks];

        [self createCheckButtons:textStr];
        
        checkRange.location = range.location + text.length;
        checkRange.length = 0;
        
        textView.selectedRange = checkRange;
        
        [self textViewDidChange:textView];
        
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    //printf("change selection\n");
    
    NSRange cursorRange = [noteTextView selectedRange];
    
    NSRange range = cursorRange;
    
    if (range.location == NSNotFound)
    {
        return;
    }
    
    range.length += range.location;
    range.location = 0;
    
    NSString *subString = [noteTextView.text substringWithRange:range];
    
    range = [subString rangeOfString:@"\n" options:NSBackwardsSearch]; //find the begin line of current text
    
    if (range.location != NSNotFound)
    {
        range.length = range.location+1;
        range.location = 0;
        
        subString = [noteTextView.text substringWithRange:range];
    }
    
    NSInteger lineIdx = [self getLineNo:subString];
    
    //printf("begin line: %d\n", lineIdx);
    
    UIButton *btn = [self.checkDict objectForKey:[NSNumber numberWithInt:lineIdx]];
    
    checkButton.selected = (btn != nil);
    
    if (cursorRange.length == 0 && (cursorRange.location < noteTextView.text.length))
    {
        unichar c = [noteTextView.text characterAtIndex:cursorRange.location];
        
        if (c == 0x2705 || c == 0x274E)
        {
            cursorRange.location += 2;
            
            textView.selectedRange = cursorRange;
        }
    }
}

@end
