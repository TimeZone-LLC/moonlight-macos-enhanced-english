//
//  main.m
//  Moonlight for macOS
//
//  Created by Michael Kenny on 22/12/17.
//  Copyright © 2017 Moonlight Stream. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [NSUserDefaults.standardUserDefaults setObject:@[@"en"] forKey:@"AppleLanguages"];
        [NSUserDefaults.standardUserDefaults setObject:@"English" forKey:@"appLanguage"];
    }
    return NSApplicationMain(argc, argv);
}
 
