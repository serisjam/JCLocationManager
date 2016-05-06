//
//  SecondViewController.m
//  JCLocationManager
//
//  Created by Jam on 16/4/26.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "SecondViewController.h"

#import "JCLocationGeocoder.h"

@implementation SecondViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    JCLocationGeocoder *geocoder = [JCLocationGeocoder sharedInstance];
    
    [geocoder geocode:^(BOOL success){
        NSLog(@"%@", geocoder.currentLocation);
    }];
}

@end
