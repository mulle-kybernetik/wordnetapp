//---------------------------------------------------------------------------------------
//	WNSearchWindowController.m created by erik on Fri 18-Sep-1998
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at <http://www.erik.clara.net>.
//	@(#)$Id: WNSearchWindowController.m,v 1.2 2001-03-14 22:47:17 znek Exp $
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "WNController.h"
#import "WNResult.h"
#import "WNTextView.h"
#import "WNSearchWindowController.h"


@interface WNSearchWindowController(PrivateAPI)
- (void)_setOutputText:(NSString *)text;
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
    
    [[self window] setFrameUsingName:@"SearchWindow"];
    [[self window] setFrameAutosaveName:@"SearchWindow"];
    [inputField setCompletes:YES];
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

- (void)runSearch:(id)sender
{
    NSArray				*resultSet;
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

    word = [inputField stringValue];

    resultSet = [wnController runSearchForWord:word];
    if([resultSet count] == 0)
        {
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
        else
            NSLog(@"warning. no popup item for '%@' %@/%@.", [result word], [result pos], [result type]);
        }
    
    [self _setOutputText:overviews];

    [inputField removeItemWithObjectValue:word];
    while([[inputField objectValues] count] > 20)
        [inputField removeItemAtIndex:[[inputField objectValues] count] - 1];
    [inputField insertItemWithObjectValue:word atIndex:0];
    [inputField selectItemAtIndex:0];

    [[self window] makeFirstResponder:[[self window] initialFirstResponder]];
}


- (void)getDetails:(id)sender
{
    NSString  *details;

    details = [wnController getDetailsForResult:[[sender selectedItem] representedObject]];
    [self _setOutputText:details];
}


- (void)_setOutputText:(NSString *)text
{
    NSMutableAttributedString	*buffer;
    NSMutableDictionary			*fontAttr;
    NSMutableParagraphStyle		*lineStyle;
    NSAttributedString			*formattedLine, *newlineString;
    NSEnumerator				*lineEnum;
    NSString					*line;
    NSScanner					*scanner;
    int							prefixLength;

    buffer = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    fontAttr = [NSDictionary dictionaryWithObject:[textView font] forKey:NSFontAttributeName];
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



- (void)printResult:(id)sender
{
    NSColor *bgc = [textView backgroundColor];
    [textView setBackgroundColor:[NSColor whiteColor]];
    [textView print:sender];
    [textView setBackgroundColor:bgc];
}


//---------------------------------------------------------------------------------------
//	OTHER INVOCATIONS FOR SEARCHES
//---------------------------------------------------------------------------------------

- (void)textViewDoubleClickNotification:(NSNotification *)notification
{
    [inputField setStringValue:[[notification userInfo] objectForKey:@"selection"]];
    [[inputField target] performSelector:[inputField action] withObject:inputField];
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
    [self showWindow:self];
    [inputField setStringValue:string];
    [[inputField target] performSelector:[inputField action] withObject:inputField];
}



//=======================================================================================
    @end
//=======================================================================================
