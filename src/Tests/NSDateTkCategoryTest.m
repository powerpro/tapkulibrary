//
//  NSDateTkCategoryTest
//
//  Created by Sean Freitag on 9/28/12.
//  Copyright 2012 Banno, LLC. All rights reserved.
//


#import "NSDateTkCategoryTest.h"
#import "TapkuLibrary.h"


@implementation NSDateTkCategoryTest

#pragma mark Helpers

- (NSCalendar *)calendar {
    return [NSCalendar currentCalendar];
}

- (NSDate *)dateFromMonth:(NSInteger)month year:(NSInteger)year {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = month;
    components.year = year;

    return [[self calendar] dateFromComponents:components];
}

#pragma mark Sunday first day tests

- (void)testFourRowsInMonth_Sunday {
    NSDate *august2009 = [self dateFromMonth:2 year:2009];

    NSUInteger rowCount = [august2009 rowsOnCalendarStartingOnSunday:YES];

    STAssertEquals(4u, rowCount, @"There should be four rows in February 2009 starting on Sunday");
}

- (void)testFiveRowsInMonth_Sunday {
    NSDate *july2012 = [self dateFromMonth:7 year:2012];

    NSUInteger rowCount = [july2012 rowsOnCalendarStartingOnSunday:YES];

    STAssertEquals(5u, rowCount, @"There should be five rows in July 2012 starting on Sunday");
}

- (void)testSixRowsInMonth_Sunday {
    NSDate *september2012 = [self dateFromMonth:9 year:2012];

    NSUInteger rowCount = [september2012 rowsOnCalendarStartingOnSunday:YES];

    STAssertEquals(6u, rowCount, @"There should be six rows in September 2012 starting on Sunday");
}

#pragma mark Monday first day tests

- (void)testFourRowsInMonth_Monday {
    NSDate *august2010 = [self dateFromMonth:2 year:2010];

    NSUInteger rowCount = [august2010 rowsOnCalendarStartingOnSunday:NO];

    STAssertEquals(4u, rowCount, @"There should be four rows in February 2010 starting on Monday");
}

- (void)testFiveRowsInMonth_Monday {
    NSDate *august2012 = [self dateFromMonth:8 year:2012];

    NSUInteger rowCount = [august2012 rowsOnCalendarStartingOnSunday:NO];

    STAssertEquals(5u, rowCount, @"There should be six rows in August 2012 starting on Monday");
}

- (void)testSixRowsInMonth_Monday {
    NSDate *july2012 = [self dateFromMonth:7 year:2012];

    NSUInteger rowCount = [july2012 rowsOnCalendarStartingOnSunday:NO];

    STAssertEquals(6u, rowCount, @"There should be six rows in July 2012 starting on Monday");
}

#pragma mark Next Month tests

- (void)testNextMonthMiddleOfYear {
    NSDate *july2012   = [self dateFromMonth:7 year:2012];
    NSDate *august2012 = [self dateFromMonth:8 year:2012];

    STAssertEqualObjects([july2012 nextMonth], august2012, @"");
}

- (void)testNextMonthFromDecember {
    NSDate *december2011 = [self dateFromMonth:12 year:2011];
    NSDate *january2012  = [self dateFromMonth:1  year:2012];

    STAssertEqualObjects([december2011 nextMonth], january2012, @"");
}

#pragma mark Previous Month tests

- (void)testPreviousMonthMiddleOfYear {
    NSDate *july2012   = [self dateFromMonth:7 year:2012];
    NSDate *june2012 =   [self dateFromMonth:6 year:2012];

    STAssertEqualObjects([july2012 previousMonth], june2012, @"");
}

- (void)testPreviousMonthFromJanuary {
    NSDate *january2012  = [self dateFromMonth:1  year:2012];
    NSDate *december2011 = [self dateFromMonth:12 year:2011];

    STAssertEqualObjects([january2012 previousMonth], december2011, @"");
}

#pragma mark Month Date tests

- (void)testMonthDate {
    NSDate *date = [NSDate date];
    NSDateComponents *components = [[self calendar] components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];

    NSDate *monthDate = [self dateFromMonth:components.month year:components.year];

    STAssertEqualObjects([date monthDate], monthDate, @"");
}

- (void)testDateByAddingDays {
    NSDate *july2012 = [self dateFromMonth:7 year:2012];
    NSDate *august2012 = [self dateFromMonth:8 year:2012];

    STAssertEqualObjects([july2012 dateByAddingDays:31], august2012, @"");
}

@end