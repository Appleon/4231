//
//  Game.m
//  attention
//
//  Created by Max on 18/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCGame.h"
#import "NCCell.h"
@interface NCGame()
@property (readwrite, nonatomic) NSUInteger total;
@property (strong, nonatomic) NSMutableArray *items;
@property (nonatomic, readwrite) NSUInteger currentNumber;
@property (nonatomic, readwrite) NSUInteger currentIndex;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, readwrite) NSNumber *duration;
@property (nonatomic, readwrite) NSUInteger colorsCount;
@property (nonatomic, readwrite) NSUInteger fontsCount;
@property (nonatomic, readwrite) BOOL isDone;
@property (nonatomic, readwrite) BOOL isComplete;
@property (nonatomic, readwrite) BOOL isStarted;
@property (nonatomic, readwrite) NSUInteger clicked;
@property (nonatomic, readwrite) NSUInteger clickedWrong;
@property (nonatomic, readwrite) NSMutableArray *randomizedSequence;
@property (nonatomic, readwrite) NSDate *startTime;
@end

@implementation NCGame

- (instancetype) initWithTotal:(NSUInteger)total
{
    self = [super init];
    
    if (self) {
        self.total = total;
        self.timeLimit = 30;
        self.difficultyLevel = 0;
        self.sequenceLevel = 0;
        self.clicked = 0;
        self.clickedWrong = 0;
        self.currentIndex = 0;
        
        self.isStarted = NO;
        self.isDone = NO;
        self.isComplete = NO;
        self.duration = [NSNumber numberWithFloat:.0];
    }

    return self;
}

- (NSMutableArray*)items
{
    if (!_items) _items = [[NSMutableArray alloc] init];
    return _items;
}

- (BOOL)select:(NSUInteger)index value:(NSString*)value
{
    NCCell *cell = self.items[self.currentIndex];
    
    NSString *current = self.sequence[self.currentIndex];
    
    if ([current isEqualToString:value]) {
        self.currentIndex++;
        self.clicked++;
        
        if (self.currentIndex >= [self.items count]) {
            self.isComplete = YES;
            [self finish];
        }

        return YES;
    } else {
        self.clickedWrong++;
        return NO;
    }
}

- (NSNumber*)getDuration {

    if (self.isStarted && !self.isDone) {
        NSDate *currentTime = [NSDate date];
        NSTimeInterval timeDifference =  [currentTime timeIntervalSinceDate:self.startTime];
        self.duration = [NSNumber numberWithDouble:timeDifference];
    }
    
    return self.duration;
}

- (BOOL)getIsDone {
    if ([[self getDuration] floatValue] >= [[NSNumber numberWithInteger:self.timeLimit] floatValue]) {
        self.isDone = YES;
    }
    
    return self.isDone;
}

