/*
 *  RTMMethodCall.m
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

#import "RTMMethodCall.h"
#import "RTMCommon.h"
#import "RTMAdditions.h"
#import "RTMResponse.h"

@interface RTMMethodCall (RTMMethodPrivate)

@end

@implementation RTMMethodCall

- (id)initWithMethod:(NSString *)method
{
    self = [super init];
    if (self)
    {
        m_params = [[NSMutableDictionary alloc] init];
        
        [m_params setValue:method forKey:kRTMMethodKey];
        [m_params setValue:RTMGetApiKey() forKey:kRTMApiKeyKey];
    }
    return self;
}

- (void)dealloc
{
    [m_params release];

    [super dealloc];
}

+ (RTMMethodCall *)callWithMethod:(NSString *)method
{
    return [[[RTMMethodCall alloc] initWithMethod:method] autorelease];
}

- (NSString *)method
{
    return [m_params valueForKey:kRTMMethodKey];
}

- (NSString *)getArgument:(NSString *)argName
{
    return [m_params valueForKey:argName];
}

- (void)setArgumentsWithDictionary:(NSDictionary *)dict
{
    [m_params setValuesForKeysWithDictionary:dict];
}

- (void)setArgument:(NSString *)argName toValue:(NSString *)val
{
    [m_params setValue:val forKey:argName];
}

- (void)sign
{
    NSString *sig;
    
    // compute my signature
    sig = [m_params rtmSignature];
    
    // and set it as the api_sig parameter
    if (sig)
    {
        [m_params setValue:sig forKey:kRTMApiSignatureKey];
    }
}

- (void)unsign
{
    [m_params removeObjectForKey:kRTMApiSignatureKey];
}

- (BOOL)isSigned
{
    return [[m_params allKeys] containsObject:kRTMApiSignatureKey];
}

- (RTMResponse *)invokeSynchronously
{
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.rememberthemilk.com/services/rest/?%@",
                                                                        [m_params urlQueryString]]];
                                                                        
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:requestUrl];
    NSURLResponse *theResponse;
    NSData *resultData;
    NSError *err;
    
    resultData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&theResponse error:&err];
    
    if (resultData)
    {
        return [RTMResponse responseWithData:resultData];
    }
    else
    {
        NSLog(@"Remember the Milk: Error invoking method call: %@", err);
        return nil;
    }
}


@end
