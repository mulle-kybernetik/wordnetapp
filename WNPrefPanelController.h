//---------------------------------------------------------------------------------------
//	WNPrefPanelController.h created by erik on Sun 11-Apr-1999
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at <http://www.erik.clara.net>.
//	@(#)$Id: WNPrefPanelController.h,v 1.1.1.1 2000-10-23 23:57:01 erik Exp $
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>

@interface WNPrefPanelController : NSWindowController
{
    IBOutlet NSTextField	*dpathField;
    IBOutlet NSBox			*restartNoteBox;
    BOOL					noteFlag;
}

+ (id)prefPanelController;
- (int)runModalDisplayRestartNote:(BOOL)flag;

- (IBAction)endSession:(id)sender;
- (IBAction)setDictionaryPath:(id)sender;

@end
