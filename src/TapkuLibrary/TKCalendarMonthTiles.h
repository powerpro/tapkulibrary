//
//  TKCalendarMonthTiles
//
//  Created by Sean Freitag on 9/20/12.
//  Copyright 2012 Banno, LLC. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol TKCalendarMonthTilesDelegate

- (BOOL)calendarMonthTiles:(TKCalendarMonthTiles *)monthTiles canSelectDate:(NSDate *)date;
- (void)dateWasSelected:(NSDate *)date;

@end

@interface TKCalendarMonthTiles : UIView

@property (nonatomic, assign) id <TKCalendarMonthTilesDelegate> delegate;

@property (strong,nonatomic) NSDate *monthDate;

- (id)initWithMonth:(NSDate *)date startDayOnSunday:(BOOL)sunday;

- (void)selectDate:(NSDate *)date;
- (NSDate*)dateSelected;
- (void)updateSelectableDays;

@property (strong,nonatomic) UIImageView *selectedImageView;

@end