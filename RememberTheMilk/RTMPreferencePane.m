/*
 *  RTMPreferencePane.h
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

#import "RTMPreferencePane.h"
#import "RememberTheMilk.h"

@interface RTMPreferencePane (RTMPreferencePaneInternal)
- (void)setAuthorizedMessageFor:(NSString *)name;
@end

@implementation RTMPreferencePane
- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)mainViewDidLoad
{
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"QSRTMToken"];
    
    if ([token length] == 0)
    {
        [m_startButton setEnabled:YES];
        [m_finishButton setEnabled:NO];
        [m_authLabel setStringValue:@"Begin authorization by clicking Start."];
    }
    else
    {
        [m_startButton setEnabled:NO];
        [m_finishButton setEnabled:NO];
        [self setAuthorizedMessageFor:[[NSUserDefaults standardUserDefaults] valueForKey:@"QSRTMAuthName"]];
    }
}

- (void)setAuthorizedMessageFor:(NSString *)name
{
    [m_authLabel setStringValue:[NSString stringWithFormat:@"Successfully authorized to access %@'s account.", name]];
}

- (IBAction)authenticateRTM:(id)sender
{
    NSURL *authURL;

    [m_startButton setEnabled:NO];
    [m_finishButton setEnabled:YES];
    [m_authLabel setStringValue:@"Please log in and grant permission to access Remember The Milk."];

    m_frob = [GetFrob() retain];
    authURL = CreateAuthenticationURL(m_frob, @"delete");

    [[NSWorkspace sharedWorkspace] openURL:authURL];
}

- (IBAction)wasAuthenticated:(id)sender
{
    [m_finishButton setEnabled:NO];
    [m_authLabel setStringValue:@"Completing authorization..."];

    RTMMethodCall *call = [RTMMethodCall callWithMethod:@"rtm.auth.getToken"];
    [call setArgument:@"frob" toValue:m_frob];
    [call sign];
    
    RTMResponse *resp = [call invokeSynchronously];
    
    if (resp && [resp isOk])
    {
        NSString *name;
        NSString *token;
        
        token = [resp valueForXPath:@"auth/token"];
        name = [resp valueForXPath:@"auth/user/attribute::fullname"];
    
        [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"QSRTMToken"];
        [[NSUserDefaults standardUserDefaults] setValue:name forKey:@"QSRTMAuthName"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"QSRTMTimeline"];
    
        [self setAuthorizedMessageFor:name];
    }
    else
    {
        [m_finishButton setEnabled:YES];
        [m_authLabel setStringValue:[NSString stringWithFormat:@"There was an error (%@).  Make sure you have given this plugin permission to access Remember The Milk.",
                                                    [resp errorMessage]]];
    }
}

- (IBAction)resetAuth:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"QSRTMToken"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"QSRTMAuthName"];
    
    [self mainViewDidLoad];
}

@end
