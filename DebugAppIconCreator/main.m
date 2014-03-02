//
//  main.m
//  DebugAppIconCreator
//
//  Created by Andy Qua on 02/03/2014.
//  Copyright (c) 2014 Andy Qua. All rights reserved.
//

#import <AppKit/AppKit.h>

NSRect getRectForTextAndFont( NSString *text, NSFont *font, NSSize size )
{
    NSRect textRect = [text boundingRectWithSize:NSMakeSize( CGFLOAT_MAX, CGFLOAT_MAX )
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}];
    
    return textRect;
}


NSFont *getFontForText( NSString *text, NSSize size )
{
    size.height = CGFLOAT_MAX;
    
    CGFloat fontSize = 20;
    while (fontSize > 0.0)
    {
        NSFont *f = [NSFont systemFontOfSize:fontSize];
        NSRect textRect = getRectForTextAndFont( text, f, size );
        if (textRect.size.width <= size.width - 10) break;
        
        fontSize -= 1.0;
    }
    
    NSLog( @"using fontSize - %f", fontSize );
    NSFont *font = [NSFont systemFontOfSize:fontSize];
    return font;
}

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        
        [NSApplication sharedApplication];
        
        if ( argc != 4 )
        {
            NSLog( @"Invalid usage!\n\nUse:\nDebugAppIconCreator <source> <dest> <buildnr>" );
            exit( 1 );
        }

        // Debug log - write out arguments
        // NSLog( @"%s %s %s", argv[1], argv[2], argv[3] );

        // Pull out source, destination and build number from args
        NSString *sourceFilename = [NSString stringWithFormat:@"%s", argv[1]];
        NSString *destFilename = [NSString stringWithFormat:@"%s", argv[2]];
        NSString *buildNr = [NSString stringWithFormat:@"%s", argv[3]];
        
        // Load up our image
        NSImage *sourceImage = [[NSImage alloc] initWithContentsOfFile:sourceFilename];

        // Extract out the size of our input image
        NSBitmapImageRep *sourceImageRep = [[sourceImage representations] objectAtIndex:0];
        NSSize size = sourceImageRep.size;
        
        // Create a new destination image with the same size as our source image
        NSImage *image = [[NSImage alloc] initWithSize:size];
        
        // Start the drawing
        [image lockFocus];
        
        // Draw the original image first
        [sourceImage drawInRect:NSMakeRect( 0, 0, size.width, size.height)];

        // Overlay Drawing stuff goes in here
        
        // Default text to draw is :
        // DEV
        // buildnr>
        
        // Set the text and calculate the size and the font to use to fit into our image
        NSString *text = [NSString stringWithFormat:@"DEV\n%@", buildNr];
        NSFont *f = getFontForText( text, size );
        NSRect textRect = getRectForTextAndFont( text, f, size );

        // Draw faded white background
        [[NSColor colorWithWhite:1 alpha:0.5] set];
        NSRectFillUsingOperation(NSMakeRect(0, 0, size.width, textRect.size.height ), NSCompositeSourceOver);
        
        // Draw text
        [text drawAtPoint:NSMakePoint( 5, 0 ) withAttributes:@{NSForegroundColorAttributeName : [NSColor blackColor],
                                                               NSFontAttributeName : f,
                                                               NSStrokeWidthAttributeName : @(-1.0),
                                                               NSStrokeColorAttributeName : [NSColor blackColor]}];

        // Finished drawing now
        [image unlockFocus];

        // Save the new image as a PNG to the destination
        CGImageRef cgRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
        NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
        [newRep setSize:[image size]];
        NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
        [pngData writeToFile:destFilename atomically:YES];
    }
    return 0;
}


