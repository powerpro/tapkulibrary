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


#pragma mark -
@interface TKCalendarMonthTiles : UIView {
	
	id _target;
	SEL _action;
	
	int _firstOfPrev, _lastOfPrev;
	NSArray *_marks;
	int _today;
	BOOL _markWasOnToday;
	
	int _selectedDay, _selectedPortion;
	
	int _firstWeekday, _daysInMonth;
	UILabel *_dot;
	BOOL _startOnSunday;
}

@property (strong,nonatomic) NSDate *monthDate;
@property (nonatomic, strong) NSMutableArray *accessibleElements;

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)marks startDayOnSunday:(BOOL)sunday;
- (void) setTarget:(id)target action:(SEL)action;

- (void) selectDay:(int)day;
- (NSDate*) dateSelected;

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday;


@property (strong,nonatomic) UIImageView *selectedImageView;
@property (strong,nonatomic) UILabel *currentDay;
@property (strong,nonatomic) UILabel *dot;
@property (nonatomic,strong) NSArray *datesArray;

@end


#pragma mark -
@implementation TKCalendarMonthTiles
@synthesize monthDate,datesArray;

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
	monthDate = date;
	_startOnSunday = sunday;
	
	TKDateInformation dateInfo = [monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	_firstWeekday = dateInfo.weekday;
	
	
	NSDate *prev = [monthDate previousMonth];	
	_daysInMonth = [[monthDate nextMonth] daysBetweenDate:monthDate];
	
	
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:date startOnSunday:sunday];
	self.datesArray = dates;
	NSUInteger numberOfDaysBetween = [[dates objectAtIndex:0] daysBetweenDate:[dates lastObject]];
	NSUInteger scale = (numberOfDaysBetween / 7) + 1;
	CGFloat h = 44.0f * scale;
	
	
	TKDateInformation todayInfo = [[NSDate date] dateInformation];
	_today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;
	
	int preDayCnt = [prev daysBetweenDate:monthDate];		
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
- (void) setTarget:(id)t action:(SEL)a{
	_target = t;
	_action = a;
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
	
	TKDateInformation info = [monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
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
        [_target performSelector:_action withObject:[NSArray arrayWithObject:[NSNumber numberWithInt:day]]];
		
	}else if(down){
        [_target performSelector:_action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day], [NSNumber numberWithInt:portion], nil]];
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



#pragma mark -
@interface TKCalendarMonthView ()
@property (strong,nonatomic) UIView *tileBox;
@property (strong,nonatomic) UIImageView *topBackground;
@property (strong,nonatomic) UILabel *monthYear;
@property (strong,nonatomic) UIButton *leftArrow;
@property (strong,nonatomic) UIButton *rightArrow;
@property (strong,nonatomic) UIImageView *shadow;
@end

#pragma mark -
@implementation TKCalendarMonthView
@synthesize delegate,dataSource;
@synthesize tileBox=_tileBox;

- (id) init{
	self = [self initWithSundayAsFirst:YES];
	return self;
}
- (id) initWithSundayAsFirst:(BOOL)s{
	if (!(self = [super initWithFrame:CGRectZero])) return nil;
	self.backgroundColor = [UIColor grayColor];

	_sunday = s;
	_currentTile = [[TKCalendarMonthTiles alloc] initWithMonth:[[NSDate date] firstOfMonth] marks:nil startDayOnSunday:_sunday];
	[_currentTile setTarget:self action:@selector(tile:)];
	
	CGRect r = CGRectMake(0, 0, self.tileBox.bounds.size.width, self.tileBox.bounds.size.height + self.tileBox.frame.origin.y);
	self.frame = r;
	
	[self addSubview:self.topBackground];
	self.topBackground.frame = CGRectMake(0, 0, self.bounds.size.width, self.topBackground.frame.size.height);
    [self.tileBox addSubview:_currentTile];
	[self addSubview:self.tileBox];
	
	NSDate *date = [NSDate date];
	self.monthYear.text = [date monthYearString];
	[self addSubview:self.monthYear];
	
	
	[self addSubview:self.leftArrow];
	[self addSubview:self.rightArrow];
	[self addSubview:self.shadow];
	self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.bounds.size.width, self.shadow.frame.size.height);
	
	
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
	if(_sunday) ar = [NSArray arrayWithObjects:sun,mon,tue,wed,thu,fri,sat,nil];
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
		label.textAlignment = UITextAlignmentCenter;
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0, 1);
		label.font = [UIFont systemFontOfSize:11];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
		i++;
	}
	
	return self;
}


