//---------------------------------------------------------------------------------------
//  EDApplication.h created by erik on Sun 19-Jul-1998
//	This code was written by Erik Doernenburg <erik@x101.net>. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	@(#)$Id: EDApplication.h,v 1.1.1.1 2000-10-23 23:57:01 erik Exp $
//---------------------------------------------------------------------------------------

#import <AppKit/NSApplication.h>

@interface EDApplication : NSApplication
{
}

- (NSString *)name;
- (void)openURL:(NSString *)url;

@end
