//---------------------------------------------------------------------------------------
//	WNController.m created by erik on Thu 18-Feb-1999
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at <http://www.erik.clara.net>.
//	@(#)$Id: WNController.h,v 1.1.1.1 2000-10-23 23:57:02 erik Exp $
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>


@interface WNController : NSObject
{
}

+ (void)setupWithDictionaryPath:(NSString *)aPath;
+ (NSString *)license;

+ (void)setResultClass:(Class)aClass;
+ (Class)resultClass;

+ (NSString *)posNameForCode:(int)code;
+ (NSString *)typeNameForCode:(int)code;

- (NSArray *)runSearchForWord:(NSString *)word;
- (NSString *)getDetailsForResult:(id)result;  // bridget doesn't like WNResult...
- (NSString *)getDetailsForWord:(NSString *)word posCode:(int)posCode typeCode:(int)typeCode;

@end
