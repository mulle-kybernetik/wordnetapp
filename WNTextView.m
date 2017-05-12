//---------------------------------------------------------------------------------------
//	WNTextView.m created by erik on Sat 19-Sep-1998
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at http://www.mulle-kybernetik.com/software/WordNet/.
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "WNTextView.h"


//=======================================================================================
    @implementation WNTextView
//=======================================================================================

NSString *WNTextViewDoubleClickNotification = @"WNTextViewDoubleClickNotification";


//---------------------------------------------------------------------------------------
//	MOUSE DOWN OVERRIDE
//---------------------------------------------------------------------------------------

- (void)mouseDown:(NSEvent *)theEvent
{
    NSRange	selRange;
    NSString *selection;
    
    [super mouseDown:theEvent];
    if([theEvent clickCount] == 2)
        {
        selRange = [self selectedRange];
        selection = [[[self textStorage] attributedSubstringFromRange:selRange] string];
        [[NSNotificationCenter defaultCenter] postNotificationName:WNTextViewDoubleClickNotification object:self userInfo:[NSDictionary dictionaryWithObject:selection forKey:@"selection"]]; 
        }
}

//=======================================================================================
    @end
//=======================================================================================
