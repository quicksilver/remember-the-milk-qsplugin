/*
 *  QSRTMController.m
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

#import "QSRTMController.h"
#import <QSCore/QSNotifyMediator.h>

static QSRTMController *g_rtmController = nil;

void QSRTMNotify(NSString *message)
{
    QSShowNotifierWithAttributes([NSDictionary dictionaryWithObjectsAndKeys:@"Remember The Milk", QSNotifierTitle,
                                                                                message, QSNotifierText,
                                                                                [QSResourceManager imageNamed:@"Cow"], QSNotifierIcon,
                                                                                nil]);
}

@implementation QSRTMController

+ (QSRTMController *)sharedInstance
{
    if (!g_rtmController)
    {
        
        g_rtmController = [[QSRTMController alloc] init];
    }
    
    return g_rtmController;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        #error Please obtain an API key from www.rememberthemilk.com and enter it here
        // yeah, sorry about that
        RTMInit(@"My API Key", @"My Shared Secret");
        
        m_session = nil;
    }
    return self;
}

// this method may have too many side effects
- (RTMSession *)getSessionWithError:(NSString **)errorString
{
    if (!m_session) // there's no session object, try to make one
    {
        // look up a stored token in preferences
        NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"QSRTMToken"];
        
        // if there was a possibly valid token in prefs, use it to make a new session
        if ([token length] > 0)
        {
            m_session = [[RTMSession alloc] initWithToken:token];
            
            return m_session;
        }
        else // no stored token.  must authenticate.
        {
            if (errorString)
                *errorString = @"You must authenticate this plugin in preferences before use.";
            
            return nil;
        }
    }
    else // there is a session already
    {
        if (![m_session hasExpired]) // has the session expired?
        {
            NSString *prefToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"QSRTMToken"];
        
            // what about the token?  does it match what's in prefs?
            if ([[m_session token] isEqualToString:prefToken])
            {
                return m_session;
            }
            else // the token has changed. kill this session, make a new one
            {
                [m_session release];
                m_session = nil;
                
                m_session = [[RTMSession alloc] initWithToken:prefToken];
                
                return m_session;
            }            
        }
        else // if the session has expired, kill the session, tell the user to reauth and erase the stored token
        {
            // TODO: verify that the problem actually lies with the token (w/ rtm.auth.checkToken)
        
            if (errorString)
                *errorString = @"Authentication has expired. You must reauthenticate to continue using this plugin.";
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"QSRTMToken"];
        
            [m_session release];
            m_session = nil;
            
            return nil;
        }
    }
}

- (NSArray *)mapListsToQObjects:(NSArray *)lists
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[lists count]];
    NSEnumerator *enumer = [lists objectEnumerator];
    NSDictionary *currListInfo = nil;
    QSObject *currObject = nil;
    
    while (currListInfo = [enumer nextObject])
    {
        currObject = [QSObject objectWithName:[currListInfo valueForKey:@"name"]];
        
        [currObject setObject:currListInfo forType:kRTMListType];
        [currObject setObject:@"Remember The Milk List" forMeta:kQSObjectDetails];
        [currObject setPrimaryType:kRTMListType];
        [currObject setIdentifier:[NSString stringWithFormat:@"[RememberTheMilkList]:ID=%@", [currListInfo valueForKey:@"id"]]];
        
        [arr addObject:currObject];
    }
    
    return [NSArray arrayWithArray:arr];
}

@end
