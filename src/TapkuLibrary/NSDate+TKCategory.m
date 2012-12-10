//
//  NSDateAdditions.m
//  Created by Devin Ross on 7/28/09.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */
#import "NSDate+TKCategory.h"


@implementation NSDate (TKCategory)

- (NSCalendar *)calendar {
    return [NSCalendar currentCalendar];
}

- (NSDate*) monthDate {
	NSCalendar *calendar = [self calendar];
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
    return [calendar dateFromComponents:components];
}

- (BOOL) isSameDay:(NSDate*)anotherDate{
	NSCalendar* calendar = [self calendar];
	NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
} 

- (NSInteger) daysBetweenDate:(NSDate*)date {
    NSTimeInterval time = [self timeIntervalSinceDate:date];
    return ((abs(time) / (60.0 * 60.0 * 24.0)) + 0.5);
}

- (BOOL) isToday{
	return [self isSameDay:[NSDate date]];
} 

- (NSDate *)dateByAddingDays:(NSUInteger)days {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.day = days;
	return [[self calendar] dateByAddingComponents:components toDate:self options:0];
}

+ (NSDate *) dateWithDatePart:(NSDate *)aDate andTimePart:(NSDate *)aTime {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yyyy"];
	NSString *datePortion = [dateFormatter stringFromDate:aDate];
	
	[dateFormatter setDateFormat:@"HH:mm"];
	NSString *timePortion = [dateFormatter stringFromDate:aTime];
	
	[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
	NSString *dateTime = [NSString stringWithFormat:@"%@ %@",datePortion,timePortion];
	return [dateFormatter dateFromString:dateTime];
}


- (NSString *) monthYearString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [self calendar].timeZone;
	dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yMMMM"
															   options:0
																locale:[NSLocale currentLocale]];
    return [dateFormatter stringFromDate:self];
}

- (TKDateInformation)dateInformation {
	
	TKDateInformation info;
	
	NSCalendar *calendar = [self calendar];
	NSDateComponents *comp = [calendar components:(NSMonthCalendarUnit |  NSMinuteCalendarUnit | NSYearCalendarUnit |
                                                     NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit |
                                                  NSSecondCalendarUnit)
                                         fromDate:self];

	info.day = [comp day];
	info.month = [comp month];
	info.year = [comp year];
	
	info.hour = [comp hour];
	info.minute = [comp minute];
	info.second = [comp second];
	
	info.weekday = [comp weekday];

	return info;
}

- (NSDate *)nextMonth {
    NSCalendar *calendar = [self calendar];
    NSDateComponents *components = [calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self];
    if (components.month < 12) {
        components.month = components.month + 1;
    } else {
        components.month = 1;
        components.year = components.year + 1;
    }

    return [calendar dateFromComponents:components];
}

- (NSDate *)previousMonth {
    NSCalendar *calendar = [self calendar];
    NSDateComponents *components = [calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self];
    if (components.month > 1) {
        components.month = components.month - 1;
    } else {
        components.month = 12;
        components.year = components.year - 1;
    }
    
    return [calendar dateFromComponents:components];
}

- (NSArray *)datesInMonth {
    NSMutableArray *array = [NSMutableArray array];
    
    NSRange days = [[self calendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];

    NSDateComponents *components = [[self calendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDate *firstDate = [[self calendar] dateFromComponents:components];

    for (int i = 0; i < days.length; i++) {
        NSDateComponents *c = [[NSDateComponents alloc] init];
        c.day = i;
        [array addObject:[[self calendar] dateByAddingComponents:c toDate:firstDate options:0]];
    }

    return array;
}

- (NSUInteger)rowsOnCalendarStartingOnSunday:(BOOL)starsOnSunday {
    NSInteger weekday = [[self calendar] components:NSWeekdayCalendarUnit fromDate:self].weekday;

    NSUInteger daysInMonth = [[self calendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self].length;

    NSInteger offset = weekday - (starsOnSunday ? 1 : 2);
    if (offset < 0) offset = 7 + offset;

    NSUInteger daysInMonthWithOffset = daysInMonth + offset;

    NSUInteger rows = (daysInMonthWithOffset / 7) + (daysInMonthWithOffset % 7 == 0 ? 0 : 1);

    return rows;
}

@end
