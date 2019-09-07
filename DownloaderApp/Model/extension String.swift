//
//  extension String.swift
//  DownloaderApp
//
//  Created by Виталий Субботин on 30/08/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import Foundation

extension String {
    
    func stringByDecodingURLFormat() -> String {
        let result = self.replacingOccurrences(of: "+", with: " ")
        return result.removingPercentEncoding!
    }
    
    func dictionaryFromQueryStringComponents() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        
        for keyValue in components(separatedBy: "&") {
            let keyValueArray = keyValue.components(separatedBy: "=")
            if keyValueArray.count < 2 {
                continue
            }
            let key = keyValueArray[0].stringByDecodingURLFormat()
            let value = keyValueArray[1].stringByDecodingURLFormat()
            parameters[key] = value as AnyObject
        }
        
        return parameters
    }
}
