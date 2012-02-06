/*
 *  RememberTheMilkSource.m
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

#import "RememberTheMilkSource.h"
#import <QSCore/QSObject.h>
#import "QSRTMController.h"
#import "RTMSession.h"

@implementation RememberTheMilkSource
- (id)init
{
    self = [super init];
    if (self)
    {
        m_controller = [QSRTMController sharedInstance];
    }
    return self;
}

- (BOOL)isVisibleSource
{
    return YES;
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return NO;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}


// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object{
//    return nil;
//}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry
{
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
      
    RTMSession *session = [m_controller getSessionWithError:NULL];
      
    if (session)
    {
        return [m_controller mapListsToQObjects:[session getLists]];
    }
    else
    {
        return nil;
    }
}


// Object Handler Methods


- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"Cow"]]; // An icon that is either already in memory or easy to load
}
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
}

@end
