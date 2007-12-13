/*
 *  RememberTheMilkAction.m
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

#import "RememberTheMilkAction.h"
#import "RememberTheMilk.h"
#import <QSCore/QSTextProxy.h>

#import "QSRTMController.h"
#import "RTMList.h"

@interface RememberTheMilkAction (RememberTheMilkActionPrivate)

@end

@implementation RememberTheMilkAction

#define kRTMAddTaskAction @"RTMAddTaskAction"
#define kRTMReverseAddTaskAction @"RTMReverseAddTaskAction"

- (id)init
{
    self = [super init];
    if (self)
    {
        m_controller = [QSRTMController sharedInstance];
        
        
    }
    return self;
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
{
    if ([[dObject primaryType] isEqualToString:kRTMListType]) 
    {
        return [NSArray arrayWithObject:kRTMReverseAddTaskAction];
    }
    else return [NSArray arrayWithObject:kRTMAddTaskAction];
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject
{
    if ([action isEqualToString:kRTMAddTaskAction])
    {    
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
    else
    {
        return [NSArray arrayWithObject:[QSObject textProxyObjectWithDefaultValue:@""]];
    }
}

- (QSObject *)newTaskWithText:(QSObject *)dObject inList:(QSObject *)iObject
{
    NSString *errorStr = NULL;
    RTMSession *session = [m_controller getSessionWithError:&errorStr];

    if (session)
    {
        NSString *err = @"";
        NSDictionary *listInfo = nil;
        BOOL shouldParse = [[NSUserDefaults standardUserDefaults] boolForKey:@"QSRTMParseTask"];
        NSDictionary *newTask;
        
        if ([[iObject primaryType] isEqualToString:kRTMListType])
        {
            listInfo = [iObject objectForType:kRTMListType];
        }
        
        if (newTask = [session addTask:[dObject stringValue] toList:listInfo parse:shouldParse error:&err])
        {
            NSString *taskName = [newTask objectForKey:kRTMTaskNameKey];
            NSDate *dueDate = [newTask objectForKey:kRTMTaskDueDateKey];
        
            NSString *notifyString;
            
            notifyString = [NSString stringWithFormat:@"Created todo \"%@\" in %@", 
                                                        taskName, 
                                                        listInfo?[listInfo valueForKey:kRTMListNameKey]:@"Inbox"];
        
            if (dueDate)
            {
                NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
                [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setTimeStyle:NSDateFormatterNoStyle];
                
                NSString *dateStr = [formatter stringFromDate:dueDate];
                
                notifyString = [NSString stringWithFormat:@"%@ due %@", notifyString, dateStr];
                
                if ([[newTask objectForKey:kRTMTaskHasDueTimeKey] boolValue])
                {
                    [formatter setDateStyle:NSDateFormatterNoStyle];
                    [formatter setTimeStyle:NSDateFormatterShortStyle];
                    
                    NSString *timeStr = [formatter stringFromDate:dueDate];
                    
                    notifyString = [NSString stringWithFormat:@"%@ at %@", notifyString, timeStr];
                }
            }
            
            QSRTMNotify(notifyString);
        }
        else
        {
            QSRTMNotify([NSString stringWithFormat:@"There was an error (%@) creating todo", err]);
        }
    }
    else
    {
        QSRTMNotify(errorStr);
    }
    
	return nil;
}
@end
