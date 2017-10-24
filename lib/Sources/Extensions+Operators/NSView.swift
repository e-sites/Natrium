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
        guard let rep = self.bitmapImageRepForCachingDisplay(in: self.bounds) else {
            return nil
        }
        self.cacheDisplay(in: self.bounds, to: rep)

        let image = NSImage(size: self.bounds.size)
        image.addRepresentation(rep)
        return image
    }
}
