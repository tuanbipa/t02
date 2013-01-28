//
//  main.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/1/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "AppDelegate.h"
#import "SmartCalAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        //return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        return UIApplicationMain(argc, argv, @"SDApplication", NSStringFromClass([SmartCalAppDelegate class]));
        
    }
}
