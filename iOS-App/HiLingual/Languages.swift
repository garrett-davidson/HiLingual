//
//  Languages.swift
//  HiLingual
//
//  Created by Garrett Davidson on 2/13/16.
//  Copyright © 2016 Team3. All rights reserved.
//

import Foundation

enum Languages: String {
    case English = "English"
    case Arabic = "Arabic"
    case Russian = "Russian"
    case Japanese = "Japanese"
    case Chinese = "Chinese"
    case French = "French"
    case Malayalam = "Malayalam"

    static let allValues: [Languages] = [.English, .Arabic, .Malayalam, .Chinese, .French, .Japanese, .Russian]
}

//TODO: Fix this to only work for [Languages]
extension Array {
    func toList() -> String {
        var string = ""

        for lang in self {
            guard let lang = lang as? Languages else {
                return ""
            }
            if let locaizedLanguage = String.localizedLanguageForLanguageName(languageName: lang.rawValue) {
                string += locaizedLanguage + ", "
            }

        }

        //Remove the trailing ", "
        if (string.lengthOfBytes(using: String.Encoding.utf8) > 2) {
            string.remove(at: string.index(string.endIndex, offsetBy: -2))
        }

        return string
    }
}

extension String {
    static func localizedLanguageForLanguageName(languageName: String) -> String? {
        return Locale.current.localizedString(forIdentifier: Locale.canonicalLanguageIdentifier(from: languageName))
    }
}
