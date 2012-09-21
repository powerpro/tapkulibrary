//
//  TKCalendarMonthTiles
//
//  Created by Sean Freitag on 9/20/12.
//  Copyright 2012 Banno, LLC. All rights reserved.
//


#import "TKCalendarMonthTiles.h"
#import "TKGlobal.h"
#import "TapkuLibrary.h"
#import "NSDate+CalendarGrid.h"


@implementation TKCalendarMonthTiles

#define dotFontSize 18.0
#define dateFontSize 22.0

#pragma mark Accessibility Container methods
- (BOOL) isAccessibilityElement{
    return NO;
}
- (NSArray *) accessibleElements{
    if (_accessibleElements!=nil) return _accessibleElements;

    _accessibleElements = [[NSMutableArray alloc] init];


	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateStyle:NSDateFormatterFullStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

	NSDate *firstDate = [self.datesArray objectAtIndex:0];

	for(int i=0;i< _marks.count;i++){
		UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];

		NSDate *day = [NSDate dateWithTimeIntervalSinceReferenceDate:[firstDate timeIntervalSinceReferenceDate]+(24*60*60*i)+5];
		element.accessibilityLabel = [formatter stringForObjectValue:day];

		CGRect r = [self convertRect:[self rectForCellAtIndex:i] toView:self.window];
		r.origin.y -= 6;

		element.accessibilityFrame = r;
		element.accessibilityTraits = UIAccessibilityTraitButton;
		element.accessibilityValue = [[_marks objectAtIndex:i] boolValue] ? @"Has Events" : @"No Events";
		[_accessibleElements addObject:element];

	}



    return _accessibleElements;
}
- (NSInteger) accessibilityElementCount{
    return [[self accessibleElements] count];
}
- (id) accessibilityElementAtIndex:(NSInteger)index{
    return [[self accessibleElements] objectAtIndex:index];
}
- (NSInteger) indexOfAccessibilityElement:(id)element{
    return [[self accessibleElements] indexOfObject:element];
}



#pragma mark Init Methods
+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday{

	NSDate *firstDate, *lastDate;

	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.day = 1;
	info.hour = 0;
	info.minute = 0;
	info.second = 0;

	NSDate *currentMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info = [currentMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];


	NSDate *previousMonth = [currentMonth previousMonth];
	NSDate *nextMonth = [currentMonth nextMonth];

	if(info.weekday > 1 && sunday){

		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		info2.day = preDayCnt - info.weekday + 2;
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];


	}else if(!sunday && info.weekday != 2){

		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		if(info.weekday==1){
			info2.day = preDayCnt - 5;
		}else{
			info2.day = preDayCnt - info.weekday + 3;
		}
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];



	}else{
		firstDate = currentMonth;
	}



	int daysInMonth = [currentMonth daysBetweenDate:nextMonth];
	info.day = daysInMonth;
	NSDate *lastInMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	TKDateInformation lastDateInfo = [lastInMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];



	if(lastDateInfo.weekday < 7 && sunday){

		lastDateInfo.day = 7 - lastDateInfo.weekday;
		lastDateInfo.month++;
		lastDateInfo.weekday = 0;
		if(lastDateInfo.month>12){
			lastDateInfo.month = 1;
			lastDateInfo.year++;
		}
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

	}else if(!sunday && lastDateInfo.weekday != 1){


		lastDateInfo.day = 8 - lastDateInfo.weekday;
		lastDateInfo.month++;
		if(lastDateInfo.month>12){ lastDateInfo.month = 1; lastDateInfo.year++; }


		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

	}else{
		lastDate = lastInMonth;
	}



	return [NSArray arrayWithObjects:firstDate,lastDate,nil];
}
- (id) initWithMonth:(NSDate*)date marks:(NSArray*)markArray startDayOnSunday:(BOOL)sunday{
	if(!(self=[super initWithFrame:CGRectZero])) return nil;

	_firstOfPrev = -1;
	_marks = markArray;
	_monthDate = date;
	_startOnSunday = sunday;

	TKDateInformation dateInfo = [_monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	_firstWeekday = dateInfo.weekday;


	NSDate *prev = [_monthDate previousMonth];
	_daysInMonth = [[_monthDate nextMonth] daysBetweenDate:_monthDate];


	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:date startOnSunday:sunday];
	self.datesArray = dates;
	NSUInteger numberOfDaysBetween = [[dates objectAtIndex:0] daysBetweenDate:[dates lastObject]];
	NSUInteger scale = (numberOfDaysBetween / 7) + 1;
	CGFloat h = 44.0f * scale;


	TKDateInformation todayInfo = [[NSDate date] dateInformation];
	_today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;

	int preDayCnt = [prev daysBetweenDate:_monthDate];
	if(_firstWeekday >1 && sunday){
		_firstOfPrev = preDayCnt - _firstWeekday +2;
		_lastOfPrev = preDayCnt;
	}else if(!sunday && _firstWeekday != 2){

		if(_firstWeekday ==1){
			_firstOfPrev = preDayCnt - 5;
		}else{
			_firstOfPrev = preDayCnt - _firstWeekday +3;
		}
		_lastOfPrev = preDayCnt;
	}


	self.frame = CGRectMake(0, 1.0, 320.0f, h+1);

	[self.selectedImageView addSubview:self.currentDay];
	[self.selectedImageView addSubview:self.dot];
	self.multipleTouchEnabled = NO;


	return self;
}

