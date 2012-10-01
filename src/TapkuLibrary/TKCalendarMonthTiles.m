//
//  TKCalendarMonthTiles
//
//  Created by Sean Freitag on 9/20/12.
//  Copyright 2012 Banno, LLC. All rights reserved.
//


#import "TapkuLibrary.h"
#import "TKCalendarMonthTiles.h"

@interface TKCalendarMonthTilesTile : NSObject

@property (nonatomic) NSUInteger row;
@property (nonatomic) NSUInteger column;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) BOOL selectable;

@end

@implementation TKCalendarMonthTilesTile
@end

@interface TKCalendarMonthTiles ()

@property (nonatomic) BOOL startsOnSunday;
@property (nonatomic) int today;
@property (nonatomic) int firstWeekday;
@property (nonatomic) int daysInMonth;

@property (nonatomic, strong) NSArray *marks;

@property (nonatomic, strong) TKCalendarMonthTilesTile *selectedTile;

@property (nonatomic, strong) NSArray *tiles;

@end

@implementation TKCalendarMonthTiles

#define dotFontSize 18.0
#define dateFontSize 22.0

#define TODAY_TILE          TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Tile.png")
#define TODAY_SELECTED_TILE TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")
#define DATE_TILE           TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile.png")
#define DATE_GRAY_TILE      TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")
#define DATE_SELECTED_TILE  TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")

- (NSArray *)tilesForMonth:(NSDate *)month startsOnSunday:(BOOL)sunday {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSInteger weekday = [calendar components:NSWeekdayCalendarUnit fromDate:month].weekday;
    NSUInteger daysInMonth = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:month].length;

    NSInteger offset = weekday - (sunday ? 1 : 2);
    if (offset < 0) offset = 7 + offset;

    NSUInteger daysInMonthWithOffset = daysInMonth + offset;

    NSUInteger rows = (daysInMonthWithOffset / 7) + (daysInMonthWithOffset % 7 == 0 ? 0 : 1);

    NSMutableArray *array = [NSMutableArray array];

    for (NSUInteger row = 0; row < rows; row++) {
        for (NSUInteger col = 0; col < 7; col++) {
            TKCalendarMonthTilesTile *tile = [[TKCalendarMonthTilesTile alloc] init];
            tile.row = row;
            tile.column = col;
            NSDate *date = [month dateByAddingDays:(row * 7) + col - offset];
            tile.date = date;

            [array addObject:tile];
        }
    }

    return array;
}

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)markArray startDayOnSunday:(BOOL)sunday{
	if(!(self=[super initWithFrame:CGRectZero])) return nil;

    self.marks = markArray;
	self.monthDate = date;
    self.startsOnSunday = sunday;

	TKDateInformation dateInfo = [self.monthDate dateInformation];
    self.firstWeekday = dateInfo.weekday;

    self.tiles = [self tilesForMonth:date startsOnSunday:sunday];

    self.daysInMonth = [[self.monthDate nextMonth] daysBetweenDate:self.monthDate];

	CGFloat h = 44.0f * [date rowsOnCalendarStartingOnSunday:sunday];

	TKDateInformation todayInfo = [[NSDate date] dateInformation];
    self.today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;

	self.frame = CGRectMake(0, 1.0, 320.0f, h+1);

	[self.selectedImageView addSubview:self.currentDay];
	[self.selectedImageView addSubview:self.dot];
	self.multipleTouchEnabled = NO;

	return self;
}

- (void)setDelegate:(id <TKCalendarMonthTilesDelegate>)delegate {
    _delegate = delegate;

    for (TKCalendarMonthTilesTile *tile in self.tiles)
        tile.selectable = [self.delegate calendarMonthTiles:self canSelectDate:tile.date];
}

