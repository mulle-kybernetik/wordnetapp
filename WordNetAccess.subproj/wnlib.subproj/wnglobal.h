/*

   wnglobals.h - global variables used by various WordNet applications

   $Id: wnglobal.h,v 1.1.1.1 2000-10-23 23:57:02 erik Exp $

*/

#ifndef _WNGLOBALS_
#define _WNGLOBALS_

#include <stdio.h>

extern char *wnrelease;		/* WordNet release/version number */

extern char *lexfiles[];	/* names of lexicographer files */
extern char *ptrtyp[];		/* pointer characters */
extern char *partnames[];	/* POS strings */
extern char partchars[];	/* single chars for each POS */
extern char *adjclass[];	/* adjective class strings */
extern char *frametext[];	/* text of verb frames */


#endif /* _WNGLOBALS_ */