- (CGRect) rectForCellAtIndex:(int)index{

	int row = index / 7;
	int col = index % 7;

	return CGRectMake(col*46, row*44+6, 47, 45);
}
- (void) drawTileInRect:(CGRect)r day:(int)day mark:(BOOL)mark font:(UIFont*)f1 font2:(UIFont*)f2{

	NSString *str = [NSString stringWithFormat:@"%d",day];


	r.size.height -= 2;
	[str drawInRect: r
		   withFont: f1
	  lineBreakMode: UILineBreakModeWordWrap
		  alignment: UITextAlignmentCenter];

	if(mark){
		r.size.height = 10;
		r.origin.y += 18;

		[@"•" drawInRect: r
				withFont: f2
		   lineBreakMode: UILineBreakModeWordWrap
			   alignment: UITextAlignmentCenter];
	}



}
- (void) drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
	UIImage *tile = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile.png")];
	CGRect r = CGRectMake(0, 0, 46, 44);
	CGContextDrawTiledImage(context, r, tile.CGImage);

	if(_today > 0){
		int pre = _firstOfPrev > 0 ? _lastOfPrev - _firstOfPrev + 1 : 0;
		int index = _today +  pre-1;
		CGRect r =[self rectForCellAtIndex:index];
		r.origin.y -= 7;
		[[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Tile.png")] drawInRect:r];
	}

	int index = 0;

	UIFont *font = [UIFont boldSystemFontOfSize:dateFontSize];
	UIFont *font2 =[UIFont boldSystemFontOfSize:dotFontSize];
	UIColor *color = [UIColor grayColor];

	if(_firstOfPrev >0){
		[color set];
		for(int i = _firstOfPrev;i<= _lastOfPrev;i++){
			r = [self rectForCellAtIndex:index];
			if ([_marks count] > 0)
				[self drawTileInRect:r day:i mark:[[_marks objectAtIndex:index] boolValue] font:font font2:font2];
			else
				[self drawTileInRect:r day:i mark:NO font:font font2:font2];
			index++;
		}
	}


	color = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	[color set];
	for(int i=1; i <= _daysInMonth; i++){

		r = [self rectForCellAtIndex:index];
		if(_today == i) [[UIColor whiteColor] set];

		if ([_marks count] > 0)
			[self drawTileInRect:r day:i mark:[[_marks objectAtIndex:index] boolValue] font:font font2:font2];
		else
			[self drawTileInRect:r day:i mark:NO font:font font2:font2];
		if(_today == i) [color set];
		index++;
	}

	[[UIColor grayColor] set];
	int i = 1;
	while(index % 7 != 0){
		r = [self rectForCellAtIndex:index] ;
		if ([_marks count] > 0)
			[self drawTileInRect:r day:i mark:[[_marks objectAtIndex:index] boolValue] font:font font2:font2];
		else
			[self drawTileInRect:r day:i mark:NO font:font font2:font2];
		i++;
		index++;
	}


}

- (void) selectDay:(int)day{

	int pre = _firstOfPrev < 0 ?  0 : _lastOfPrev - _firstOfPrev + 1;

	int tot = day + pre;
	int row = tot / 7;
	int column = (tot % 7)-1;

	_selectedDay = day;
	_selectedPortion = 1;


	if(day == _today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];
		_markWasOnToday = YES;
	}else if(_markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);



		NSString *path = TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png");
		self.selectedImageView.image = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
		_markWasOnToday = NO;
	}



	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];

	if ([_marks count] > 0) {

		if([[_marks objectAtIndex:row * 7 + column] boolValue]){
			[self.selectedImageView addSubview:self.dot];
		}else{
			[self.dot removeFromSuperview];
		}


	}else{
		[self.dot removeFromSuperview];
	}

	if(column < 0){
		column = 6;
		row--;
	}

	CGRect r = self.selectedImageView.frame;
	r.origin.x = (column*46);
	r.origin.y = (row*44)-1;
	self.selectedImageView.frame = r;




}
- (NSDate*) dateSelected{
	if(_selectedDay < 1 || _selectedPortion != 1) return nil;

	TKDateInformation info = [_monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	info.day = _selectedDay;
	NSDate *d = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];



	return d;

}


