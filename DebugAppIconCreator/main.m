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
    
    CGFloat fontSize = 40;
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
        NSLog( @"%s %s %s", argv[1], argv[2], argv[3] );
        
        // Pull out source, destination and build number from args
        NSString *sourceFilename = [NSString stringWithFormat:@"%s", argv[1]];
        NSString *destFilename = [NSString stringWithFormat:@"%s", argv[2]];
        NSString *buildNr = [NSString stringWithFormat:@"%s", argv[3]];

        
        // Load up our image
        NSData *sourceData = [NSData dataWithContentsOfFile:sourceFilename];
        NSImage *sourceImage = [[NSImage alloc] initWithData:sourceData];

        // Extract out the size of our input image - Note we use pixelsWide and pixelsHigh for image size
        // as NSBitmapImageRep.size doesn't return the display size
        NSBitmapImageRep *sourceImageRep = [[sourceImage representations] objectAtIndex:0];
        NSSize size = NSMakeSize( sourceImageRep.pixelsWide, sourceImageRep.pixelsHigh );
//        NSLog( @"Size - %f, %f,", size.width, size.height );
//        NSLog( @"Source Size - %f, %f,", sourceImageRep.size.width, sourceImageRep.size.height );
        
        // Create a new destination image with the same size as our source image
        NSImage *image = [[NSImage alloc] initWithSize:size];
        
        // Start the drawing
        [image lockFocus];
        
        // Draw the original image first
        [sourceImageRep drawInRect:NSMakeRect( 0, 0, size.width, size.height)];

        // Overlay Drawing stuff goes in here
        
        // Default text to draw is :
        // DEV
        // buildnr>
        
        // Set the text and calculate the size and the font to use to fit into our image
        NSString *text = [NSString stringWithFormat:@"DEV\n%@", buildNr];
        NSFont *f = getFontForText( text, size );
        NSRect textRect = getRectForTextAndFont( text, f, size );

        // Draw faded white background
        // Note we drop down into CGxxx methods as we can't use NSColor for alpha
        // As it doesn't work on headless display
        NSRect rect = NSMakeRect(0, 0, size.width, textRect.size.height );
        CGContextRef        context    = [[NSGraphicsContext currentContext]
                                          graphicsPort];
        CGContextSetRGBFillColor (context, 1,1,1, .5);
        CGContextFillRect (context, CGRectMake (0, 0, rect.size.width,
                                                rect.size.height));

        // Draw text
        [text drawAtPoint:NSMakePoint( 5, 0 ) withAttributes:@{NSForegroundColorAttributeName : [NSColor blackColor],
                                                               NSFontAttributeName : f,
                                                               NSStrokeWidthAttributeName : @(-1.0),
                                                               NSStrokeColorAttributeName : [NSColor blackColor]}];

        // Finished drawing now
        [image unlockFocus];
        
        // Create New image - of the original size - This is because when we create our NSImage above,
        // if we are on a retina mac it decides to create a retina image so our saved image is double the size!
        NSBitmapImageRep *imgRep = [[NSBitmapImageRep alloc]
                                 initWithBitmapDataPlanes:NULL
                                 pixelsWide:size.width
                                 pixelsHigh:size.height
                                 bitsPerSample:8
                                 samplesPerPixel:4
                                 hasAlpha:YES
                                 isPlanar:NO
                                 colorSpaceName:NSCalibratedRGBColorSpace
                                 bytesPerRow:0
                                 bitsPerPixel:0];
        [imgRep setSize:NSMakeSize(size.width, size.height)];
        
        // draw our updated image into this image
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:imgRep]];
        [image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];


        NSData *pngData = [imgRep representationUsingType:NSPNGFileType properties:nil];
        [pngData writeToFile:destFilename atomically:YES];
    }
    return 0;
}


