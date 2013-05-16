//
//  main.m
//  ohttpd
//
//  Created by Maxthon Chan on 13-5-16.
//  Copyright (c) 2013年 muski. All rights reserved.
//

#import <CGIKit/CGIKit.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool
    {
        
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        NSArray *args = [processInfo arguments];
        
        // Status fields
        NSUInteger operation = 0; // 0 = error
                                  // 1 = start
                                  // 2 = stop
                                  // 3 = reload
        NSString *confFile = nil;
        NSString *identifier = nil;
        
        for (NSUInteger i = 1; i < [args count]; i++)
        {
            NSString *arg = [args[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if ([arg isEqualToString:@"--start"])
                operation = 1;
            else if ([arg isEqualToString:@"--stop"])
                operation = 2;
            else if ([arg isEqualToString:@"--relaod"])
                operation = 3;
            else if ([arg isEqualToString:@"--config-file"])
                confFile = [args[++i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            else if ([arg isEqualToString:@"--identifier"])
                identifier = [args[++i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            else
            {
                eprintf("ohttpd: error: unrecognized argument: %s\n", CGICSTR(arg));
                exit(1);
            }
        }
        
        switch (operation)
        {
            case 1: // start
            {
                CGIServer *server = [CGIServer server];
                
                server.instanceIdentifier = identifier;
                server.configFilePath = confFile;
                
                [server start];
                
                break;
            }
            case 2: // stop
            {
                NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
                [dnc postNotificationName:CGIServerStopNotification
                                   object:identifier];
                break;
            }
            case 3:
            {
                NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
                [dnc postNotificationName:CGIServerReloadNotification
                                   object:identifier];
                break;
            }
            default:
            {
                eprintf("ohttpd: error: cannot determine what to do.\n"
                        "specify --start, --stop or --reload\n");
                exit(1);
                break;
            }
        }
        
    }
    return 0;
}