- (NSDate*) dateForMonthChange:(UIView*)sender {
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [_currentTile.monthDate nextMonth] : [_currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	
	return localNextMonth;
}

- (void) changeMonthAnimation:(UIView*)sender{
	
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [_currentTile.monthDate nextMonth] : [_currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	
	
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:_sunday];
	NSArray *ar = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:nextMonth marks:ar startDayOnSunday:_sunday];
	[newTile setTarget:self action:@selector(tile:)];
	
	
	
	int overlap =  0;
	
	if(isNext){
		overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : 44;
	}else{
		overlap = [_currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? 44 : 0;
	}
	
	float y = isNext ? _currentTile.bounds.size.height - overlap : newTile.bounds.size.height * -1 + overlap +2;
	
	newTile.frame = CGRectMake(0, y, newTile.frame.size.width, newTile.frame.size.height);
	newTile.alpha = 0;
	[self.tileBox addSubview:newTile];
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];
	newTile.alpha = 1;

	[UIView commitAnimations];
	
	
	
	self.userInteractionEnabled = NO;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(animationEnded)];
	[UIView setAnimationDelay:0.1];
	[UIView setAnimationDuration:0.4];
	
	
	
	if(isNext){
		
		_currentTile.frame = CGRectMake(0, -1 * _currentTile.bounds.size.height + overlap + 2, _currentTile.frame.size.width, _currentTile.frame.size.height);
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		
		
	}else{
		
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		_currentTile.frame = CGRectMake(0,  newTile.frame.size.height - overlap, _currentTile.frame.size.width, _currentTile.frame.size.height);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		
	}
	
	
	[UIView commitAnimations];
	
	_oldTile = _currentTile;
	_currentTile = newTile;
	
	
	
	_monthYear.text = [localNextMonth monthYearString];
	
	

}
- (void) changeMonth:(UIButton *)sender{
	
	NSDate *newDate = [self dateForMonthChange:sender];
	if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:newDate animated:YES] ) 
		return;
	
	
	if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] ) 
		[self.delegate calendarMonthView:self monthWillChange:newDate animated:YES];
	

	
	
	[self changeMonthAnimation:sender];
	if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
		[self.delegate calendarMonthView:self monthDidChange:_currentTile.monthDate animated:YES];

}
- (void) animationEnded{
	self.userInteractionEnabled = YES;
	[_oldTile removeFromSuperview];
	_oldTile = nil;
}

- (NSDate*) dateSelected{
	return [_currentTile dateSelected];
}
- (NSDate*) monthDate{
	return [_currentTile monthDate];
}
- (void) selectDate:(NSDate*)date{
	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSDate *month = [date firstOfMonth];
	
	if([month isEqualToDate:[_currentTile monthDate]]){
		[_currentTile selectDay:info.day];
		return;
	}else {
		
		if ([delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:month animated:YES] ) 
			return;
		
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] )
			[self.delegate calendarMonthView:self monthWillChange:month animated:YES];
		
		
		NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:_sunday];
		NSArray *data = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
		TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:month
                                                                              marks:data
                                                                   startDayOnSunday:_sunday];
		[newTile setTarget:self action:@selector(tile:)];
		[_currentTile removeFromSuperview];
		_currentTile = newTile;
        [self.tileBox addSubview:_currentTile];
		self.tileBox.frame = CGRectMake(0, 44, newTile.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);

		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		self.monthYear.text = [date monthYearString];
		[_currentTile selectDay:info.day];
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
			[self.delegate calendarMonthView:self monthDidChange:date animated:NO];
		
		
	}
}
- (void) reload{
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:[_currentTile monthDate] startOnSunday:_sunday];
	NSArray *ar = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	
	TKCalendarMonthTiles *refresh = [[TKCalendarMonthTiles alloc] initWithMonth:[_currentTile monthDate] marks:ar startDayOnSunday:_sunday];
	[refresh setTarget:self action:@selector(tile:)];
	
	[self.tileBox addSubview:refresh];
	[_currentTile removeFromSuperview];
	_currentTile = refresh;
	
}

- (void) tile:(NSArray*)ar{
	
	if([ar count] < 2){
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[self.delegate calendarMonthView:self didSelectDate:[self dateSelected]];
	
	}else{
		
		int direction = [[ar lastObject] intValue];
		UIButton *b = direction > 1 ? self.rightArrow : self.leftArrow;
		
		NSDate* newMonth = [self dateForMonthChange:b];
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![delegate calendarMonthView:self monthShouldChange:newMonth animated:YES])
			return;
		
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)])					
			[self.delegate calendarMonthView:self monthWillChange:newMonth animated:YES];
		
		
		
		[self changeMonthAnimation:b];
		
		int day = [[ar objectAtIndex:0] intValue];

	
		// thanks rafael
		TKDateInformation info = [[_currentTile monthDate] dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		info.day = day;
        
        NSDate *dateForMonth = [NSDate dateFromDateInformation:info  timeZone:[NSTimeZone timeZoneWithName:@"GMT"]]; 
		[_currentTile selectDay:day];
		
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[self.delegate calendarMonthView:self didSelectDate:dateForMonth];
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
			[self.delegate calendarMonthView:self monthDidChange:dateForMonth animated:YES];

		
	}
	
}

#pragma mark Properties
- (UIImageView *) topBackground{
	if(_topBackground ==nil){
		_topBackground = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Grid Top Bar.png")]];
	}
	return _topBackground;
}
- (UILabel *) monthYear{
	if(_monthYear ==nil){
		_monthYear = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, self.tileBox.frame.size.width, 38), 40, 6)];
		_monthYear.textAlignment = UITextAlignmentCenter;
		_monthYear.backgroundColor = [UIColor clearColor];
		_monthYear.font = [UIFont boldSystemFontOfSize:22];
		_monthYear.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	}
	return _monthYear;
}
- (UIButton *) leftArrow{
	if(_leftArrow ==nil){
		_leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		_leftArrow.tag = 0;
        _leftArrow.accessibilityLabel = @"Previous Month";
		[_leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		[_leftArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Left Arrow"] forState:0];
		_leftArrow.frame = CGRectMake(0, 0, 48, 38);
	}
	return _leftArrow;
}
- (UIButton *) rightArrow{
	if(_rightArrow ==nil){
		_rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		_rightArrow.tag = 1;
        _rightArrow.accessibilityLabel = @"Next Month";
		[_rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		_rightArrow.frame = CGRectMake(320-45, 0, 48, 38);
		[_rightArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Right Arrow"] forState:0];
	}
	return _rightArrow;
}
- (UIView *) tileBox{
	if(_tileBox==nil){
		_tileBox = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, _currentTile.frame.size.height)];
		_tileBox.clipsToBounds = YES;
	}
	return _tileBox;
}
- (UIImageView *) shadow{
	if(_shadow ==nil){
		_shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];
	}
	return _shadow;
}

@end