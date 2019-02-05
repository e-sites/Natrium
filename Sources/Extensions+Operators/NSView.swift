//
//  NSView.swift
//  Natrium
//
//  Created by Bas van Kuijck on 24/10/2017.
//

import Foundation
import AppKit

extension NSView {
    func capturedImage() -> NSImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        cacheDisplay(in: bounds, to: rep)

        let image = NSImage(size: bounds.size)
        image.addRepresentation(rep)
        return image
    }
}
