//
//  TKCalendarMonthTiles
//
//  Created by Sean Freitag on 9/20/12.
//  Copyright 2012 Banno, LLC. All rights reserved.
//


#import "TKCalendarMonthTiles.h"
#import "TapkuLibrary.h"


@interface TKCalendarMonthTiles ()

@property (nonatomic) BOOL startsOnSunday;
@property (nonatomic) BOOL markWasOnToday;
@property (nonatomic) int today;
@property (nonatomic) int firstOfPrev;
@property (nonatomic) int lastOfPrev;
@property (nonatomic) int selectedDay;
@property (nonatomic) int selectedPortion;
@property (nonatomic) int firstWeekday;
@property (nonatomic) int daysInMonth;

@property (nonatomic, strong) NSArray *marks;

@end

@implementation TKCalendarMonthTiles

#define dotFontSize 18.0
#define dateFontSize 22.0

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)markArray startDayOnSunday:(BOOL)sunday{
	if(!(self=[super initWithFrame:CGRectZero])) return nil;

    self.firstOfPrev = -1;
    self.marks = markArray;
	self.monthDate = date;
    self.startsOnSunday = sunday;

	TKDateInformation dateInfo = [self.monthDate dateInformation];
    self.firstWeekday = dateInfo.weekday;


	NSDate *prev = [self.monthDate previousMonth];
    self.daysInMonth = [[self.monthDate nextMonth] daysBetweenDate:self.monthDate];

	CGFloat h = 44.0f * [date rowsOnCalendarStartingOnSunday:sunday];

	TKDateInformation todayInfo = [[NSDate date] dateInformation];
    self.today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;

	int preDayCnt = [prev daysBetweenDate:self.monthDate];
	if(self.firstWeekday >1 && sunday){
        self.firstOfPrev = preDayCnt - self.firstWeekday +2;
        self.lastOfPrev = preDayCnt;
	}else if(!sunday && self.firstWeekday != 2){

		if(self.firstWeekday ==1){
            self.firstOfPrev = preDayCnt - 5;
		}else{
            self.firstOfPrev = preDayCnt - self.firstWeekday +3;
		}
        self.lastOfPrev = preDayCnt;
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
	  lineBreakMode: NSLineBreakByWordWrapping
		  alignment: NSTextAlignmentCenter];

	if(mark){
		r.size.height = 10;
		r.origin.y += 18;

		[@"•" drawInRect: r
				withFont: f2
		   lineBreakMode: NSLineBreakByWordWrapping
			   alignment: NSTextAlignmentCenter];
	}



}
- (void) drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
	UIImage *tile = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile.png")];
	CGRect r = CGRectMake(0, 0, 46, 44);
	CGContextDrawTiledImage(context, r, tile.CGImage);

	if(self.today > 0){
		int pre = self.firstOfPrev > 0 ? self.lastOfPrev - self.firstOfPrev + 1 : 0;
		int index = self.today +  pre-1;
		CGRect r =[self rectForCellAtIndex:index];
		r.origin.y -= 7;
		[[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Tile.png")] drawInRect:r];
	}

	int index = 0;

	UIFont *font = [UIFont boldSystemFontOfSize:dateFontSize];
	UIFont *font2 =[UIFont boldSystemFontOfSize:dotFontSize];
	UIColor *color = [UIColor grayColor];

	if(self.firstOfPrev >0){
		[color set];
		for(int i = self.firstOfPrev;i<= self.lastOfPrev;i++){
			r = [self rectForCellAtIndex:index];
			if ([self.marks count] > 0)
				[self drawTileInRect:r day:i mark:[[self.marks objectAtIndex:index] boolValue] font:font font2:font2];
			else
				[self drawTileInRect:r day:i mark:NO font:font font2:font2];
			index++;
		}
	}


	color = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	[color set];
	for(int i=1; i <= self.daysInMonth; i++){

		r = [self rectForCellAtIndex:index];
		if(self.today == i) [[UIColor whiteColor] set];

		if ([self.marks count] > 0)
			[self drawTileInRect:r day:i mark:[[self.marks objectAtIndex:index] boolValue] font:font font2:font2];
		else
			[self drawTileInRect:r day:i mark:NO font:font font2:font2];
		if(self.today == i) [color set];
		index++;
	}

	[[UIColor grayColor] set];
	int i = 1;
	while(index % 7 != 0){
		r = [self rectForCellAtIndex:index] ;
		if ([self.marks count] > 0)
			[self drawTileInRect:r day:i mark:[[self.marks objectAtIndex:index] boolValue] font:font font2:font2];
		else
			[self drawTileInRect:r day:i mark:NO font:font font2:font2];
		i++;
		index++;
	}


}

- (void) selectDay:(int)day{

	int pre = self.firstOfPrev < 0 ?  0 : self.lastOfPrev - self.firstOfPrev + 1;

	int tot = day + pre;
	int row = tot / 7;
	int column = (tot % 7)-1;

    self.selectedDay = day;
	self.selectedPortion = 1;


	if(day == self.today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];
        self.markWasOnToday = YES;
	}else if(self.markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);



		NSString *path = TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png");
		self.selectedImageView.image = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        self.markWasOnToday = NO;
	}



	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];

	if ([self.marks count] > 0) {

		if([[self.marks objectAtIndex:row * 7 + column] boolValue]){
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

- (NSDate *)dateSelected {
	if(self.selectedDay < 1 || self.selectedPortion != 1) return nil;

	return [self.monthDate dateByAddingDays:(NSUInteger) self.selectedDay];
}

- (void)reactToTouch:(UITouch *)touch {

	CGPoint p = [touch locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;

	int column = p.x / 46, row = p.y / 44;
	int day = 1, portion = 0;

	if(row == (int) (self.bounds.size.height / 44)) row --;

	int fir = self.firstWeekday - 1;
	if(!self.startsOnSunday && fir == 0) fir = 7;
	if(!self.startsOnSunday) fir--;


	if(row==0 && column < fir){
		day = self.firstOfPrev + column;
	}else{
		portion = 1;
		day = row * 7 + column  - self.firstWeekday +2;
		if(!self.startsOnSunday) day++;
		if(!self.startsOnSunday && fir==6) day -= 7;

	}
	if(portion > 0 && day > self.daysInMonth){
		portion = 2;
		day = day - self.daysInMonth;
	}


	if(portion != 1){
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
        self.markWasOnToday = YES;
	}else if(portion==1 && day == self.today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];
        self.markWasOnToday = YES;
	}else if(self.markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);


		NSString *path = TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png");
		self.selectedImageView.image = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];

        self.markWasOnToday = NO;
	}

	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];

	if ([self.marks count] > 0) {
		if([[self.marks objectAtIndex:row * 7 + column] boolValue])
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

	if(day == self.selectedDay && self.selectedPortion == portion) return;



    self.selectedDay = day;
    self.selectedPortion = portion;

    NSDate *monthDate;
    if (portion == 1)
        monthDate = self.monthDate;
    else if (portion == 2)
        monthDate = [self.monthDate nextMonth];
    else
        monthDate = [self.monthDate previousMonth];

    [self.delegate dateWasSelected:[monthDate dateByAddingDays:(NSUInteger) (day - 1)]];
}

#pragma mark UIResponder touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self reactToTouch:[touches anyObject]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self reactToTouch:[touches anyObject]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self reactToTouch:[touches anyObject]];
}

#pragma mark Properties

- (UILabel *) currentDay{
	if(_currentDay ==nil){
		CGRect r = self.selectedImageView.bounds;
		r.origin.y -= 2;
		_currentDay = [[UILabel alloc] initWithFrame:r];
		_currentDay.text = @"1";
		_currentDay.textColor = [UIColor whiteColor];
		_currentDay.backgroundColor = [UIColor clearColor];
		_currentDay.font = [UIFont boldSystemFontOfSize:dateFontSize];
		_currentDay.textAlignment = NSTextAlignmentCenter;
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
		_dot.textAlignment = NSTextAlignmentCenter;
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