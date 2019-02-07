//
//  AppIconParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 07/02/2019.
//

import Foundation
import Yaml
import AppKit
import Francium

private struct AssetType {
    let size: CGFloat
    let scales: [Int]
    let metaData: [String: String]

    init(_ size: CGFloat, _ scales: [Int] = [1], _ metadata: [String: String] = [:]) {
        self.size = size
        self.scales = scales
        self.metaData = metadata
    }
}

private enum AppIconIdiom: String {
    case iPhone = "iphone"
    case iPad = "ipad"
    case iOSMarketing = "ios-marketing"
    case car
    case mac
    case watch

    static func from(rawValue: String) throws -> AppIconIdiom {
        guard let idiom = AppIconIdiom(rawValue: rawValue) else {
            throw NatriumError.generic("Invalid idiom: '\(rawValue)'")
        }
        return idiom
    }

    /// Every idiom has different assets with sizes and scales
    var assetTypes: [AssetType] {
        switch self {
        case .iPhone:
            return [
                AssetType(29, [2, 3]),
                AssetType(40, [2, 3]),
                AssetType(60, [2, 3]),
                AssetType(20, [2, 3])
            ]
        case .iPad:
            return [
                AssetType(29, [1, 2]),
                AssetType(40, [1, 2]),
                AssetType(76, [1, 2]),
                AssetType(83.5, [2]),
                AssetType(20, [1, 2])
            ]
        case .car:
            return [
                AssetType(60, [2, 3])
            ]
        case .iOSMarketing:
            return [
                AssetType(1024)
            ]
        case .watch:
            return [
                AssetType(24, [2], [ "subtype": "38mm", "role": "notificationCenter" ]),
                AssetType(27.5, [2], [ "subtype": "42mm", "role": "notificationCenter" ]),
                AssetType(29, [2, 3], [ "role": "companionSettings" ]),
                AssetType(40, [2], [ "subtype": "38mm", "rol": "appLauncher" ]),
                AssetType(86, [2], [ "subtype": "38mm", "rol": "quickLook" ]),
                AssetType(98, [2], [ "subtype": "42mm", "rol": "quickLook" ])
            ]
        case .mac:
            return [
                AssetType(16, [1, 2]),
                AssetType(32, [1, 2]),
                AssetType(128, [1, 2]),
                AssetType(256, [1, 2]),
                AssetType(512, [1, 2])
            ]
        }
    }
}

class AppIconParser: Parseable {

    var yamlKey: String {
        return "appicon"
    }

    var isRequired: Bool {
        return false
    }

    private lazy var availableIdioms: [AppIconIdiom] = [ .iPhone, .iPad, .iOSMarketing, .mac, .watch ]

    func parse(_ dictionary: [String: NatriumValue]) throws {
        // Do some pre-checks
        guard let destinationDirectoryString = dictionary["appiconset"]?.stringValue else {
            throw NatriumError.generic("Missing 'appiconset' in appicon")
        }
        guard let file = dictionary["original"]?.stringValue else {
            throw NatriumError.generic("Missing 'original' in appicon")
        }
        
        let originalFile = File(path: "\(projectDir)/\(file)")
        if !originalFile.isExisting {
            throw NatriumError.generic("Cannot find file: \(originalFile.absolutePath)")
        }

        // Create the destination directory (AppIcon.appiconset)
        let destinationDirectory = Dir(path: "\(projectDir)/\(destinationDirectoryString)")
        if !destinationDirectory.dirName.hasSuffix(".appiconset") {
            throw NatriumError.generic("\(destinationDirectory.absolutePath) must be a .appiconset")
        }
        if !destinationDirectory.isExisting {
            try destinationDirectory.make()

        } else if !destinationDirectory.isDirectory {
            throw NatriumError.generic("\(destinationDirectory.absolutePath) is not a directory")
        }

        destinationDirectory.chmod(0o7777)

        // Map the idioms to AppIconIdioms
        var idioms = try dictionary["idioms"]?.value.array?.compactMap { try AppIconIdiom.from(rawValue: $0.stringValue) } ?? [ ]
        if idioms.isEmpty {
            idioms = [ .iPhone ]
        }

        // iPad and iPhone idioms should have the ios-marketing idiom by default
        if (idioms.contains(.iPhone) || idioms.contains(.iPad)) && !idioms.contains(.iOSMarketing) {
            idioms.append(.iOSMarketing)
        }

        // Clear the destination directory (AppIcon.appiconset)
        try destinationDirectory.empty(recursively: true)

        guard var image = NSImage(contentsOfFile: originalFile.absolutePath) else {
            throw NatriumError.generic("Invalid image: \(originalFile.absolutePath)")
        }

        let ribbonText = dictionary["ribbon"]?.stringValue
        _addRibbon(to: &image, ribbon: ribbonText)

        Logger.info("Generating icons:")
        Logger.insets += 1
        var images: [[String: String]] = []
        for idiom in idioms {
            for assetType in idiom.assetTypes {
                for scale in assetType.scales {
                    images.append(_generateResizedImage(image: image, destinationDirectory: destinationDirectory, idiom: idiom, assetType: assetType, scale: scale))
                }
            }
        }
        try _writeToContentsJSONFile(destinationDirectory: destinationDirectory, images: images)
        Logger.insets -= 1
    }

