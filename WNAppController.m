//---------------------------------------------------------------------------------------
//	WNAppController.m created by erik on Fri 18-Sep-1998
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at <http://www.erik.clara.net>.
//	@(#)$Id: WNAppController.m,v 1.4 2001-03-30 00:20:33 znek Exp $
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "EDApplication.h"
#import "WordNetAccess.h"
#import "Constants.h"
#import "WNPrefPanelController.h"
#import "WNSearchWindowController.h"
#import "WNAppController.h"


//=======================================================================================
    @implementation WNAppController
//=======================================================================================


//---------------------------------------------------------------------------------------
//	APP CONFIGURATION
//---------------------------------------------------------------------------------------

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    WNPrefPanelController 		*ppController = nil;
    WNSearchWindowController	*swController;
    
    do
        {
        NS_DURING
            [WNController setupWithDictionaryPath:[[NSUserDefaults standardUserDefaults] stringForKey:WNDictionaryDefaultsKey]];
            wnController = [[WNController alloc] init];
        NS_HANDLER
            if(ppController == nil)
                ppController = [WNPrefPanelController prefPanelController];
            else
                NSBeep();
            if([ppController runModalDisplayRestartNote:NO] == 0)
                [[NSApplication sharedApplication] terminate:self];
        NS_ENDHANDLER
        }
    while(wnController == nil);

    swController = [[WNSearchWindowController alloc] initWithAccessController:wnController];
    [swController showWindow:self];
    [[NSApplication sharedApplication] setServicesProvider:swController];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}


//---------------------------------------------------------------------------------------
//	INFO, LICENSE, ETC.
//---------------------------------------------------------------------------------------

- (void)showAboutPanel:(id)sender
{
    extern double	WordNetVersionNumber;
    NSDictionary 	*options;

    options = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%g", WordNetVersionNumber] forKey:@"Version"];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}


- (void)showLicense:(id)sender
{
    if(licensePanel == nil)
        {
        if([NSBundle loadNibNamed:@"License" owner:self] == NO)
            [NSException raise:NSGenericException format:@"-[%@ %@]: Could not load License NIB file.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
       [licenseView setString:[NSString stringWithFormat:@"Database and Software Library License:\n\n%@", [WNController license]]];
        [licensePanel center];
        }
    [licensePanel makeKeyAndOrderFront:self];
}


- (void)windowWillClose:(NSNotification *)aNotification;
{
    NSWindow *window = [aNotification object];

    if(window == licensePanel)
        {
        [licensePanel autorelease];
        licensePanel = nil;
        }
}


- (IBAction)setPreferences:(id)sender
{
    [[WNPrefPanelController prefPanelController] runModalDisplayRestartNote:YES];
}


- (void)gotoWordNetHomepage:(id)sender
{
    [(EDApplication *)[NSApplication sharedApplication] openURL:@"http://www.cogsci.princeton.edu/%7Ewn/"];
}


//=======================================================================================
    @end
//=======================================================================================