- (void) reactToTouch:(UITouch*)touch down:(BOOL)down{

	CGPoint p = [touch locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;

	int column = p.x / 46, row = p.y / 44;
	int day = 1, portion = 0;

	if(row == (int) (self.bounds.size.height / 44)) row --;

	int fir = _firstWeekday - 1;
	if(!_startOnSunday && fir == 0) fir = 7;
	if(!_startOnSunday) fir--;


	if(row==0 && column < fir){
		day = _firstOfPrev + column;
	}else{
		portion = 1;
		day = row * 7 + column  - _firstWeekday +2;
		if(!_startOnSunday) day++;
		if(!_startOnSunday && fir==6) day -= 7;

	}
	if(portion > 0 && day > _daysInMonth){
		portion = 2;
		day = day - _daysInMonth;
	}


	if(portion != 1){
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
		_markWasOnToday = YES;
	}else if(portion==1 && day == _today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];
		_markWasOnToday = YES;
	}else if(_markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);


		NSString *path = TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png");
		self.selectedImageView.image = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];

		_markWasOnToday = NO;
	}

	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];

	if ([_marks count] > 0) {
		if([[_marks objectAtIndex:row * 7 + column] boolValue])
			[self.selectedImageView addSubview:self.dot];
		else
			[self.dot removeFromSuperview];
	}else{
		[self.dot removeFromSuperview];
	}




	CGRect r = self.selectedImageView.frame;
	r.origin.x = (column*46);
	r.origin.y = (row*44)-1;
	self.selectedImageView.frame = r;

	if(day == _selectedDay && _selectedPortion == portion) return;



	if(portion == 1){
		_selectedDay = day;
		_selectedPortion = portion;
        [self.delegate tile:[NSArray arrayWithObject:[NSNumber numberWithInt:day]]];
	}else if(down){
        [self.delegate tile:[NSArray arrayWithObjects:[NSNumber numberWithInt:day], [NSNumber numberWithInt:portion], nil]];
		_selectedDay = day;
		_selectedPortion = portion;
	}

}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	//[super touchesBegan:touches withEvent:event];
	[self reactToTouch:[touches anyObject] down:NO];
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:NO];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:YES];
}

- (UILabel *) currentDay{
	if(_currentDay ==nil){
		CGRect r = self.selectedImageView.bounds;
		r.origin.y -= 2;
		_currentDay = [[UILabel alloc] initWithFrame:r];
		_currentDay.text = @"1";
		_currentDay.textColor = [UIColor whiteColor];
		_currentDay.backgroundColor = [UIColor clearColor];
		_currentDay.font = [UIFont boldSystemFontOfSize:dateFontSize];
		_currentDay.textAlignment = UITextAlignmentCenter;
		_currentDay.shadowColor = [UIColor darkGrayColor];
		_currentDay.shadowOffset = CGSizeMake(0, -1);
	}
	return _currentDay;
}
- (UILabel *) dot{
	if(_dot ==nil){
		CGRect r = self.selectedImageView.bounds;
		r.origin.y += 29;
		r.size.height -= 31;
		_dot = [[UILabel alloc] initWithFrame:r];

		_dot.text = @"•";
		_dot.textColor = [UIColor whiteColor];
		_dot.backgroundColor = [UIColor clearColor];
		_dot.font = [UIFont boldSystemFontOfSize:dotFontSize];
		_dot.textAlignment = UITextAlignmentCenter;
		_dot.shadowColor = [UIColor darkGrayColor];
		_dot.shadowOffset = CGSizeMake(0, -1);
	}
	return _dot;
}
- (UIImageView *) selectedImageView{
	if(_selectedImageView ==nil){

		NSString *path = TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png");
		UIImage *img = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
		_selectedImageView = [[UIImageView alloc] initWithImage:img];
		_selectedImageView.frame = CGRectMake(0, 0, 47, 45);
	}
	return _selectedImageView;
}

@end