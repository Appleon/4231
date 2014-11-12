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
@property (nonatomic, readwrite) NSUInteger duration;
@property (nonatomic, readwrite) NSUInteger colorsCount;
@property (nonatomic, readwrite) NSUInteger fontsCount;
@property (nonatomic, readwrite) BOOL isDone;
@property (nonatomic, readwrite) BOOL isComplete;
@end

@implementation NCGame
- (instancetype) initWithTotal:(NSUInteger)total
{
    self = [super init];
    
    if (self) {
        self.total = total;
        self.isDone = NO;
        self.isComplete = NO;
        
        // filling up
        for (NSUInteger i = 1; i <= total; i++) {
            NCCell *cell = [[NCCell alloc] init];
            cell.value = i;
//            cell.color = arc4random() % self.colorsCount;
//            cell.fontSize = arc4random() % self.fontsCount;
            
            [self.items addObject:cell];
        }
        
        
        //randomizing
        for (int i = 0; i < [self.items count]; i++) {
            NCCell *cell = [self.items objectAtIndex:i];
            int newIndex = arc4random() % [self.items count];

            if (newIndex != i) {
                self.items[i] = self.items[newIndex];
                self.items[newIndex] = cell;
            }
        }

    }

    return self;
}

- (NSMutableArray*)items
{
    if (!_items) _items = [[NSMutableArray alloc] init];
    return _items;
}

- (BOOL)select:(NSUInteger)index
{
    NCCell *cell = self.items[index];
    
    if (self.currentNumber + 1 == cell.value) {
        self.currentNumber++;
        self.currentIndex++;
        
        if (self.currentIndex >= [self.items count]) {
            self.isComplete = YES;
            [self finish];
        }

        return YES;
    } else {
        return NO;
    }
}

- (void)timerTick
{
    self.duration++;
    
//    NSLog(@"tick %lu", (unsigned long)self.duration);
}

- (void) start
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    
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
//        [def removeObjectForKey:@"log"];
        // seems like a hack
        id obj = [def objectForKey:@"log"];
        NSMutableArray *log;
        if (nil == obj) {
            log = [[NSMutableArray alloc] init];
        } else {
            log = [obj mutableCopy];
        }
        
//        NSLog(@"%@", [NSMutableArray class]);
        
        [log addObject:@[date, [NSNumber numberWithUnsignedInteger:self.total], [NSNumber numberWithUnsignedInteger:self.duration]]];
        
        [def setObject:log forKey:@"log"];
        [def synchronize];

    } else {
        NSLog(@"game not done :(");
    }
}

- (float)getSpeed {
    return (float)self.total / (float)self.duration;
}

+ (NSMutableArray*)log {
    NSUserDefaults *def = [[NSUserDefaults alloc] init];
    NSMutableArray *log = [def objectForKey:@"log"];
    if (nil == log) {
        log = [[NSMutableArray alloc] init];
    }
    return log;
}

+ (NSMutableDictionary*)stats {
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    NSMutableArray *log = [self log];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY.MM.dd"];
    
    for (id obj in log) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *item = obj;
            int total = [item[1] intValue];
            int time  = [item[2] intValue];
            float speed = (float)total / (float)time;
            NSDate *date = item[0];

            NSMutableDictionary *part = [stats objectForKey:[NSString stringWithFormat:@"%d", total]];
            NSString *key;
            if (nil == part) {
                part = [[NSMutableDictionary alloc] init];
                key = [NSString stringWithFormat:@"%d", total];
                stats[key] = part;
            }
            
            key = [formatter stringFromDate:date];
            NSNumber *val = [part objectForKey:key];
            if (nil == val) {

                [part setObject:[NSNumber numberWithFloat:speed] forKey:key];
            } else {
                [part setObject:[NSNumber numberWithFloat:(([val floatValue] + speed) / 2.)] forKey:key];
            }
            
        }
    }
    
    return stats;
}

+ (NSMutableDictionary*)statsForDay {
    
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
            NSDate *date = item[0];
            
            //            NSLog(@"%d", total);
            
            NSMutableDictionary *part = [stats objectForKey:[NSString stringWithFormat:@"%d", total]];
            NSString *key;
            if (nil == part) {
                part = [[NSMutableDictionary alloc] init];
                key = [NSString stringWithFormat:@"%d", total];
                stats[key] = part;
            }
            
            key = [formatter stringFromDate:date];
            NSNumber *val = [part objectForKey:key];
            if (nil == val) {
                //                NSLog(@"%f", speed);
                [part setObject:[NSNumber numberWithFloat:speed] forKey:key];
            } else {
                [part setObject:[NSNumber numberWithFloat:(([val floatValue] + speed) / 2.)] forKey:key];
            }
            
        }
    }

    return stats;
}
@end
