//---------------------------------------------------------------------------------------
//	WNPrefPanelController.m created by erik on Sun 11-Apr-1999
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at http://www.mulle-kybernetik.com/software/WordNet/.
//	@(#)$Id: WNPrefPanelController.m,v 1.2 2003-11-03 12:42:03 znek Exp $
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "Constants.h"
#import "WNPrefPanelController.h"


//=======================================================================================
    @implementation WNPrefPanelController
//=======================================================================================

#define StdUserDefaults [NSUserDefaults standardUserDefaults] 


//---------------------------------------------------------------------------------------
//	FACTORY	
//---------------------------------------------------------------------------------------

+ (id)prefPanelController
{
    return [[[WNPrefPanelController alloc] init] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)init
{
    if((self = [self initWithWindowNibName:@"Preferences"]) == nil)
        return nil;

    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    // we'll remove the box from its superview...
    [restartNoteBox retain];
}


- (void)dealloc
{
    [restartNoteBox release];
    [super dealloc];
}

    
//---------------------------------------------------------------------------------------
//	RUNNING THE PANEL
//---------------------------------------------------------------------------------------

- (int)runModalDisplayRestartNote:(BOOL)flag
{
    int choice;

    noteFlag = flag;
    [self window]; // will load NIB if necessary
    [restartNoteBox removeFromSuperview];
    [dpathField setStringValue:[StdUserDefaults stringForKey:WNDictionaryDefaultsKey]];
    choice = [[NSApplication sharedApplication] runModalForWindow:[self window]];
    if(choice == 1)
        [StdUserDefaults setObject:[dpathField stringValue] forKey:WNDictionaryDefaultsKey];
    [[self window] orderOut:self];

    return choice;
}


//---------------------------------------------------------------------------------------
//	ACTIONS METHODS FOR PANEL
//---------------------------------------------------------------------------------------

- (void)endSession:(id)sender
{
    NSParameterAssert([sender isKindOfClass:[NSMatrix class]]);
    [[NSApplication sharedApplication] stopModalWithCode:[[sender selectedCell] tag]];
}


- (void)setDictionaryPath:(id)sender
{
    NSOpenPanel	*openPanel;
    NSString 	*newPath;

    openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    if([openPanel runModalForTypes:nil] == NSOKButton)
        {
        newPath = [[openPanel filenames] lastObject];
        [dpathField setStringValue:newPath];
        if((noteFlag == YES) && ([newPath isEqualToString:[StdUserDefaults stringForKey:WNDictionaryDefaultsKey]] == NO))
            {
            if([restartNoteBox superview] == nil)
                [[[self window] contentView] addSubview:restartNoteBox];
            }
        else
            {
            if([restartNoteBox superview] != nil)
                [restartNoteBox removeFromSuperview];
            }
        }
}


//=======================================================================================
    @end
//=======================================================================================
