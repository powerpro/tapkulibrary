//
//  NSDateTkCategoryTest
//
//  Created by Sean Freitag on 9/28/12.
//  Copyright 2012 Banno, LLC. All rights reserved.
//


#import "NSDateTkCategoryTest.h"
#import "TapkuLibrary.h"


@implementation NSDateTkCategoryTest

#pragma mark Sunday first day tests

- (void)testFourRowsInMonth_Sunday {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 2;
    components.year = 2009;

    NSDate *august2009 = [[NSCalendar currentCalendar] dateFromComponents:components];

    NSUInteger i = [august2009 rowsOnCalendarStartingOnSunday:YES];

    STAssertEquals(4u, i, @"There should be four rows in February 2009 starting on Sunday");
}

- (void)testFiveRowsInMonth_Sunday {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 7;
    components.year = 2012;

    NSDate *july2012 = [[NSCalendar currentCalendar] dateFromComponents:components];

    NSUInteger i = [july2012 rowsOnCalendarStartingOnSunday:YES];

    STAssertEquals(5u, i, @"There should be five rows in July 2012 starting on Sunday");
}

- (void)testSixRowsInMonth_Sunday {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 9;
    components.year = 2012;

    NSDate *september2012 = [[NSCalendar currentCalendar] dateFromComponents:components];

    NSUInteger i = [september2012 rowsOnCalendarStartingOnSunday:YES];

    STAssertEquals(6u, i, @"There should be six rows in September 2012 starting on Sunday");
}

#pragma mark Monday first day tests

- (void)testFourRowsInMonth_Monday {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 2;
    components.year = 2010;

    NSDate *august2010 = [[NSCalendar currentCalendar] dateFromComponents:components];

    NSUInteger i = [august2010 rowsOnCalendarStartingOnSunday:NO];

    STAssertEquals(4u, i, @"There should be four rows in February 2010 starting on Monday");
}

- (void)testFiveRowsInMonth_Monday {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 8;
    components.year = 2012;

    NSDate *august2012 = [[NSCalendar currentCalendar] dateFromComponents:components];

    NSUInteger i = [august2012 rowsOnCalendarStartingOnSunday:NO];

    STAssertEquals(5u, i, @"There should be six rows in August 2012 starting on Monday");
}

- (void)testSixRowsInMonth_Monday {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 7;
    components.year = 2012;

    NSDate *july2012 = [[NSCalendar currentCalendar] dateFromComponents:components];

    NSUInteger i = [july2012 rowsOnCalendarStartingOnSunday:NO];

    STAssertEquals(6u, i, @"There should be six rows in July 2012 starting on Monday");
}

@end