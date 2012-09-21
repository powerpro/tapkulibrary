//
//  TKCalendarMonthView.m
//  Created by Devin Ross on 6/10/10.
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

#import "TKCalendarMonthView.h"
#import "NSDate+TKCategory.h"
#import "TKGlobal.h"
#import "UIImage+TKCategory.h"
#import "NSDate+CalendarGrid.h"
#import "TKCalendarMonthTiles.h"


#pragma mark -
@interface TKCalendarMonthView ()

@property (strong,nonatomic) UIView *tileBox;
@property (strong,nonatomic) UIImageView *topBackground;
@property (strong,nonatomic) UILabel *monthYear;
@property (strong,nonatomic) UIButton *leftArrow;
@property (strong,nonatomic) UIButton *rightArrow;
@property (strong,nonatomic) UIImageView *shadow;

@property (nonatomic) BOOL sunday;
@property (nonatomic, strong) TKCalendarMonthTiles *currentTile;

@end

#pragma mark -
@implementation TKCalendarMonthView

- (void)setup {
    self.currentTile = [self tilesForMonth:[[NSDate date] firstOfMonth]];

    self.tileBox = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, self.currentTile.frame.size.height)];
    self.tileBox.clipsToBounds = YES;
    [self.tileBox addSubview:self.currentTile];
    [self addSubview:self.tileBox];

    CGRect r = CGRectMake(0, 0, self.tileBox.bounds.size.width, self.tileBox.bounds.size.height + self.tileBox.frame.origin.y);
   	self.frame = r;

    self.topBackground =  [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Grid Top Bar.png")]];
    self.topBackground.frame = CGRectMake(0, 0, self.bounds.size.width, self.topBackground.frame.size.height);
    [self addSubview:self.topBackground];

    self.monthYear = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, self.tileBox.frame.size.width, 38), 40, 6)];
  	self.monthYear.textAlignment = NSTextAlignmentCenter;
  	self.monthYear.backgroundColor = [UIColor clearColor];
  	self.monthYear.font = [UIFont boldSystemFontOfSize:22];
  	self.monthYear.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
    self.monthYear.text = [[NSDate date] monthYearString];
   	[self addSubview:self.monthYear];

    self.rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightArrow.accessibilityLabel = @"Next Month";
    [self.rightArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Right Arrow"] forState:UIControlStateNormal];
    [self.rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
    self.rightArrow.frame = CGRectMake(320-45, 0, 48, 38);
    [self addSubview:self.rightArrow];

    self.leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftArrow.accessibilityLabel = @"Previous Month";
    [self.leftArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Left Arrow"] forState:UIControlStateNormal];
    [self.leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
  	self.leftArrow.frame = CGRectMake(0, 0, 48, 38);
    [self addSubview:self.leftArrow];

    self.shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];
    self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.bounds.size.width, self.shadow.frame.size.height);
    [self addSubview:self.shadow];

    self.backgroundColor = [UIColor grayColor];
}

- (id) init{
	self = [self initWithSundayAsFirst:YES];
	return self;
}
- (id) initWithSundayAsFirst:(BOOL)sundayFirst {
	if (!(self = [super initWithFrame:CGRectZero])) return nil;
    self.sunday = sundayFirst;

    [self setup];

	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"eee"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	
	TKDateInformation sund;
	sund.day = 5;
	sund.month = 12;
	sund.year = 2010;
	sund.hour = 0;
	sund.minute = 0;
	sund.second = 0;
	sund.weekday = 0;
	
	
	NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
	NSString * sun = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 6;
	NSString *mon = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 7;
	NSString *tue = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 8;
	NSString *wed = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 9;
	NSString *thu = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 10;
	NSString *fri = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 11;
	NSString *sat = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	NSArray *ar;
	if(self.sunday) ar = [NSArray arrayWithObjects:sun,mon,tue,wed,thu,fri,sat,nil];
	else ar = [NSArray arrayWithObjects:mon,tue,wed,thu,fri,sat,sun,nil];
	
	int i = 0;
	for(NSString *s in ar){
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46 * i, 29, 46, 15)];
		[self addSubview:label];
        
        //Added Accessibility Labels
        if ([s isEqualToString:@"Sun"]) {
            label.accessibilityLabel = @"Sunday";
        } else if ([s isEqualToString:@"Mon"]) {
            label.accessibilityLabel = @"Monday";
        } else if ([s isEqualToString:@"Tue"]) {
            label.accessibilityLabel = @"Tuesday";
        } else if ([s isEqualToString:@"Wed"]) {
            label.accessibilityLabel = @"Wednesday";
        } else if ([s isEqualToString:@"Thu"]) {
            label.accessibilityLabel = @"Thursday";
        } else if ([s isEqualToString:@"Fri"]) {
            label.accessibilityLabel = @"Friday";
        } else if ([s isEqualToString:@"Sat"]) {
            label.accessibilityLabel = @"Saturday";
        }
        
		label.text = s;
		label.textAlignment = NSTextAlignmentCenter;
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0, 1);
		label.font = [UIFont systemFontOfSize:11];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
		i++;
	}
	
	return self;
}

