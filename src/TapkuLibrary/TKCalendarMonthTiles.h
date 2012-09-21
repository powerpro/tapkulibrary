//
//  TKCalendarMonthTiles
//
//  Created by Sean Freitag on 9/20/12.
//  Copyright 2012 Banno, LLC. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol TKCalendarMonthTilesDelegate

- (void)tile:(NSArray *)ar;

@end

@interface TKCalendarMonthTiles : UIView {
	int _firstOfPrev, _lastOfPrev;
	NSArray *_marks;
	int _today;
	BOOL _markWasOnToday;

	int _selectedDay, _selectedPortion;

	int _firstWeekday, _daysInMonth;
	UILabel *_dot;
	BOOL _startOnSunday;
}

@property (nonatomic, weak) id <TKCalendarMonthTilesDelegate> delegate;

@property (strong,nonatomic) NSDate *monthDate;
@property (nonatomic, strong) NSMutableArray *accessibleElements;

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)marks startDayOnSunday:(BOOL)sunday;

- (void) selectDay:(int)day;
- (NSDate*) dateSelected;

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday;


@property (strong,nonatomic) UIImageView *selectedImageView;
@property (strong,nonatomic) UILabel *currentDay;
@property (strong,nonatomic) UILabel *dot;
@property (nonatomic,strong) NSArray *datesArray;

@end