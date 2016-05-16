# JCLocationManager
JCLocationManager是一个全局位置管理器
##使用全局定位器

    JCLocationGeocoder *geocoder = [JCLocationGeocoder sharedInstance];
    
    [geocoder geocode:^(BOOL success){
        NSLog(@"%@", geocoder.currentLocation);
    }];
  
##通过KVO新建定位器定位
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
