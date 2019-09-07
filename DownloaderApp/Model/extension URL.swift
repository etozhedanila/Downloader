//
//  extension Url.swift
//  DownloaderApp
//
//  Created by Виталий Субботин on 30/08/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import Foundation

extension URL {
    func dictionaryFromQueryString() -> [String: AnyObject]? {
        if let query = self.query {
            return query.dictionaryFromQueryStringComponents()
        }
        
        let result = absoluteString.components(separatedBy: "?")
        if result.count > 1 {
            return result.last?.dictionaryFromQueryStringComponents()
        }
        return nil
    }
}