    /// Ads a ribbon (bottom text bar) to an image
    ///
    /// - parameters:
    ///   - image: `inout NSImage` the original image ("hi-res")
    ///   - ribbon: `String?` the text to be placed in the ribbon
    private func _addRibbon(to image: inout NSImage, ribbon: String?) {
        let ribbon = ribbon ?? ""
        if ribbon.isEmpty {
            return
        }

        let maxSize: CGFloat = 1024
        let frame = NSRect(x: 0, y: 0, width: maxSize, height: maxSize)
        let imageView = NSImageView(frame: frame)
        imageView.layer = CALayer()
        imageView.layer?.contentsGravity = .resize
        imageView.layer?.contents = image

        let containerView = NSView(frame: frame)
        containerView.addSubview(imageView)
        let ribbonHeight = maxSize / 5
        let ribbonFrame = NSRect(x: 0, y: 0, width: maxSize, height: ribbonHeight)

        let ribbonView = NSView(frame: ribbonFrame)
        ribbonView.wantsLayer = true
        ribbonView.layer?.backgroundColor = NSColor(calibratedWhite: 0, alpha: 0.5).cgColor
        containerView.addSubview(ribbonView)

        let ribbonLabel = _ribbonLabel()
        ribbonLabel.frame = NSRect(x: 0, y: 0, width: maxSize, height: ribbonHeight - 20)
        ribbonLabel.font = NSFont.systemFont(ofSize: maxSize / 7.5)
        ribbonLabel.stringValue = ribbon
        ribbonView.addSubview(ribbonLabel)

        if let captureImage = containerView.capturedImage() {
            image = captureImage
        }
    }

    /// Generates the ribbon label
    ///
    /// - returns `NSTextField`
    private func _ribbonLabel() -> NSTextField {
        let ribbonLabel = NSTextField()
        ribbonLabel.isBezeled = false
        ribbonLabel.isEditable = false
        ribbonLabel.isSelectable = false
        ribbonLabel.drawsBackground = false
        ribbonLabel.textColor = NSColor.white
        ribbonLabel.alignment = .center
        return ribbonLabel
    }

    /// Generates a new image and returns the corresponding dictionary to be written in Contents.json
    ///
    /// - parameters:
    ///   - image: `NSImage` The original (with ribbon) image
    ///   - destinationDirectory: `Dir` The directory to store the image in
    ///   - idiom: `AppIconIdiom`
    ///   - assetType: `AssetType`
    ///   - scale: `Int`
    ///
    /// - returns: `[String: String]` A dictionary that will be appended to the `Contents.json` file
    private func _generateResizedImage(image: NSImage, destinationDirectory: Dir, idiom: AppIconIdiom, assetType: AssetType, scale: Int) -> [String: String] {
        let size = assetType.size
        var rSizeString = size.isInteger ? "\(Int(size))" : "\(size)"
        var sizeString = "\(rSizeString)x\(rSizeString)"
        let filename = scale == 1 ? "\(rSizeString).png" : "\(rSizeString)@x\(scale).png"

        let dic = [
            "filename": filename,
            "size": sizeString,
            "idiom": idiom.rawValue,
            "scale": "\(scale)x"
        ].merging(assetType.metaData) { _, new in new }

        rSizeString = size.isInteger ? "\(Int(size) * scale)" : "\(size * CGFloat(scale))"
        sizeString = "\(rSizeString)x\(rSizeString)"
        let widhtHeight = size * CGFloat(scale)
        Logger.log("\(sizeString) ▸ \(filename)")

        let image = image.resize(to: CGSize(width: widhtHeight, height: widhtHeight))
        image.writePNG(toFilePath: "\(destinationDirectory.absolutePath)/\(filename)")

        return dic
    }

    /// This will actually write the array of dictionaries to `Contents.json`
    ///
    /// - parameters:
    ///   - destinationDirectory: `Dir`
    ///   - images: `[[String: String]]`
    private func _writeToContentsJSONFile(destinationDirectory: Dir, images: [[String: String]]) throws {
        let json: [String: Any] = [
            "images": images,
            "info": [
                "author": "xcode",
                "version": 1
            ],
            "properties": [
                "pre-rendered": true
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NatriumError.generic("Cannot convert appicon to JSON")
        }

        let filePath = "\(destinationDirectory.absolutePath)/Contents.json"
        let file = File(path: filePath)
        if file.isExisting {
            try file.delete()
        }
        try file.write(string: jsonString)
    }
}
