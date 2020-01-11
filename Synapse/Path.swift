//
//  Path.swift
//  RSS13

import Foundation

class Path {
    
    //MARK: Properties
    static let insecurePrefix = "http://"
    static let securePrefix = "https://"
    
    /// Returns a `lowercased` path string with an `https://` prefix
    /// - Parameter source: The input string to be normalized
    ///
    /// If the string already includes an insecure prefix it will be replaced.
    static func normalized(for source: String) -> String {
        let caseNormalized = source.lowercased()
        if caseNormalized.starts(with: insecurePrefix) || caseNormalized.starts(with: securePrefix) {
            return source
        }
        let newPath = securePrefix + caseNormalized
        return newPath
    }
}
