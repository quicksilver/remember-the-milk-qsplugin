/*
 *  RTMSession.m
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

#import "RTMSession.h"
#import "RTMMethodCall.h"
#import "RTMResponse.h"
#import "RTMCommon.h"
#import "RTMList.h"
#import "NSCalendarDate+ISO8601Parsing.h"

@interface RTMSession (RTMSessionPrivate)
@end

@implementation RTMSession

- (id)initWithToken:(NSString *)token
{
    self = [super init];
    if (self)
    {
        m_token = [token retain];
        m_timeline = nil;
        m_expired = NO;
        
        m_cachedListsResponse = nil;
        m_cachedListsCreationTime = nil;
            
    }
    return self;
}

- (BOOL)hasExpired
{
    return m_expired;
}

- (NSString *)token
{
    return m_token;
}

- (NSString *)getTimeline
{
    if (!m_timeline)
    {
        m_timeline = [[self createTimeline] retain];
    }

    return m_timeline;
}

- (NSString *)createTimeline
{
    NSString *error;
    RTMResponse *resp = [self callAndVerifyAuthenticatedMethod:@"rtm.timelines.create" 
                                                 withArguments:[NSDictionary dictionary]
                                                         error:&error];

    if (resp)
    {
        NSString *timeline = [resp valueForXPath:@"timeline"];
    
        [[NSUserDefaults standardUserDefaults] setValue:timeline forKey:@"QSRTMTimeline"];
        
        return timeline;
    }
    else
    {
        NSLog(@"RTM: There was an error (%@) getting a new timeline", error);
        return nil;
    }
}

- (NSArray *)getLists
{
    // cache this to avoid multiple consecutive queries (add time condition)
    
    if (m_cachedListsResponse != nil && m_cachedListsCreationTime != nil)
    {
        if ([[NSDate date] timeIntervalSinceDate:m_cachedListsCreationTime] <= 60.0)
        {
            return [m_cachedListsResponse lists];
        }
        else // expire cache
        {
            [m_cachedListsResponse release];
            m_cachedListsResponse = nil;
            
            [m_cachedListsCreationTime release];
            m_cachedListsCreationTime = nil;
        }
    }
    
    NSString *error;
    RTMResponse *resp = [self callAndVerifyAuthenticatedMethod:@"rtm.lists.getList" 
                                                 withArguments:[NSDictionary dictionary]
                                                         error:&error];

    if (resp)
    {
        m_cachedListsResponse = [resp retain];
        m_cachedListsCreationTime = [[NSDate date] retain];
    
        return [resp lists];
    }
    else
    {
        NSLog(@"RTM: There was an error (%@) getting a list of lists", error);
        return nil;
    }
}

- (NSDictionary *)addTask:(NSString *)todo toList:(NSDictionary *)list parse:(BOOL)parse error:(NSString **)err
{
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithObjectsAndKeys:(parse?@"1":@"0"), @"parse", todo, @"name", [self getTimeline], @"timeline", nil];

    if (list)
    {
        [args setValue:[list valueForKey:kRTMListIDKey] forKey:@"list_id"];
    }

    RTMResponse *resp = [self callAndVerifyAuthenticatedMethod:@"rtm.tasks.add" 
                                                 withArguments:args
                                                         error:err];
    
    if (resp)
    {
        NSMutableDictionary *taskDesc = [NSMutableDictionary dictionary];
        NSString *dueDateString = [resp valueForXPath:@"list/taskseries/task/attribute::due"];
        NSString *hasDueTimeString = [resp valueForXPath:@"list/taskseries/task/attribute::has_due_time"];
        
        [taskDesc setObject:[resp valueForXPath:@"list/taskseries/attribute::name"] forKey:kRTMTaskNameKey];
        
        if ([dueDateString length] > 0)
        {
            NSCalendarDate *dateObj = [NSCalendarDate calendarDateWithString:dueDateString strictly:YES];
            
            [taskDesc setObject:dateObj forKey:kRTMTaskDueDateKey];
            [taskDesc setObject:[NSNumber numberWithBool:[hasDueTimeString isEqualToString:@"1"]] forKey:kRTMTaskHasDueTimeKey];
        }
        
        return [NSDictionary dictionaryWithDictionary:taskDesc];
    }
    else
    {
        return nil;
    }
}

- (RTMResponse *)callAndVerifyAuthenticatedMethod:(NSString *)method 
                                    withArguments:(NSDictionary *)dict
                                            error:(NSString **)error
{
    if (error) *error = NULL; 
    
    RTMMethodCall *call = [RTMMethodCall callWithMethod:method];
    [call setArgument:@"auth_token" toValue:[self token]];
    [call setArgumentsWithDictionary:dict];
    [call sign];
    
    RTMResponse *resp = [call invokeSynchronously];
    
    if (resp && [resp isOk])
    {    
        return resp;
    }
    else
    {
        
        if (resp)
        {
            if ([resp errorCode] == kRTMInvalidLoginError)
            {
                // most likely the user has revoked authorization
                m_expired = YES;
            }

            if (error)
            {
                *error = [resp errorMessage];
            }
        }
        
        return nil;
    }
}

@end
