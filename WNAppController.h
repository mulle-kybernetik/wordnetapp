//---------------------------------------------------------------------------------------
//	WNController.h created by erik on Fri 18-Sep-1998
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at http://www.mulle-kybernetik.com/software/WordNet/.
//	@(#)$Id: WNAppController.h,v 1.2 2003-11-03 12:42:03 znek Exp $
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>

@class WNController;


@interface WNAppController : NSObject
{
    IBOutlet NSPanel		*licensePanel;
    IBOutlet NSText			*licenseView;
    WNController			*wnController;
}

- (IBAction)showAboutPanel:(id)sender;
- (IBAction)showLicense:(id)sender;
- (IBAction)setPreferences:(id)sender;
- (IBAction)gotoWordNetHomepage:(id)sender;

@end
