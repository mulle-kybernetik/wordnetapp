//---------------------------------------------------------------------------------------
//	EDApplication.m created by erik on Sun 19-Jul-1998
//	This code was written by Erik Doernenburg <erik@x101.net>. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	@(#)$Id: EDApplication.m,v 1.1.1.1 2000-10-23 23:57:01 erik Exp $
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "EDApplication.h"

@interface EDApplication(PrivateAPI)
- (void)_registerFactoryDefaults;
@end


//---------------------------------------------------------------------------------------
    @implementation EDApplication
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

- (void)finishLaunching
{
    [self _registerFactoryDefaults];
    [super finishLaunching];
}


- (void)reportException:(NSException *)theException;
{
    NSString *appName;

    appName = [self name];
    NSLog(@"%@: %@", [theException name], [theException reason]);
    NSRunAlertPanel(nil, NSLocalizedString(@"An unexpected error has occured which may cause %@ to malfunction. You may want to save copies of your open documents and quit %@.\n\n%@: %@", "Text for the alert panel to report uncaught exceptions."), NSLocalizedString(@"OK", "For buttons in alert panels."), nil, nil, appName, appName, [theException name], [theException reason]);
}


//---------------------------------------------------------------------------------------
//	ADDITIONAL FUNCTIONALITY
//---------------------------------------------------------------------------------------

- (NSString *)name
{
    return [[NSProcessInfo processInfo] processName];
}


- (void)openURL:(NSString *)url;
{
    NSPasteboard 	*pboard;
    NSString 		*sname;

    pboard = [NSPasteboard pasteboardWithName:@"URLServicePasteboard"];
    [pboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pboard setString:url forType:NSStringPboardType];

    if((sname = [[NSUserDefaults standardUserDefaults] stringForKey:@"URLService"]) == nil)
        sname = @"OmniWeb/Open URL";
    NSPerformService(sname, pboard);		
}


//---------------------------------------------------------------------------------------
//	PRIVATE HELPER
//---------------------------------------------------------------------------------------

- (void)_registerFactoryDefaults
{
    NSString		*resourcePath;
    NSDictionary	*factorySettings;

    resourcePath = [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"];
    NSAssert(resourcePath != nil, @"missing resource; cannot find FactoryDefaults");
    NS_DURING
        factorySettings = [[NSString stringWithContentsOfFile:resourcePath] propertyList];
    NS_HANDLER
        factorySettings = nil;
    NS_ENDHANDLER
    if([factorySettings isKindOfClass:[NSDictionary class]] == NO)
        [NSException raise:NSGenericException format:@"Damaged resource; FactoryDefaults does not contain a valid dictionary representation."];
    [[NSUserDefaults standardUserDefaults] registerDefaults:factorySettings];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