- (void)drawTileInRect:(CGRect)rect day:(int)day font:(UIFont *)font color:(UIColor *)color {
	NSString *str = [NSString stringWithFormat:@"%d",day];

    [color set];

	rect.size.height -= 2;
	[str drawInRect:rect
		   withFont:font
	  lineBreakMode: NSLineBreakByWordWrapping
		  alignment: NSTextAlignmentCenter];
}

- (void) drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
	UIImage *tile = [UIImage imageWithContentsOfFile:DATE_TILE];
	CGRect r = CGRectMake(0, 0, 46, 44);
	CGContextDrawTiledImage(context, r, tile.CGImage);

    UIFont *font = [UIFont boldSystemFontOfSize:dateFontSize];
    NSCalendar *calendar = [NSCalendar currentCalendar];

    for (TKCalendarMonthTilesTile *dayTile in self.tiles) {
        NSInteger day = [calendar components:NSDayCalendarUnit fromDate:dayTile.date].day;
        CGRect dayRect = CGRectMake(dayTile.column * 46, dayTile.row * 44 + 6, 47, 45);

        UIColor *color = [[dayTile.date monthDate] isEqualToDate:self.monthDate] ? [UIColor colorWithHex:0x006AD4] : [UIColor grayColor];

        if (!dayTile.selectable && [self.monthDate isEqualToDate:[dayTile.date monthDate]])
            color = [UIColor colorWithRed:59 / 255. green:73 / 255. blue:88 / 255. alpha:1];

        if (self.today == day && [[dayTile.date monthDate] isEqualToDate:self.monthDate]) {
            CGRect todayTileRect = dayRect;
            todayTileRect.origin.y -= 7;
            [[UIImage imageWithContentsOfFile:TODAY_TILE] drawInRect:todayTileRect];
            color = [UIColor whiteColor];
        }

        [self drawTileInRect:dayRect day:day font:font color:color];
    }
}

- (void) selectDay:(int)day{
    TKCalendarMonthTilesTile *tile;

    for (TKCalendarMonthTilesTile *dayTile in self.tiles) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger d = [calendar components:NSDayCalendarUnit fromDate:dayTile.date].day;

        if (day == d && [[dayTile.date monthDate] isEqualToDate:self.monthDate]) {
            tile = dayTile;
            break;
        }
    }

	int row = tile.row;
	int column = tile.column;

	if(day == self.today){
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TODAY_SELECTED_TILE];
	}else {
		NSString *path = DATE_SELECTED_TILE;
		self.selectedImageView.image = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	}

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
	return self.selectedTile.date;
}

- (TKCalendarMonthTilesTile *)tileAtPoint:(CGPoint)point {
    int column = (int) (point.x / 46);
    int row    = (int) (point.y / 44);

    for (TKCalendarMonthTilesTile *tile in self.tiles)
        if (tile.selectable && tile.column == column && tile.row == row)
            return tile;

    return nil;
}

- (void)reactToTouch:(UITouch *)touch {
	CGPoint p = [touch locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;

    TKCalendarMonthTilesTile *tile = [self tileAtPoint:p];
    if (self.selectedTile == tile || tile == nil) return;
    self.selectedTile = tile;

	int column = tile.column;
    int row = tile.row;
    int day = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:tile.date].day;

	if(![[tile.date monthDate] isEqualToDate:self.monthDate]) {
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:DATE_GRAY_TILE];
	} else if(day == self.today){
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TODAY_SELECTED_TILE];
	} else {
		NSString *path = DATE_SELECTED_TILE;
		self.selectedImageView.image = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	}

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
	r.origin.x = (column * 46);
	r.origin.y = (row * 44)-1;
	self.selectedImageView.frame = r;

    [self.delegate dateWasSelected:tile.date];
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

		NSString *path = DATE_SELECTED_TILE;
		UIImage *img = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
		_selectedImageView = [[UIImageView alloc] initWithImage:img];
		_selectedImageView.frame = CGRectMake(0, 0, 47, 45);
        [self addSubview:_selectedImageView];
	}
	return _selectedImageView;
}

@end