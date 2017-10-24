//
//  NSImage.swift
//  Natrium
//
//  Created by Bas van Kuijck on 24/10/2017.
//

import Foundation
import AppKit

extension NSImage {
    func resize(to size: CGSize) -> NSImage {
        let scale = CGFloat((self.representations.first?.pixelsWide) ?? Int(self.size.width)) / self.size.width
        let size = NSSize(width: size.width / scale, height: size.height / scale)

        let img = NSImage(size: size)
        img.lockFocus()
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = .high
        let fromRect = NSRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let rect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        self.draw(in: rect, from: fromRect, operation: .copy, fraction: 1.0)
        img.unlockFocus()
        return img
    }
    
    public func writePNG(toFilePath filePath: String) {
        let properties: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: 1.0
        ]
        guard
            let data = tiffRepresentation,
            let rep = NSBitmapImageRep(data: data),
            let imgData = rep.representation(using: .png, properties: properties) else {
                    return
        }
        
        try? imgData.write(to: URL(fileURLWithPath: filePath))
    }
}
