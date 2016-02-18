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
}

extension _ArrayType where Generator.Element == Languages {
    func toList() -> String {
        var string = ""

        for lang in self {
            string += lang.rawValue + ", "
        }

        //Remove the trailing ", "
        if (string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 2) {
            string = string.substringToIndex(string.endIndex.predecessor().predecessor())
        }
        
        return string
    }
}