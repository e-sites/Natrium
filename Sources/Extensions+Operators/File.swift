//
//  File.swift
//  
//
//  Created by George Kiriy on 24.11.2019.
//

import Foundation
import Francium
import CommonCrypto

extension File {
    var data: Data? {
        return try? read()
    }

    func writeChanges(string: String) throws {
        let contents = (self.contents ?? "").trim()
        let string = string.trim()
        if string != contents {
            try write(string: string)
        }
    }
    
    var md5Checksum: String {
        guard let contents, let data = contents.data(using: .utf8), !data.isEmpty else {
            return ""
        }
        
        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)
        
        _ = data.withUnsafeBytes { bytes in
            CC_MD5_Update(&context, bytes.baseAddress, CC_LONG(data.count))
        }
        
        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { bytes in
            CC_MD5_Final(bytes.bindMemory(to: UInt8.self).baseAddress, &context)
        }
        
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
