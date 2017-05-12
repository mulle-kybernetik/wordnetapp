//---------------------------------------------------------------------------------------
//	WNResult.m created by erik on Thu 18-Feb-1999
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at http://www.mulle-kybernetik.com/software/WordNet/.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "WNController.h"
#import "WNResult.h"


//=======================================================================================
    @implementation WNResult
//=======================================================================================

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithWord:(NSString *)aWord posCode:(int)aPosCode typeCode:(int)aTypeCode
{
    [super init];
    posCode = aPosCode;
    typeCode = aTypeCode;
    word = [aWord copyWithZone:[self zone]];
    return self;
}


- (void)dealloc
{
    [word release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS (IMMUTABLE ATTRIBUTES)
//---------------------------------------------------------------------------------------

- (NSString *)word
{
    return word;
}


- (int)posCode
{
    return posCode;
}


- (int)typeCode
{
    return typeCode;
}


//---------------------------------------------------------------------------------------
//	DERIVED ATTRIBUTES
//---------------------------------------------------------------------------------------

- (NSString *)pos
{
    return [WNController posNameForCode:posCode];
}


- (NSString *)type
{
    return [WNController typeNameForCode:typeCode];
}


//=======================================================================================
    @end
//=======================================================================================
