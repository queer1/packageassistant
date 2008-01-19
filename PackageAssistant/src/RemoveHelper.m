//
//  RemoveHelper.m
//  PackageAssistant
//
//  Created by VorteX on 16/01/2008.
//

#import "PackageLib.h"

#import <stdio.h>
#import <string.h>
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    long len;
    char *buf;
    char cmd[1024] = {0};

    // protocol is:
    // expect name length (long)
    // read name
    // delete
    // write result (zero or one, long)
    while(fread(&len, sizeof(len), 1, stdin))
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
        buf = malloc(len);
        fread(buf, len, 1, stdin);
        NSString *objcname = [NSString stringWithCString:buf
            encoding:NSUTF8StringEncoding];
        NSLog(@"About to delete: %@", objcname);
        
        // remove dependencies
        NSArray *deps = [PackageAssistant getPackageDependencies:objcname];
        
        int i;
        for(i = 0; i < [deps count]; i++)
        {
            sprintf(cmd, "/bin/rm -f \"%s\"", 
                [[[deps objectAtIndex:i] filename]
                    cStringUsingEncoding:NSUTF8StringEncoding]);
            NSLog(@"About to execute: %s", cmd);
            system(cmd);
        }
        
        // remove receipt
        sprintf(cmd, "/bin/rm -rf \"%s\"",
            [[PackageAssistant getPackageFile: objcname]
                    cStringUsingEncoding:NSUTF8StringEncoding]);
                
        NSLog(@"About to execute: %s", cmd);
        system(cmd);
        
        free(buf);
        
        // return ok
        len = 1;
        fwrite(&len, sizeof(len), 1, stdout);
        
        [pool release];
    }
    
    return 0;
}
