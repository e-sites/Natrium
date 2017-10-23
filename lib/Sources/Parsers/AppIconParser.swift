//
//  AppIconParser.swift
//  CommandLineKit
//
//  Created by Bas van Kuijck on 20/10/2017.
//

import Foundation
import Yaml

class AppIconParser: Parser {
    let natrium: Natrium
    fileprivate var appIconSet: String!
    fileprivate var original: String!
    fileprivate var ribbon: String!
    fileprivate var idioms: [String] = []
    fileprivate let tmpFile = "tmp_file.png"

    var yamlKey: String {
        return "appicon"
    }

    required init(natrium: Natrium) {
        self.natrium = natrium
    }

    func parse(_ yaml: [NatriumKey: Yaml]) {

        for object in yaml {
            switch object.key.string {
            case "appiconset":
                appIconSet = object.value.stringValue
            case "idioms":
                if let ar = object.value.array {
                    idioms = ar.flatMap { $0.string }
                } else if let string = object.value.string {
                    idioms = string.components(separatedBy: ",")
                }
            case "original":
                original = object.value.string

            case "ribbon":
                ribbon = object.value.string

            default:
                break
            }
        }
        if appIconSet == nil {
            Logger.fatalError("Missing 'appiconset' in [appicon]")

        } else {
            appIconSet = Dir.dirName(path: natrium.projectDir + "/" + appIconSet!)
            if !File.exists(at: appIconSet) {
                Logger.fatalError("Cannot find app icon set \(appIconSet!)")
            }
        }

        if original == nil {
            Logger.fatalError("Missing 'original' in [appicon]")
        } else {
            original = Dir.dirName(path: natrium.projectDir + "/" + original!)
            if !File.exists(at: original) {
                Logger.fatalError("Cannot find original \(original!)")
            }
        }

        if ribbon == nil {
            Logger.fatalError("Missing 'ribbon' in [appicon]")
        }
        if idioms.isEmpty {
            idioms = [ "iphone" ]
        }

        if idioms.contains("iphone") || idioms.contains("ipad") {
            idioms.append("ios-marketing")
        }
        _checkImageMagick()
    }

    fileprivate func _checkImageMagick() {
        let imagemagickResult = shell("/usr/local/bin/convert", arguments: [ "--version" ])
        if imagemagickResult?.contains("ImageMagick") == true {
            _run()

        } else {
            Logger.error("ImageMagick is not installed on this machine")
        }
    }

    fileprivate typealias AssetValue = (Double, [Int], [String: String]?)

    fileprivate func _getAssets() -> [String: [AssetValue]] {
        return [
            "iphone": [
                (29, [2, 3], nil),
                (40, [2, 3], nil),
                (60, [2, 3], nil),
                (20, [2, 3], nil)
            ],
            "ipad": [
                (29, [1, 2], nil),
                (40, [1, 2], nil),
                (76, [1, 2], nil),
                (83.5, [2], nil),
                (20, [1, 2], nil)
            ],
            "car": [
                (60, [2, 3], nil)
            ],
            "ios-marketing": [
                (1024, [1], nil)
            ],
            "watch": [
                (24, [2], [ "subtype": "38mm", "role": "notificationCenter" ]),
                (27.5, [2], [ "subtype": "42mm", "role": "notificationCenter" ]),
                (29, [2, 3], [ "role": "companionSettings" ]),
                (40, [2], [ "subtype": "38mm", "rol": "appLauncher" ]),
                (86, [2], [ "subtype": "38mm", "rol": "quickLook" ]),
                (98, [2], [ "subtype": "42mm", "rol": "quickLook" ])
            ],
            "mac": [
                (16, [1, 2], nil),
                (32, [1, 2], nil),
                (128, [1, 2], nil),
                (256, [1, 2], nil),
                (512, [1, 2], nil)
            ]
        ]
    }

    fileprivate func _run() {
        Dir.clearContents(of: appIconSet)

        let assets: [String: [AssetValue]] = _getAssets()

        var images: [[String: String]] = []
        let maxSize = 1024

        shell("/usr/local/bin/convert", arguments: [ original!, "-resize", "\(maxSize)x\(maxSize)", tmpFile])

        if ribbon != nil && !ribbon.isEmpty {
            let h = 0.244 * Double(maxSize)
            let pointSize = Double(maxSize) / 7.5
            shell("/usr/local/bin/convert",
                  useProxyScript: true,
                  arguments: [
                    "-size", "\(maxSize)x\(maxSize)",
                    "xc:skyblue",
                    "-gravity", "South",
                    "-draw", "\"image over 0,0 0,0 '\(tmpFile)'\"",
                    "-draw", "\"fill black fill-opacity 0.5 rectangle 0, \(Double(maxSize) - h) \(maxSize),\(maxSize)\"", // swiftlint:disable:this line_length
                    "-pointsize", "\(pointSize)",
                    "-draw", "\"fill white text 0,\(Int(h / 5)) '\(ribbon!)'\"",
                    tmpFile
                ])
        }

        Logger.info("    Generating icons:")
        for asset in assets {
            if !idioms.contains(asset.key) {
                continue
            }
            for av in asset.value {
                for scale in av.1 {
                    images.append(_createAsset(idiom: asset.key, size: av.0, scale: scale, additional: av.2))
                }
            }
        }
        File.remove(tmpFile)

        let json: [String: Any] = [
            "images": images,
            "info": [
                "version": 1,
                "author": "xcode"
            ],
            "properties": [
                "pre-rendered": true
            ]
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
            let jsonString = String(data: data, encoding: .utf8) else {
                return
        }

        let filePath = "\(appIconSet!)/Contents.json"
        FileHelper.write(filePath: filePath, contents: jsonString)
    }
    
    fileprivate func _createAsset(idiom: String,
                                  size: Double,
                                  scale: Int,
                                  additional: [String: String]?) -> [String: String] {
        
        var rSizeString = "\(size)"
        if Double(Int(size)) == size {
            rSizeString = "\(Int(size))"
        }
        var sizeString = "\(rSizeString)x\(rSizeString)"
        var filename = "\(rSizeString)@x\(scale).png"
        if scale == 1 {
            filename = "\(rSizeString).png"
        }
        var dic = [
            "size": sizeString,
            "idiom": idiom,
            "filename": filename,
            "scale": "\(scale)x"
        ]

        for av in (additional ?? [:]) {
            dic[av.key] = av.value
        }

        rSizeString = "\(size * Double(scale))"
        if Double(Int(size)) == size {
            rSizeString = "\(Int(size) * scale)"
        }
        sizeString = "\(rSizeString)x\(rSizeString)"
        Logger.log("      \(sizeString) ▸ \(filename)")
        shell("/usr/local/bin/convert", arguments: [
            tmpFile,
            "-resize", sizeString,
            "\(appIconSet!)/\(filename)"
            ])

        return dic
    }
}