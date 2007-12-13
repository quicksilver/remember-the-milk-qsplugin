/*
 *  RTMAdditions.m
 *  
 *  Copyright 2007 Brian Moore. All rights reserved.
 *
 *  This file is part of QSRememberTheMilk.
 *
 *  Redistribution and use in source and binary forms, with or without 
 *  modification, are permitted provided that the following conditions 
 *  are met:
 *
 *  * Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright 
 *      notice, this list of conditions and the following disclaimer in the 
 *      documentation and/or other materials provided with the distribution.
 *  * Neither the name of Binary Minded Software nor the names of its 
 *      contributors may be used to endorse or promote products derived from 
 *      this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 *  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

#import "RTMAdditions.h"
#import "RTMCommon.h"

#import <openssl/md5.h>

@implementation NSDictionary (RTMDictionaryAdditions)

- (NSString *)urlQueryString
{
    // make string like foo=bar&baz=boa
    NSMutableString *queryString;
    NSEnumerator *keyEnum;
    NSString *currentKey;
    id currentValue;
    NSString *currentValueString;
    BOOL isNotFirst;
    
    queryString = [NSMutableString string];
    keyEnum = [self keyEnumerator];
    
    isNotFirst = NO;
    while (currentKey = [keyEnum nextObject])
    {
        currentValue = [self valueForKey:currentKey];
        
        // make sure it's a string (guess i could have used assert here)
        if ([[currentValue class] isSubclassOfClass:[NSString class]])
        {
            currentValueString = (NSString*)currentValue;
            
            if (isNotFirst)
            {
                [queryString appendString:@"&"];
            }
            else
            {
                isNotFirst = YES;
            }
            
            [queryString appendString:[currentKey stringByAddingQueryEscapes]];
            [queryString appendString:@"="];
            [queryString appendString:[currentValueString stringByAddingQueryEscapes]];
        }
        else
        {
            NSLog(@"The dictionary %@ cannot be turned into a url query string because it contains a non-string value", self);
            return nil;
        }
    }
    
    return queryString;
}

- (NSString *)rtmSignature
{
    // as described on http://www.rememberthemilk.com/services/api/authentication.rtm
    NSArray *sortedKeys;
    NSMutableString *concatString;
    id currentValue;
    NSString *currentValueString;
    NSString *currentKey;
    NSEnumerator *keyEnumer;
    
    // "Sort your parameters by key name"
    sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // "Concatenate the previous result onto your shared secret" (ok, it's out of order, but this still works)
    concatString = [NSMutableString stringWithString:RTMGetSharedSecret()];
    
    // "Construct a string with all key/value pairs concatenated together"
    keyEnumer = [sortedKeys objectEnumerator];
    
    while (currentKey = [keyEnumer nextObject])
    {
        // exclude the api_sig parameter
        if (![currentKey isEqualToString:kRTMApiSignatureKey])
        {
            // get the value
            currentValue = [self valueForKey:currentKey];
            
            // assert it's a string
            if ([[currentValue class] isSubclassOfClass:[NSString class]])
            {
                currentValueString = (NSString*)currentValue;
                
                // concatenate key and value to string
                [concatString appendString:currentKey];
                [concatString appendString:currentValueString];

            }
        }
    }
    
    // "Calculate the MD5 hash of this string"
    return [concatString md5];
}


@end



@implementation NSString (RTMStringAdditions)

- (NSString *)md5
{
    const char *utf8Str;
    unsigned long len;
    NSMutableString *hexString;
    int i;
    
    utf8Str = (const char *)[self UTF8String];
    if (!utf8Str)
    {
        NSLog(@"-[NSString UTF8String] returned null");
        return nil;
    }
    
    len = strlen(utf8Str);
    
    unsigned char *md5Data = MD5((unsigned const char *)utf8Str, len, NULL);
    
    if (!md5Data)
    {
        NSLog(@"MD5 returned null");
        return nil;
    }
    
    hexString = [NSMutableString string];
    
    for (i=0; i<MD5_DIGEST_LENGTH; i++)
    {
        [hexString appendFormat:@"%02x", md5Data[i]];
    }
    
    return hexString;
}

- (NSString *)stringByAddingQueryEscapes
{
    NSString *escaped;
    
    escaped = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
    
    return [escaped autorelease];
}

@end