- (TKCalendarMonthTiles *)tilesForMonth:(NSDate *)month {
    NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:self.sunday];
    NSArray *ar = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
   	TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:month marks:ar startDayOnSunday:self.sunday];
   	[newTile setTarget:self action:@selector(tile:)];
    return newTile;
}

- (void)changeMonth:(UIButton *)sender{
	BOOL isNext = self.rightArrow == sender;
	NSDate *nextMonth = isNext ? [self.currentTile.monthDate nextMonth] : [self.currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];

    self.currentTile = [self tilesForMonth:nextMonth];

	self.monthYear.text = [localNextMonth monthYearString];
}

- (NSDate*) dateSelected{
	return [self.currentTile dateSelected];
}
- (NSDate*) monthDate{
	return [self.currentTile monthDate];
}
- (void) selectDate:(NSDate*)date{
	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSDate *month = [date firstOfMonth];
	
	if([month isEqualToDate:[self.currentTile monthDate]]){
		[self.currentTile selectDay:info.day];
		return;
	}else {
		TKCalendarMonthTiles *newTile = [self tilesForMonth:month];
        self.currentTile = newTile;

		self.tileBox.frame = CGRectMake(0, 44, newTile.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);

		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		self.monthYear.text = [date monthYearString];
		[self.currentTile selectDay:info.day];
	}
}
- (void) reload{
    self.currentTile = [self tilesForMonth:[self.currentTile monthDate]];
}

- (void) tile:(NSArray*)ar{
	if([ar count] >= 2){
		int direction = [[ar lastObject] intValue];
		UIButton *b = direction > 1 ? self.rightArrow : self.leftArrow;

        [self changeMonth:b];

        int day = [[ar objectAtIndex:0] intValue];
		[self.currentTile selectDay:day];
	}

    if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
  	    [self.delegate calendarMonthView:self didSelectDate:[self dateSelected]];
	
}

#pragma mark Properties

- (void)setCurrentTile:(TKCalendarMonthTiles *)newTile {
    if ([[_currentTile monthDate] isEqualToDate:[newTile monthDate]]) return;

    TKCalendarMonthTiles *currentTile = _currentTile;
    float animation = (currentTile == nil) ? 0 : 1;
    BOOL shouldAnimate = animation > 0;

    if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:[newTile monthDate] animated:shouldAnimate] )
   		return;

   	if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] )
   		[self.delegate calendarMonthView:self monthWillChange:[newTile monthDate] animated:shouldAnimate];

    _currentTile = newTile;

    BOOL isNext = [currentTile.monthDate compare:newTile.monthDate] == NSOrderedAscending;
    NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
    NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:self.sunday];

    int overlap =  0;

   	if(isNext){
   		overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : 44;
   	}else{
   		overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? 44 : 0;
   	}

   	float y = isNext ? currentTile.bounds.size.height - overlap : newTile.bounds.size.height * -1 + overlap +2;

   	newTile.frame = CGRectMake(0, y, newTile.frame.size.width, newTile.frame.size.height);
   	newTile.alpha = 0;
   	[self.tileBox addSubview:newTile];

    self.userInteractionEnabled = NO;

    [UIView animateWithDuration:animation * 0.1 animations:^{
        newTile.alpha = 1;
    }];

    [UIView animateWithDuration:animation * 0.4 delay:animation * 0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (isNext) {
            currentTile.frame = CGRectMake(0, -1 * currentTile.bounds.size.height + overlap + 2, currentTile.frame.size.width, currentTile.frame.size.height);
       		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
       		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
       		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);

       		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
       	} else {
       		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
       		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
       		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
            currentTile.frame = CGRectMake(0,  newTile.frame.size.height - overlap, currentTile.frame.size.width, currentTile.frame.size.height);

       		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
       	}
    } completion:^(BOOL completed) {
        self.userInteractionEnabled = YES;

        if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
      	    [self.delegate calendarMonthView:self monthDidChange:[newTile monthDate] animated:shouldAnimate];
    }];
}

@end