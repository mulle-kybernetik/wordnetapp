//---------------------------------------------------------------------------------------
//	WNController.m created by erik on Thu 18-Feb-1999
//	This code is part of the WordNet frontend by Erik Doernenburg. For copyright details
//	see GNU public license version 2 or above. No warranties implied. Use at own risk.
//	More information can be found at <http://www.erik.clara.net>.
//	@(#)$Id: WNController.m,v 1.1.1.1 2000-10-23 23:57:02 erik Exp $
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "wn.h"
#import "wnhelp.h"
#import "license.h"
#import "WNResult.h"
#import "WNController.h"

@interface WNController(PrivateAPI)
- (void)_addDescriptionsOfResult:(unsigned long)search forWord:(const char *)word:(int)pos toSet:(NSMutableArray *)resultSet;
@end


//=======================================================================================
    @implementation WNController
//=======================================================================================


//---------------------------------------------------------------------------------------
//	RESULT CLASS
//---------------------------------------------------------------------------------------

/* Allows clients of WNController to specify a subclass of WNResult that is used when results are returned. This feature is not used in the AppKit front-end but this subproject is also part of the more general WordNetAccess framework which is used for the web front-end. There would have been other design patterns to augment the result info, embedding WNResult in another object for example, but, given that the framework is wrapped and the web front-end is written in java, it is a cool demonstration of how well the java bridge works. (The web front-end implements a java subclass of WNResult and invokes WNController.setResultClass() with this class!)
*/

static Class resultClass;


+ (void)setResultClass:(Class)aClass
{
    if([[[[aClass alloc] initWithWord:@"" posCode:0 typeCode:0] autorelease] isKindOfClass:[WNResult class]] == NO)
        [NSException raise:NSInvalidArgumentException format:@"+[%@ %@]: Invalid result class %@; must inherit from WNResult.", NSStringFromClass(self), NSStringFromSelector(_cmd), NSStringFromClass(aClass)];
    NSLog(@"using result class %@", NSStringFromClass(aClass));
    resultClass = aClass;
}


+ (Class)resultClass
{
    return resultClass;
}


//---------------------------------------------------------------------------------------
//	WNLIB FEATURES
//---------------------------------------------------------------------------------------

+ (void)setupWithDictionaryPath:(NSString *)aPath
{
    NSLog(@"setting up with path \"%@\"", aPath);
    setenv("WNSEARCHDIR", [aPath cString], 1);
    resultClass = [WNResult class];
    if(wninit() != 0)
        [NSException raise:NSInvalidArgumentException format:@"+[%@ %@]: Cannot initialise the database access library. Make sure that you've set the correct path to your WordNet dictionary installation.", NSStringFromClass(self), NSStringFromSelector(_cmd)];
}


+ (NSString *)license
{
    if(dblicense); // avoid warning
    return [NSString stringWithCString:license];
}


//---------------------------------------------------------------------------------------
//	NAME LOOKUP
//---------------------------------------------------------------------------------------

+ (NSString *)posNameForCode:(int)code
{
    return [NSString stringWithCString:partnames[code]];
}


+ (NSString *)typeNameForCode:(int)code
{
    return [[NSBundle bundleForClass:[WNController class]] localizedStringForKey:[NSString stringWithFormat:@"%02d", code] value:@"-" table:@"SearchTypes"];
}


//---------------------------------------------------------------------------------------
//	RUNNING SEARCHES
//---------------------------------------------------------------------------------------

- (NSArray *)runSearchForWord:(NSString *)word
{
    NSMutableArray		*resultSet;
    char				*searchword, *morphword;
    int					i;
    unsigned long 		search;
    BOOL				foundOne = NO;

    resultSet = [[[NSMutableArray allocWithZone:[self zone]] init] autorelease];

    searchword = strdup([word lossyCString]);
    strtolower(strsubst(searchword, ' ', '_'));
    for (i = 1; i <= NUMPARTS; i++)
        {
        if((search = is_defined(searchword, i)) != 0)
            {
            [self _addDescriptionsOfResult:search forWord:searchword:i toSet:resultSet];
            foundOne = YES;
            }	
        morphword = morphstr(searchword, i);
        while(morphword != NULL)
            {
            if((search = is_defined(morphword, i)) != 0)
                {
                [self _addDescriptionsOfResult:search forWord:morphword:i toSet:resultSet];
                foundOne = YES;
                }	

            morphword = morphstr(NULL, i);
            }
        }
    free(searchword);

    return ([resultSet count] > 0) ? resultSet : nil;
}


- (void)_addDescriptionsOfResult:(unsigned long)search forWord:(const char *)word:(int)pos toSet:(NSMutableArray *)resultSet
{	
    WNResult	*result;
    int			j;

    for(j = 1; j <= MAXSEARCH; j++)
        {
        if((search & bit(j)) && ([[[self class] typeNameForCode:j] isEqual:@"-"] == NO))
            {
            result = [[[resultClass allocWithZone:[self zone]] initWithWord:[NSString stringWithCString:word] posCode:pos typeCode:j] autorelease];
            [resultSet addObject:result];
            }
        }
}


- (NSString *)getDetailsForResult:(WNResult *)result
{
    return [self getDetailsForWord:[result word] posCode:[result posCode] typeCode:[result typeCode]];
}


- (NSString *)getDetailsForWord:(NSString *)word posCode:(int)posCode typeCode:(int)typeCode;
{
    const char	 *outbuf;

    outbuf = findtheinfo((char *)[word cString], posCode, typeCode, ALLSENSES);

    return [NSString stringWithCString:outbuf];
}


//=======================================================================================
    @end
//=======================================================================================

