//---------------------------------------------------------------------------------------
//	WNSearchWindowController.m created by erik on Fri 18-Sep-1998
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at http://www.mulle-kybernetik.com/software/WordNet/.
//	@(#)$Id: WNSearchWindowController.m,v 1.6 2003-11-04 02:45:31 znek Exp $
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "WNController.h"
#import "WNResult.h"
#import "WNTextView.h"
#import "WNSearchWindowController.h"


@interface WNSearchWindowController(PrivateAPI)
- (void)_setOutputText:(NSString *)text;
- (void)findDirection:(int)direction;
- (NSRange)findString:(NSString *)string inString:(NSString *)supersetString selectedRange:(NSRange)selectedRange options:(unsigned)options wrap:(BOOL)wrap;
- (NSString *)pbSearchString;
- (void)setPbSearchString:(NSString *)aString;
@end


//=======================================================================================
    @implementation WNSearchWindowController
//=======================================================================================

//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    [WNTextView poseAsClass:[NSTextView class]];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithAccessController:(WNController *)controller
{
    if((self = [self initWithWindowNibName:@"SearchWindow"]) == nil)
        return nil;
    wnController = [controller retain];
    return self;
}


- (void)windowDidLoad
{
    NSArray				*popUpButtonList;
    NSMutableDictionary	*titles;
    NSEnumerator		*popUpButtonEnum, *itemEnum;
    NSPopUpButton		*popUpButton;
    id <NSMenuItem>		item;
    NSNumber			*wordType;
    
    [super windowDidLoad];

    popUpButtonList = [NSArray arrayWithObjects:nounPopUp, verbPopUp, adjPopUp, advPopUp, nil];
    popUpButtons = [[NSMutableDictionary alloc] init];
    popUpTitles = [[NSMutableDictionary alloc] init];
    popUpButtonEnum = [popUpButtonList objectEnumerator];
    while((popUpButton = [popUpButtonEnum nextObject]) != nil)
        {
        [popUpButton setAutoenablesItems:NO];
        wordType = [NSNumber numberWithInt:[popUpButton tag]];
        [popUpButtons setObject:popUpButton forKey:wordType];
        titles = [NSMutableDictionary dictionary];
        itemEnum = [[popUpButton itemArray] objectEnumerator];
        while((item = [itemEnum nextObject]) != nil)
            if([item tag] > 0)
                [titles setObject:[item title] forKey:[NSNumber numberWithInt:[item tag]]];
        [popUpTitles setObject:titles forKey:wordType];
        }
    
    [(NSSearchFieldCell *)[inputField cell] setMaximumRecents:20];

    [[self window] setFrameUsingName:@"SearchWindow"];
    [[self window] setFrameAutosaveName:@"SearchWindow"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDoubleClickNotification:) name:WNTextViewDoubleClickNotification object:textView];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [popUpButtons release];
    [popUpTitles release];
    [wnController release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	WINDOW HANDLING
//---------------------------------------------------------------------------------------

- (void)showWindow:(id)sender
{
    [self window]; // will load NIB if necessary
    [super showWindow:sender];
}


//---------------------------------------------------------------------------------------
//	ACTIONS METHODS
//---------------------------------------------------------------------------------------

- (IBAction)runSearch:(id)sender
{
    NSArray				*resultSet = nil;
    NSMutableDictionary	*resultWords;
    NSEnumerator		*popUpButtonEnum;
    NSPopUpButton		*popUpButton;
    NSDictionary		*titles;
    NSString			*word;
    NSMutableString		*overviews;
    NSEnumerator		*resultEnum, *itemEnum;
    WNResult			*result;
    id <NSMenuItem>		item;
    int					itemIndex;

    word = [[inputField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if([word isEqualToString:@""] == NO)
        resultSet = [wnController runSearchForWord:word];
    if(resultSet == nil || [resultSet count] == 0)
        {
        [nounPopUp setEnabled:NO];
        [verbPopUp setEnabled:NO];
        [adjPopUp setEnabled:NO];
        [advPopUp setEnabled:NO];
        [textView setString:@""];

        [inputField selectText:self];
        [[self window] makeFirstResponder:inputField];

        NSBeep();
        return;
        }

    resultWords = [NSMutableDictionary dictionary];
    overviews = [NSMutableString string];
    resultEnum = [resultSet objectEnumerator];
    while((result = [resultEnum nextObject]) != nil)
        {
        [resultWords setObject:[result word] forKey:[NSNumber numberWithInt:[result posCode]]];
        if([result typeCode] == 29)
            [overviews appendString:[wnController getDetailsForResult:result]];
        }

    // setup titles and disable all
    popUpButtonEnum = [popUpButtons objectEnumerator];
    while((popUpButton = [popUpButtonEnum nextObject]) != nil)
        {
        [popUpButton setEnabled:NO];
        titles = [popUpTitles objectForKey:[NSNumber numberWithInt:[popUpButton tag]]];
        itemEnum = [[popUpButton itemArray] objectEnumerator];
        while((item = [itemEnum nextObject]) != nil)
            {
            if([item tag] < 0)
                continue;
            [item setTitle:[NSString stringWithFormat:[titles objectForKey:[NSNumber numberWithInt:[item tag]]], [resultWords objectForKey:[NSNumber numberWithInt:[popUpButton tag]]]]];
            [item setEnabled:NO];
            }
        }

    // enable valid searches
    resultEnum = [resultSet objectEnumerator];
    while((result = [resultEnum nextObject]) != nil)
        {
        popUpButton = [popUpButtons objectForKey:[NSNumber numberWithInt:[result posCode]]];
        [popUpButton setEnabled:YES];
        if((itemIndex = [popUpButton indexOfItemWithTag:[result typeCode]]) != -1)
            {
            item = [popUpButton itemAtIndex:itemIndex];
            [item setEnabled:YES];
            [item setRepresentedObject:result];
            }
#if DEBUG
        else
            NSLog(@"warning. no popup item for '%@' %@/%@.", [result word], [result pos], [result type]);
#endif
        }
    
    [self _setOutputText:overviews];

    [inputField selectText:self];
    [[self window] makeFirstResponder:inputField];
}


- (IBAction)getDetails:(id)sender
{
    NSString  *details;

    details = [wnController getDetailsForResult:[[sender selectedItem] representedObject]];
    [self _setOutputText:details];
}


- (void)_setOutputText:(NSString *)text
{
    static NSFont *font = nil;
    NSMutableAttributedString	*buffer;
    NSMutableDictionary			*fontAttr;
    NSMutableParagraphStyle		*lineStyle;
    NSAttributedString			*formattedLine, *newlineString;
    NSEnumerator				*lineEnum;
    NSString					*line;
    NSScanner					*scanner;
    int							prefixLength;

    if(font == nil)
        font = [[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] retain];

    buffer = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    fontAttr = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    newlineString = [[[NSAttributedString alloc] initWithString:@"\n"] autorelease];

    lineEnum = [[text componentsSeparatedByString:@"\n"] objectEnumerator];
    while((line = [lineEnum nextObject]) != nil)
        {
        scanner = [NSScanner scannerWithString:line];
        if([scanner scanString:@"->" intoString:NULL] == YES)
            prefixLength = [scanner scanLocation];
        else if([scanner scanString:@"=>" intoString:NULL] == YES)
            prefixLength = [scanner scanLocation];
        else if([scanner scanString:@"MEMBER OF:" intoString:NULL] == YES)
            prefixLength = [scanner scanLocation];
        else if([scanner scanString:@"PART OF:" intoString:NULL] == YES)
            prefixLength = [scanner scanLocation];
        else if([scanner scanString:@"HAS PART:" intoString:NULL] == YES)
            prefixLength = [scanner scanLocation];
        else if([scanner scanString:@"EX:" intoString:NULL] == YES)
            prefixLength = [scanner scanLocation];
        else if([scanner scanInt:NULL] && [scanner scanString:@"." intoString:NULL])
            prefixLength = [scanner scanLocation];
        else
            prefixLength = 0;
        if(([line length] > prefixLength) && ([line characterAtIndex:prefixLength] == ' '))
            prefixLength += 1;
        
        lineStyle = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [lineStyle setHeadIndent:[[line substringToIndex:prefixLength] sizeWithAttributes:fontAttr].width];
        formattedLine = [[[NSAttributedString alloc] initWithString:line attributes:[NSDictionary dictionaryWithObject:lineStyle forKey:NSParagraphStyleAttributeName]] autorelease];
        [buffer appendAttributedString:formattedLine];
        [buffer appendAttributedString:newlineString];
        }

    [[textView textStorage] beginEditing];
    [[textView textStorage] setAttributedString:buffer];
    [[textView textStorage] endEditing];
}



- (IBAction)printResult:(id)sender
{
    NSColor *bgc = [textView backgroundColor];
    [textView setBackgroundColor:[NSColor whiteColor]];
    [textView print:sender];
    [textView setBackgroundColor:bgc];
}

- (IBAction)enterSelection:(id)sender
{
  NSRange range = [textView selectedRange];
  if(range.length != 0)
  {
    NSString *searchString = [[[textView textStorage] string] substringWithRange:range];
    [self setPbSearchString:searchString];
    [findStringField setStringValue:searchString];
  }
  else
  {
    NSBeep();
  }
}

- (void)jumpToSelection: sender
{
  [textView scrollRangeToVisible:[textView selectedRange]];
}


//---------------------------------------------------------------------------------------
//	FIND PANEL
//---------------------------------------------------------------------------------------


- (IBAction)showFindPanel:(id)sender
{
  if([self pbSearchString])
    [findStringField setStringValue:[self pbSearchString]];
  else
    [findStringField setStringValue:@""];
  [findPanel makeKeyAndOrderFront:sender];
}

- (IBAction)findNext:(id)sender
{
  [self setPbSearchString:[findStringField stringValue]];
  [self findDirection:0];
}

- (IBAction)findPrevious:(id)sender
{
  [self setPbSearchString:[findStringField stringValue]];
  [self findDirection:NSBackwardsSearch];
}


/*
      direction is one of
      0 == forwards
      NSBackwardsSearch == backwards
 */

- (void)findDirection:(int)direction
{
  NSString *searchString;
  BOOL found = NO;

  searchString = [self pbSearchString];
  if(searchString != nil)
  {
    NSString *textContents = [[textView textStorage] string];
    unsigned textLength;
    if(textContents && (textLength = [textContents length]))
    {
      NSRange range;
      unsigned options = 0;
      if(direction == NSBackwardsSearch)
        options |= NSBackwardsSearch;
      if([ignoreCaseButton state] == NSOnState)
        options |= NSCaseInsensitiveSearch;
      range = [self findString:searchString inString:textContents selectedRange:[textView selectedRange] options:options wrap:YES];
      if(range.length)
      {
        [textView setSelectedRange:range];
        [textView scrollRangeToVisible:range];
        found = YES;
      }
    }
  }

  if(found == NO)
    NSBeep();
}

- (NSRange)findString:(NSString *)string inString:(NSString *)supersetString selectedRange:(NSRange)selectedRange options:(unsigned)options wrap:(BOOL)wrap
{
  BOOL forwards = (options & NSBackwardsSearch) == 0;
  unsigned length = [supersetString length];
  NSRange searchRange, range;

  if(forwards)
  {
    searchRange.location = NSMaxRange(selectedRange);
    searchRange.length = length - searchRange.location;
    range = [supersetString rangeOfString:string options:options range:searchRange];
    if((range.length == 0) && wrap)
    {
      // If not found look at the first part of the string
      searchRange.location = 0;
      searchRange.length = selectedRange.location;
      range = [supersetString rangeOfString:string options:options range:searchRange];
    }
  }
  else
  {
    searchRange.location = 0;
    searchRange.length = selectedRange.location;
    range = [supersetString rangeOfString:string options:options range:searchRange];
    if((range.length == 0) && wrap)
    {
      searchRange.location = NSMaxRange(selectedRange);
      searchRange.length = length - searchRange.location;
      range = [supersetString rangeOfString:string options:options range:searchRange];
    }
  }
  return range;
}        

- (NSString *)pbSearchString
{
  NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];
  NSString *searchString = nil;

  if([[pasteboard types] containsObject:NSStringPboardType])
    searchString = [pasteboard stringForType:NSStringPboardType];

  return searchString;
}

- (void)setPbSearchString:(NSString *)aString
{
  NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];

  [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
  [pasteboard setString:aString forType:NSStringPboardType];
}


//---------------------------------------------------------------------------------------
//	MENU ITEM VALIDATION
//---------------------------------------------------------------------------------------

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
  SEL action = [anItem action];
  
  if(action == @selector(findPrevious:))
    return ([self pbSearchString] != nil) && ([[[textView textStorage] string] length] != 0);
  if(action == @selector(findNext:))
    return ([self pbSearchString] != nil) && ([[[textView textStorage] string] length] != 0);
  if(action == @selector(jumpToSelection:))
    return [textView selectedRange].length != 0;
  if(action == @selector(enterSelection:))
    return [textView selectedRange].length != 0;

  return YES;
}


//---------------------------------------------------------------------------------------
//	OTHER INVOCATIONS FOR SEARCHES
//---------------------------------------------------------------------------------------

- (void)textViewDoubleClickNotification:(NSNotification *)notification
{
    NSString *searchString;

    searchString = [[[notification userInfo] objectForKey:@"selection"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [inputField setStringValue:searchString];
    [inputField performClick:self];
}


- (void)provideLookupService:(NSPasteboard *)pasteboard userData:(NSString *)userData error:(NSString **)error
{
    NSString *string;

    if([[pasteboard types] containsObject:NSStringPboardType] == NO)
        {
        *error = NSLocalizedString(@"No text provided.", "");
        return;
        }
    if((string = [pasteboard stringForType:NSStringPboardType]) == nil)
        {
        *error = NSLocalizedString(@"No text provided.", "");
        return;
        }
    [NSApp activateIgnoringOtherApps:YES];
    [self showWindow:self];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [inputField setStringValue:string];
    [inputField performClick:self];
}


//---------------------------------------------------------------------------------------
//	WINDOW DELEGATE METHODS
//---------------------------------------------------------------------------------------

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
  // Update Findpanel with current NSFindPasteboard's content
  // (which might have been changed by another app in the meantime)
  if([self pbSearchString])
    [findStringField setStringValue:[self pbSearchString]];
  else
    [findStringField setStringValue:@""];
}


//=======================================================================================
    @end
//=======================================================================================
