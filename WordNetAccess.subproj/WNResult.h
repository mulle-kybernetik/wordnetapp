//---------------------------------------------------------------------------------------
//	WNResult.h created by erik on Thu 18-Feb-1999
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at http://www.mulle-kybernetik.com/software/WordNet/.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>


@interface WNResult : NSObject
{
    NSString		*word;
    int				posCode;  // pos = part of speech!
    int				typeCode;
}

- (id)initWithWord:(NSString *)aWord posCode:(int)aPosCode typeCode:(int)aTypeCode;

- (NSString *)word;
- (int)posCode;
- (int)typeCode;

- (NSString *)pos;
- (NSString *)type;

@end
