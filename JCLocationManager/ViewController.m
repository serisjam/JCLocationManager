//
//  ViewController.m
//  JCLocationManager
//
//  Created by Jam on 16/4/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "ViewController.h"
#import "JCLocationGeocoder.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    JCLocationGeocoder *geocoder = [JCLocationGeocoder sharedInstanceForKey:@"ViewController"];
    
    [geocoder reverseGeocode:^(BOOL success) {
        if(success) {
            NSLog(@"%@", geocoder.currentLocation);
            NSLog(@"%@", geocoder.locationPlacemark);
        }
        else {
            NSLog(@"%@", geocoder.error.localizedDescription);
        }
    }];
    
#if DEBUG
    // 2
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 3
    static dispatch_source_t source = nil;
    
    // 4
    __typeof(self) __weak weakSelf = self;
    
    // 5
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 6
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGSTOP, 0, queue);
        
        // 7
        if (source)
        {
            // 8
            dispatch_source_set_event_handler(source, ^{
                // 9
                NSLog(@"Hi, I am: %@", weakSelf);
            });
            dispatch_resume(source); // 10
        }
    });
#endif

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
