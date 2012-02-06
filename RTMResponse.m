/*
 *  RTMResponse.m
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
#import "RTMResponse.h"
#import "RTMList.h"

@interface RTMResponse (RTMResponseInternal)
- (NSString *)getStatus;
@end

@implementation RTMResponse

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        NSError *err;
    
        m_xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&err];
        
        if (!m_xmlDoc)
        {
            NSLog(@"error initializing response: %@", err);
            [self dealloc];
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if (m_xmlDoc) [m_xmlDoc release];

    [super dealloc];
}


+ (RTMResponse *)responseWithData:(NSData *)data
{
    return [[[RTMResponse alloc] initWithData:data] autorelease];
}

- (NSString *)getStatus
{
    return [[[m_xmlDoc rootElement] attributeForName:@"stat"] stringValue];
}

- (BOOL)isOk
{
    return [[self getStatus] isEqualToString:@"ok"];
}

- (NSString *)errorMessage
{
    return [self valueForElement:@"err" attribute:@"msg"];
}

- (int)errorCode
{
    return [[self valueForElement:@"err" attribute:@"code"] intValue];
}

- (NSString *)valueForKey:(NSString *)key
{
    return [self valueForXPath:key];
}

- (NSString *)valueForElement:(NSString *)key attribute:(NSString *)attrib
{
    return [self valueForXPath:[NSString stringWithFormat:@"%@/attribute::%@", key, attrib]];
}

- (NSString *)valueForXPath:(NSString *)path
{
    NSArray *elts = [[m_xmlDoc rootElement] nodesForXPath:path error:NULL];
    
    if ([elts count] > 0)
    {
        return [[elts objectAtIndex:0] stringValue];
    }
    else
    {
        return nil;
    }
}

- (NSArray *)lists
{
    NSError *err = nil;
    NSArray *elts = [[m_xmlDoc rootElement] nodesForXPath:@"lists/list[(@deleted=0 and @archived=0) and @smart=0]" error:&err];
    NSEnumerator *eltEnumer = [elts objectEnumerator];
    NSXMLElement *currElt;
    NSMutableArray *resultArray = [NSMutableArray array];
    
    while (currElt = [eltEnumer nextObject])
    {
        [resultArray addObject:ListDescriptionWithXmlElement(currElt)];
    }
    
    return resultArray;
}

@end
