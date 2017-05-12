//---------------------------------------------------------------------------------------
//	WNAppController.m created by erik on Fri 18-Sep-1998
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at http://www.mulle-kybernetik.com/software/WordNet/.
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "WordNetAccess.h"
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
    WNSearchWindowController	*swController;

    [WNController setupWithDatabasePath:[[NSBundle mainBundle] pathForResource:@"Database" ofType:@""]];
    wnController = [[WNController alloc] init];

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
            [NSException raise:NSGenericException format:@"-[%@ %@]: Could not load License NIB file.", NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
        [licenseView setString:[NSString stringWithFormat:@"\nWordNet Database and Software Library License:\n\n%@", [WNController license]]];
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


- (void)gotoWordNetHomepage:(id)sender
{
    if([[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://wordnet.princeton.edu/"]] == NO)
        NSBeep();
}


//=======================================================================================
    @end
//=======================================================================================

