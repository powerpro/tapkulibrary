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

@property (nonatomic, strong) TKCalendarMonthTilesTile *selectedTile;
@property (nonatomic, strong, readonly) UILabel *currentDay;

@property (nonatomic, strong) NSArray *tiles;

@end

@implementation TKCalendarMonthTiles {
    UILabel *_currentDay;
}

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

- (id)initWithMonth:(NSDate *)date startDayOnSunday:(BOOL)sunday {
	if(!(self=[super initWithFrame:CGRectZero])) return nil;

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

	self.multipleTouchEnabled = NO;

	return self;
}

- (void)setDelegate:(id <TKCalendarMonthTilesDelegate>)delegate {
    _delegate = delegate;
    [self updateSelectableDays];
}

- (void)updateSelectableDays {
    for (TKCalendarMonthTilesTile *tile in self.tiles) {
        tile.selectable = [self.delegate calendarMonthTiles:self canSelectDate:tile.date];
    }
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

        UIColor *color = ([[dayTile.date monthDate] isEqualToDate:self.monthDate]
                          ? [UIColor colorWithRed:0.224 green:0.278 blue:0.337 alpha:1.000]
                          : [UIColor grayColor]);
        if (!dayTile.selectable && [self.monthDate isEqualToDate:[dayTile.date monthDate]])
            color = [UIColor colorWithRed:0.438 green:0.492 blue:0.550 alpha:1.000];

        if (self.today == day && [[dayTile.date monthDate] isEqualToDate:self.monthDate]) {
            CGRect todayTileRect = dayRect;
            todayTileRect.origin.y -= 7;
            [[UIImage imageWithContentsOfFile:TODAY_TILE] drawInRect:todayTileRect];
            color = [UIColor whiteColor];
        }

        [self drawTileInRect:dayRect day:day font:font color:color];
    }
}

- (void)selectDate:(NSDate *)date {
    TKCalendarMonthTilesTile *tile = nil;

    for (TKCalendarMonthTilesTile *dayTile in self.tiles) {
        if ([dayTile.date isSameDay:date]) {
            tile = dayTile;
            break;
        }
    }

    if (tile == nil) return;
    
    if(![[tile.date monthDate] isEqualToDate:self.monthDate])
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:DATE_GRAY_TILE];
    else if ([date isSameDay:[NSDate date]])
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TODAY_SELECTED_TILE];
	else
        self.selectedImageView.image = [[UIImage imageWithContentsOfFile:DATE_SELECTED_TILE] stretchableImageWithLeftCapWidth:1 topCapHeight:0];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    self.currentDay.text = [NSString stringWithFormat:@"%d", [calendar components:NSDayCalendarUnit fromDate:date].day];
    NSLog(@"tile column %d and row %d", tile.column, tile.row);
    NSNumber *row = [NSNumber numberWithInt:tile.row];
    CGFloat xpos = (row.floatValue * 44) - 1;
    CGRect r = CGRectMake(tile.column * 46, xpos, self.selectedImageView.frame.size.width, self.selectedImageView.frame.size.height);
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

- (UIImageView *) selectedImageView{
	if(_selectedImageView ==nil){

		NSString *path = DATE_SELECTED_TILE;
		UIImage *img = [[UIImage imageWithContentsOfFile:path] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
		_selectedImageView = [[UIImageView alloc] initWithImage:img];
		_selectedImageView.frame = CGRectMake(0, 0, 47, 45);
        [self.selectedImageView addSubview:self.currentDay];
        [self addSubview:_selectedImageView];
	}
	return _selectedImageView;
}

@end