+ (NSArray*)getSymbols:(NSString*)key {
    //    @[@"А", @"Б", @"В", @"Г", @"Д", @"Е", @"Ж", @"З", @"И", @"К", @"Л", @"М", @"Н", @"О", @"П", @"Р", @"С", @"Т", @"У", @"Ф", @"Х", @"Ц", @"Ч", @"Ш", @"Щ", @"Ъ", @"Ы", @"Ь", @"Э", @"Ю", @"Я"];
    
    NSMutableArray *numbersFrom1 = [[NSMutableArray alloc] init];
    for (NSUInteger i = 1; i < 100; i++) {
        [numbersFrom1 addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    NSDictionary *symbols = @{
                              @"numbersFrom1" : numbersFrom1,
                              @"numbers" : @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"],
                              @"numbersLetters" : @[
                                                    @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N",
                                                    @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z",
                                                    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                                                    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                                                    ],
                              
                              @"letters" : @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                                             @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W",
                                             @"X", @"Y", @"Z"],
                              @"emoji" : @[@"🌳", @"🎄", @"🎼", @"🎭", @"🏁", @"🍄", @"🍀", @"🌍", @"🌚", @"🍍", @"🍒", @"🍴", @"🎃", @"🚲", @"🚧", @"🚀", @"📖", @"👣", @"👻", @"👽", @"🌴", @"🐲", @"🐬", @"☔️", @"🎸", @"⚽️", @"😱", @"🌻", @"⛅️", @"❄️", @"🍉", @"🎁", @"🎯", @"🚜", @"🏠", @"📱", @"⌚️", @"🎥", @"💾", @"💿", @"📡", @"💰", @"🔑"],
                              @"katakana" : @[@"ア",@"イ",@"ウ",@"エ",@"オ",@"カ",@"キ",@"ク",@"ケ",@"コ",@"サ",@"シ",@"ス",@"セ",@"ソ"]
                              };

    return symbols[key];
}

+ (NSArray*)getSequencesParams {

    NSArray *sequencesSettings = @[
                     @{
                         @"id" : @"numbers",
                         @"symbols" : @"numbersFrom1",
                         @"label" : @"Numbers"
                         },
                     @{
                         @"id" : @"letters",
                         @"symbols" : @"letters",
                         @"label" : @"Letters"
                         },
                     @{
                         @"id" : @"emoji",
                         @"symbols" : @"emoji",
                         @"label" : @"Random Emoji",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     @{
                         @"id" : @"randomNumbers",
                         @"symbols" : @"numbers",
                         @"label"   : @"Random numbers",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     @{
                         @"id" : @"randomNumbersLetters",
                         @"symbols" : @"numbersLetters",
                         @"label"   : @"Random numbers & letters",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     @{
                         @"id" : @"katakana",
                         @"symbols" : @"katakana",
                         @"label" : @"Katakana (don't be scared)"
                         },
                     @{
                         @"id" : @"randomKatakana",
                         @"symbols" : @"katakana",
                         @"label"   : @"Random Katakana %)",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     ];
    
    return sequencesSettings;
}

+ (NSDictionary*)getSequenceParams:(NSUInteger)level {
    NSArray *sequencesSettings = [NCGame getSequencesParams];
    
    if (level > [sequencesSettings count]) {
        level = 0;
    }
    
    NSDictionary *settings = [sequencesSettings objectAtIndex:level];
    
    return settings;
}

- (NSMutableArray*)getSequence:(NSUInteger)sequenceLevel difficultyLevel:(NSUInteger)difficultyLevel {
    NSMutableArray *sequence;

    NSDictionary *settings = [NCGame getSequenceParams:sequenceLevel];
    
    NSArray *symbols = [NCGame getSymbols:[settings objectForKey:@"symbols"]];
    
    if (nil == [settings objectForKey:@"generator"]) {
        sequence = [NCGame createLimitSequence:self.total symbols:symbols];
    } else {
        SEL selector = NSSelectorFromString([settings objectForKey:@"generator"]);
        sequence = [self performSelector:selector withObject:symbols];
        sequence = [NCGame createLimitSequence:self.total symbols:sequence];
    }
    
    return sequence;
}

+ (NSMutableArray*)createLimitSequence:(NSUInteger)total symbols:(NSArray*)symbols {
    NSMutableArray *sequence = [[NSMutableArray alloc] init];
    
    NSString *val;
    NSUInteger symbolsCount = [symbols count];

    for (NSUInteger i = 0; i < total; i++) {

        if (i < symbolsCount) {
            val = [NSString stringWithFormat:@"%@", [symbols objectAtIndex:i]];
        } else if (i < symbolsCount * 2){
            val = [NSString stringWithFormat:@"%@%@",
                   [symbols objectAtIndex:0],
                   [symbols objectAtIndex:i - symbolsCount]
                   ];
        } else {
            break;
        }

        [sequence addObject:[NSString stringWithFormat:@"%@", val]];
    }

    return sequence;
}

- (void)generateItems:(BOOL)reverse {
    [self.sequence enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NCCell *cell = [[NCCell alloc] init];
        
        cell.value = idx;
        cell.text = obj;
        [self.items addObject:cell];
    }];
}

+ (NSMutableArray*)randomizeArray:(NSMutableArray*)itemsOriginal {
    NSMutableArray *items = itemsOriginal.mutableCopy;
    
    for (int i = 0; i < [items count]; i++) {
        NCCell *cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}


+ (NSMutableArray*)randomize:(NSMutableArray*)itemsOriginal {
    NSMutableArray *items = itemsOriginal.mutableCopy;
    
    for (int i = 0; i < [items count]; i++) {
        NCCell *cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}

- (NSArray*)getRandomizedSequence:(NSArray*)sequenceOriginal {
    NSMutableArray *items = sequenceOriginal.mutableCopy;
    
    for (int i = 0; i < [items count]; i++) {
        NCCell *cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}

- (NSArray*)getItems {

    // filling up
    self.sequence = [self getSequence:self.sequenceLevel difficultyLevel:self.difficultyLevel];

    [self generateItems:NO];
    
    //randomizing
    self.items = [NCGame randomize:self.items];
    
    return self.items;
}

- (void) start
{
    self.startTime = [NSDate date];
    self.isStarted = YES;
}
- (void) finish
{
    if (self.isDone) {
        return;
    }
    self.isDone = YES;
    
    if(self.timer) {
        [self.timer invalidate];
    }
    
    if (self.isComplete) {
        NSLog(@"GAME IS DONE!");

        NSDate *date = [NSDate date];
        
        NSUserDefaults *def = [[NSUserDefaults alloc] init];
        // seems like a hack
        id obj = [def objectForKey:@"log"];
        NSMutableArray *log;
        if (nil == obj) {
            log = [[NSMutableArray alloc] init];
        } else {
            log = [obj mutableCopy];
            for (NSUInteger i = 0; i < [log count]; i++) {
                id obj = [log objectAtIndex:i];
                if (![obj isKindOfClass:[NSDictionary class]]) {
                    [log removeObjectAtIndex:i];
                }
            }
        }
        
        NSDictionary *settings = [NCGame getSequenceParams:self.sequenceLevel];

        NSDictionary *entry = @{
                                @"date" : date,
                                @"total" : [NSString stringWithFormat:@"%lu", self.total],
                                @"id" : [settings objectForKey:@"id"],
                                @"difficulty" : [NSString stringWithFormat:@"%lu", self.difficultyLevel],
                                @"duration" : self.duration,
                                @"clicked" : [NSString stringWithFormat:@"%lu", self.clicked],
                                @"clickedWrong" : [NSString stringWithFormat:@"%lu", self.clickedWrong],
                             };
        
        [log addObject:entry];
        
        [def setObject:log forKey:@"log"];
        [def synchronize];

    } else {
        NSLog(@"game not done :(");
    }
}

- (float)getSpeed {
    return (float)self.clicked / ([[self getDuration] floatValue]);
}

+ (NSMutableArray*)log {
    NSUserDefaults *def = [[NSUserDefaults alloc] init];
    NSMutableArray *log = [def objectForKey:@"log"];
    if (nil == log) {
        log = [[NSMutableArray alloc] init];
    }
    return log;
}

+ (NSMutableDictionary*)stats:(NSString*)keyFormat {
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *days = [[NSMutableDictionary alloc] init];
    NSMutableArray *log = [self log];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:keyFormat];
    
    NSNumber *totalMax;
    NSNumber *totalAvg;
    NSNumber *totalMin;

    for (id obj in log) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        NSDictionary *item = obj;
        float gameScore;
        NSDate *date = [item objectForKey:@"date"];
        // calculate item value
        float total = [[item objectForKey:@"total"] floatValue];
        float time  = [[item objectForKey:@"duration"] floatValue];
        
        if (!time || time > 1000000) {
            continue;
        }

        float speed = total / time;

        gameScore = speed * total;
        
        float percent = gameScore / 100.;
        
        gameScore = gameScore - percent * [[item objectForKey:@"clickedWrong"] floatValue];
        gameScore = gameScore + (percent*10.) * [[item objectForKey:@"difficulty"] floatValue];

        NSString *dayKey = [formatter stringFromDate:date];
        
        /*
         
         dayLog [
            date = [
                avg   = ...
                max   = ...
                min   = ...
            ],
            avg = ...
            max = ...
            min = ...
         ]
         
         */
        
        NSMutableDictionary *dayLog = [days objectForKey:dayKey];
        if (nil == dayLog) {
            dayLog = [[NSMutableDictionary alloc] init];
            days[dayKey] = dayLog;
        }

        
        NSNumber *dayAvg = [dayLog objectForKey:@"avg"];
        NSNumber *dayMax = [dayLog objectForKey:@"max"];
        NSNumber *dayMin = [dayLog objectForKey:@"min"];
        
        if (nil == dayAvg) {
            dayAvg = [NSNumber numberWithFloat:gameScore];
        } else {
            dayAvg = [NSNumber numberWithFloat:([dayAvg floatValue] + gameScore) / 2.];
        }
        
        if (nil == dayMax || [dayMax floatValue] < gameScore) {
            dayMax = [NSNumber numberWithFloat:gameScore];
        }

        if (nil == dayMin || [dayMin floatValue] > gameScore) {
            dayMin = [NSNumber numberWithFloat:gameScore];
        }
        
        [dayLog setObject:dayAvg forKey:@"avg"];
        [dayLog setObject:dayMax forKey:@"max"];
        [dayLog setObject:dayMin forKey:@"min"];

        if (nil == totalAvg) {
            totalAvg = [NSNumber numberWithFloat:gameScore];
        } else {
            totalAvg = [NSNumber numberWithFloat:([totalAvg floatValue] + gameScore) / 2.];
        }
        
        if (nil == totalMax || [totalMax floatValue] < gameScore) {
            totalMax = [NSNumber numberWithFloat:gameScore];
        }
        
        if (nil == totalMin || [totalMin floatValue] > gameScore) {
            totalMin = [NSNumber numberWithFloat:gameScore];
        }
    }
    
    [stats setObject:totalMax forKey:@"max"];
    [stats setObject:totalAvg forKey:@"avg"];
    [stats setObject:totalMin forKey:@"min"];
    [stats setObject:days forKey:@"days"];
    
    return stats;
}

+ (NSMutableDictionary*)statsForDay {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    return result;
    // TODO: не делить на totalsб среднее считать из всех записей за час, только данное количество есть в каждом часу
    // напрмиер, если в каждом часу считали 15 и 42, а в одном или в нескольких, но не во всех, 24, то среднее берется только
    // из 15 и 42,  24 исключается
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    NSMutableArray *log = [self log];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH"];
    
    for (id obj in log) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *item = obj;
            int total = [item[1] intValue];
            int time  = [item[2] intValue];
            float speed = (float)total / (float)time;
            
            speed = speed * total;

            NSDate *date = item[0];
            
            //            NSLog(@"%d", total);
            
            NSMutableDictionary *dayLog = [stats objectForKey:[NSString stringWithFormat:@"%d", total]];
            NSString *dayKey;
            if (nil == dayLog) {
                dayLog = [[NSMutableDictionary alloc] init];
                dayKey = [NSString stringWithFormat:@"%d", 42];
                stats[dayKey] = dayLog;
            }
            
            dayKey = [formatter stringFromDate:date];
            NSNumber *val = [dayLog objectForKey:dayKey];
            if (nil == val) {
                //                NSLog(@"%f", speed);
                [dayLog setObject:[NSNumber numberWithFloat:speed] forKey:dayKey];
            } else {
                [dayLog setObject:[NSNumber numberWithFloat:(([val floatValue] + speed) / 2.)] forKey:dayKey];
            }
            
        }
    }

    return stats;
}
@end
