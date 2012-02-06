/*
 *  RTMCommon.m
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

#import "RTMCommon.h"
#import "RTMMethodCall.h"
#import "RTMResponse.h"

static NSString *g_rtmApiKey = NULL;
static NSString *g_rtmSharedSecret = NULL;

void RTMInit(NSString *apiKey, NSString *sharedSecret)
{
    if (apiKey == NULL || sharedSecret == NULL)
    {
        NSLog(@"Remember The Milk Error: Please call RTMInit with non-NULL strings.");
    }
    else if (g_rtmApiKey != NULL || g_rtmSharedSecret != NULL)
    {
        NSLog(@"Remember The Milk Error: Please call RTMInit only once!");
    }
    else
    {
        g_rtmApiKey = [apiKey retain];
        g_rtmSharedSecret = [sharedSecret retain];
    }
}

NSString *RTMGetApiKey()
{
    if (g_rtmApiKey == NULL)
    {
        NSLog(@"Remember The Milk Error: You must provide an API key and shared secret with RTMInit");
    }
    
    return g_rtmApiKey;
}

NSString *RTMGetSharedSecret()
{
    if (g_rtmSharedSecret == NULL)
    {
        NSLog(@"Remember The Milk Error: You must provide an API key and shared secret with RTMInit");
    }
    
    return g_rtmSharedSecret;
}

NSURL *CreateAuthenticationURL(NSString *frob, NSString *perms)
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:RTMGetApiKey(), kRTMApiKeyKey,
                                                                      perms, @"perms", 
                                                                      frob, @"frob", nil];
                                                                      
    NSString *sig = [params rtmSignature];
    
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"https://www.rememberthemilk.com/services/auth/?%@&api_sig=%@",
                                       [params urlQueryString],
                                       sig]];
}

NSString *GetFrob()
{
    RTMMethodCall *call = [RTMMethodCall callWithMethod:@"rtm.auth.getFrob"];
    [call sign];
    
    RTMResponse *response = [call invokeSynchronously];
    
    if (response)
    {
        if ([response isOk])
        {
            return [response valueForKey:@"frob"];
        }
        else
        {
            NSLog(@"Remember the Milk: error getting frob; %@", [response errorMessage]);
            return nil;
        }
    }
    else
    {
        NSLog(@"Remember the Milk: error getting frob, response is nil");
        return nil;
    }
}