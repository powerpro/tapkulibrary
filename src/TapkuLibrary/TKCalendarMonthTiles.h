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
@property (nonatomic, strong) NSMutableArray *accessibleElements;

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)marks startDayOnSunday:(BOOL)sunday;

- (void) selectDay:(int)day;
- (NSDate*)dateSelected;

@property (strong,nonatomic) UIImageView *selectedImageView;
@property (strong,nonatomic) UILabel *currentDay;
@property (strong,nonatomic) UILabel *dot;

@end