//---------------------------------------------------------------------------------------
//	WNSearchWindowController.h created by erik on Fri 18-Sep-1998
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at <http://www.erik.clara.net>.
//	@(#)$Id: WNSearchWindowController.h,v 1.1.1.1 2000-10-23 23:57:01 erik Exp $
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>

@class WNController;


@interface WNSearchWindowController : NSWindowController
{
    WNController			*wnController;
    NSMutableDictionary		*popUpButtons;
    NSMutableDictionary		*popUpTitles;

    IBOutlet NSComboBox		*inputField;
    IBOutlet NSPopUpButton	*nounPopUp;
    IBOutlet NSPopUpButton	*verbPopUp;
    IBOutlet NSPopUpButton	*adjPopUp;
    IBOutlet NSPopUpButton	*advPopUp;
    IBOutlet NSTextView		*textView;
}

- (id)initWithAccessController:(WNController *)controller;

- (IBAction)runSearch:(id)sender;
- (IBAction)getDetails:(id)sender;
- (IBAction)printResult:(id)sender;

@end
