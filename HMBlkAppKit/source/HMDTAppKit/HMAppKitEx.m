/*
HMAppKitEx.m

Author: Makoto Kinoshita

Copyright 2004-2006 The Shiira Project. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted 
provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions 
  and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of 
  conditions and the following disclaimer in the documentation and/or other materials provided 
  with the distribution.

THIS SOFTWARE IS PROVIDED BY THE SHIIRA PROJECT ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE SHIIRA PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.
*/
/* Copyright © 2007-2008, The Sequential Project
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the the Sequential Project nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE SEQUENTIAL PROJECT ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE SEQUENTIAL PROJECT BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#import "HMAppKitEx.h"
#import "HMFoundationEx.h"

@implementation NSBezierPath (ellipse)

+ (NSBezierPath*)ellipseInRect:(NSRect)rect withRadius:(float)r
{
    float   x, y, w, h;
    x = rect.origin.x;
    y = rect.origin.y;
    w = rect.size.width;
    h = rect.size.height;
    
    // Create ellipse bezier path
    NSBezierPath*   path;
    path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(x, y + r)];
    [path lineToPoint:NSMakePoint(x, y + h - r)];
    [path curveToPoint:NSMakePoint(x + r, y + h) 
            controlPoint1:NSMakePoint(x, y + h - r/2) 
            controlPoint2:NSMakePoint(x + r/2, y + h)];
    [path lineToPoint:NSMakePoint(x + w - r, y + h)];
    [path curveToPoint:NSMakePoint(x + w, y + h - r) 
            controlPoint1:NSMakePoint(x + w - r/2, y + h) 
            controlPoint2:NSMakePoint(x + w, y + h - r/2)];
    [path lineToPoint:NSMakePoint(x + w, y + r)];
    [path curveToPoint:NSMakePoint(x + w - r, y) 
            controlPoint1:NSMakePoint(x + w, y + r/2) 
            controlPoint2:NSMakePoint(x + w - r/2, y)];
    [path lineToPoint:NSMakePoint(x + r, y)];
    [path curveToPoint:NSMakePoint(x, y + r) 
            controlPoint1:NSMakePoint(x + r/2, y) 
            controlPoint2:NSMakePoint(x, y + r/2)];
    [path closePath];
    
    return path;
}

@end

#pragma mark -

@implementation NSDocumentController (MIMEType)

- (NSString*)typeFromMIMEType:(NSString*)MIMEType
{
    // Get info dictionary
    NSDictionary*   infoDict;
    infoDict = [[NSBundle mainBundle] infoDictionary];
    if (!infoDict) {
        return nil;
    }
    
    // Get CFBundleDocumentTypes
    NSArray*    types;
    types = [infoDict objectForKey:@"CFBundleDocumentTypes"];
    if (!types) {
        return nil;
    }
    
    // Enumerate document types
    NSEnumerator*   enumerator;
    NSDictionary*   type;
    enumerator = [types objectEnumerator];
    while (type = [enumerator nextObject]) {
        // Get MIME types
        NSArray*    mimeTypes;
        mimeTypes = [type objectForKey:@"CFBundleTypeMIMETypes"];
        if (!mimeTypes) {
            continue;
        }
        
        // Check MIME type
        NSEnumerator*   mimeEnumerator;
        NSString*       mime;
        mimeEnumerator = [mimeTypes objectEnumerator];
        while (mime = [mimeEnumerator nextObject]) {
            if ([mime isEqualToString:MIMEType]) {
                // Return type name
                return [type objectForKey:@"CFBundleTypeName"];
            }
        }
    }
    
    return nil;
}

@end

#pragma mark -

@implementation NSImage (HMAdditions)

+ (NSImage*)imageWithSize:(NSSize)size
		leftImage:(NSImage*)leftImage
		middleImage:(NSImage*)middleImage
		rightImage:(NSImage*)rightImage
		middleRect:(NSRect*)outMiddleRect
{
	// Filter
	if (!leftImage || !middleImage || !rightImage || ![leftImage size].height || ![rightImage size].height || !size.width || !size.height) {
		return nil;
	}
	
	// Get copy of images
	NSImage *left, *middle, *right;
	left = [[leftImage copy] autorelease];
	middle = [[middleImage copy] autorelease];
	right = [[rightImage copy] autorelease];
	
	float floatHeight;
	int intHeight;
	floatHeight = size.height;
	intHeight = rintf(floatHeight);
	
	// Resize images
	NSSize s;
	int middleWidth;
	s = [left size];
	[left setSize:NSMakeSize(rintf(floatHeight / s.height * s.width), intHeight)];
	s = [right size];
	[right setSize:NSMakeSize(rintf(size.height / s.height * s.width), intHeight)];
	middleWidth = rintf(size.width - ([left size].width + [right size].width));
	if (middleWidth < 1) {
		return nil;
	}
	[middle setSize:NSMakeSize(middleWidth, intHeight)];
	
	// Calculate middle rect
	NSRect middleRect;
	middleRect = NSMakeRect([left size].width, 0, middleWidth, intHeight);
	
	// Make new image
	NSImage *image;
	image = [[NSImage alloc] initWithSize:size];
	[image lockFocus];
	[left drawAtPoint:NSZeroPoint
			fromRect:HMMakeRect(NSZeroPoint, [left size])
			operation:NSCompositeSourceOver
			fraction:1.0];
	[middle drawAtPoint:middleRect.origin
			fromRect:HMMakeRect(NSZeroPoint, [middle size])
			operation:NSCompositeSourceOver
			fraction:1.0];
	[right drawAtPoint:NSMakePoint([left size].width + [middle size].width, 0)
			fromRect:HMMakeRect(NSZeroPoint, [right size])
			operation:NSCompositeSourceOver
			fraction:1.0];
	[image unlockFocus];
	
	// Set outMiddleRect
	if (outMiddleRect) {
		*outMiddleRect = middleRect;
	}
	
	return [image autorelease];
}
+ (NSImage *)HM_imageNamed:(NSString *)name
		for:(id)anObject
		flipped:(BOOL)flag
{
	if(!anObject || !name) return nil;
	Class const class = [anObject class];
	NSString *const fullName = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(class), name];
	NSImage *image = [NSImage imageNamed:fullName];
	if(!image) {
		image = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:class] pathForImageResource:name]] autorelease];
		[image setName:fullName];
	}
	[image setFlipped:flag];
	return image;
}
- (void)drawInRect:(NSRect)dstRect
		fromRect:(NSRect)srcRect
		operation:(NSCompositingOperation)op
		fraction:(float)delta
		contextRect:(NSRect)ctxRect
		isContextFlipped:(BOOL)flag
{
	if (flag) {
		NSAffineTransform *transform;
		transform = [NSAffineTransform transform];
		[transform scaleXBy:1.0 yBy:-1.0];
		[transform concat];
		[transform invert];
		[self drawInRect:[transform transformRect:dstRect] fromRect:srcRect operation:op fraction:delta];
		[transform concat];
	}
	else {
		[self drawInRect:HMFlipRect(dstRect, ctxRect) fromRect:srcRect operation:op fraction:delta];
	}
}
@end

#pragma mark -

@implementation NSTableView (ContextMenu)

- (NSMenu*)menuForEvent:(NSEvent*)event
{
    if ([[self delegate] respondsToSelector:@selector(tableView:menuForEvent:)]) {
        return [(NSObject *)[self delegate] tableView:self menuForEvent:event];
    }
    
    return nil;
}

@end

#pragma mark -

@implementation NSOutlineView (ExpandingAndCollapsing)

- (void)expandAllItems
{
    // Expand items
    int i;
    for (i = 0; i < [self numberOfRows]; i++) {
        id  item;
        item = [self itemAtRow:i];
        
        [self expandItem:item expandChildren:YES];
    }
}

- (void)collapseAllItems
{
    // Collapse items
    int i;
    for (i = 0; i < [self numberOfRows]; i++) {
        id  item;
        item = [self itemAtRow:i];
        
        [self collapseItem:item collapseChildren:YES];
    }
}

@end

@implementation NSOutlineView (ContextMenu)

- (NSMenu*)menuForEvent:(NSEvent*)event
{
    if ([[self delegate] respondsToSelector:@selector(outlineView:menuForEvent:)]) {
        return [(NSObject *)[self delegate] outlineView:self menuForEvent:event];
    }
    
    return nil;
}

- (void)draggedImage:(NSImage*)image 
        endedAt:(NSPoint)point 
        operation:(NSDragOperation)operation
{
    if ([[self delegate] respondsToSelector:@selector(draggedImage:endedAt:operation:)]) {
        [(NSObject *)[self delegate] draggedImage:image endedAt:point operation:operation];
    }
}

@end

#pragma mark -

@implementation NSToolbar (ToolbarItem)

- (NSToolbarItem*)toolbarItemWithIdentifier:(id)identifier
{
    NSArray*        items;
    NSEnumerator*   enumerator;
    NSToolbarItem*  item;
    items = [self items];
    enumerator = [items objectEnumerator];
    while (item = [enumerator nextObject]) {
        if ([[item itemIdentifier] isEqual:identifier]) {
            return item;
        }
    }
    
    return nil;
}

@end

#pragma mark -

@implementation NSView (HMAdditions)

- (BOOL)HM_isActive
{
	if(![[self window] isKeyWindow]) return NO;
	NSResponder *const fr = [[self window] firstResponder];
	if(fr == self) return YES;
	return [fr isKindOfClass:[NSView class]] && [(NSView *)fr isDescendantOf:self];
}

@end

@implementation NSWindow (HMAdditions)

- (NSRect)HM_logicalFrame
{
	return [self frame];
}
- (void)HM_setLogicalFrame:(NSRect)aRect
        display:(BOOL)flag
{
	[self setFrame:aRect display:flag];
}
- (NSRect)HM_resizeRectForView:(NSView *)aView
{
	if(![self showsResizeIndicator]) return NSZeroRect;
	NSView *const c = [self contentView];
	NSRect const b = [c bounds];
	return [c convertRect:NSMakeRect(NSMaxX(b) - 15, NSMinY(b), 15, 15) toView:aView];
}
- (BOOL)HM_trackResize:(BOOL)isResize
        withEvent:(NSEvent *)firstEvent
{
	NSRect const initialFrame = [self HM_logicalFrame];
	NSPoint const firstMousePoint = [[firstEvent window] convertBaseToScreen:[firstEvent locationInWindow]];
	NSScreen *boundingScreen = nil;
	if(isResize) {
		NSScreen *const screen = [self screen];
		if(screen && NSPointInRect(NSMakePoint(NSMaxX(initialFrame) - 1, NSMinY(initialFrame)), [screen visibleFrame])) boundingScreen = screen;
	}

	BOOL dragged = NO;
	NSEvent *latestEvent;
	while((latestEvent = [self nextEventMatchingMask:NSLeftMouseDraggedMask | NSLeftMouseUpMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES]) && [latestEvent type] != NSLeftMouseUp) {
		dragged = YES;
		NSPoint const mousePoint = [[latestEvent window] convertBaseToScreen:[latestEvent locationInWindow]];
		float const dx = mousePoint.x - firstMousePoint.x;
		float const dy = firstMousePoint.y - mousePoint.y;
		NSRect frame = initialFrame;
		if(isResize) {
			frame.size.width += dx;
			frame.size.height += dy;
			frame.origin.y -= dy;

			// Constrain with min and max size
			NSSize  minSize, maxSize;
			minSize = [self minSize];
			maxSize = [self maxSize];
			if(minSize.width > 0 && frame.size.width < minSize.width) frame.size.width = minSize.width;
			if(maxSize.width > 0 && frame.size.width > maxSize.width) frame.size.width = maxSize.width;
			if(minSize.height > 0 && frame.size.height < minSize.height) {
				frame.origin.y += frame.size.height - minSize.height;
				frame.size.height = minSize.height;
			}
			if(maxSize.height > 0 && frame.size.height > maxSize.height) {
				frame.origin.y += frame.size.height - minSize.height;
				frame.size.height = maxSize.height;
			}

			// Constrain to the screen.
			if(boundingScreen) {
				NSRect const s = [boundingScreen visibleFrame];
				if(NSMaxX(frame) > NSMaxX(s)) frame.size.width -= NSMaxX(frame) - NSMaxX(s);
				if(NSMinY(frame) < NSMinY(s)) {
					float const y = NSMinY(frame) - NSMinY(s);
					frame.origin.y -= y;
					frame.size.height += y;
				}
			}
		} else {
			frame.origin.x += dx;
			frame.origin.y -= dy;

			// Constrain by menu bar
			NSArray *const screens = [NSScreen screens];
			if([screens count]) {
				NSScreen *const mainScreen = [screens objectAtIndex:0];
				if([self screen] == mainScreen && NSMaxY(frame) > NSMaxY([mainScreen visibleFrame])) frame.origin.y -= NSMaxY(frame) - NSMaxY([mainScreen visibleFrame]);
			}
		}
		[self HM_setLogicalFrame:frame display:YES];
	}
	[self discardEventsMatchingMask:NSAnyEventMask beforeEvent:latestEvent];
	return dragged;
}

@end
