//
//  YoutubeParser.swift
//  DownloaderApp
//
//  Created by Виталий Субботин on 30/08/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import CoreData
import UIKit

class YoutubeUrlParser {
    
    private static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private static let infoURL = "http://www.youtube.com/get_video_info?video_id="
    private static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2)  AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
    
    
    static func getYoutubeIDFromYoutubeURL(youtubeURL: URL) -> String? {
        guard let host = youtubeURL.host else { return nil }
        let pathComponents = youtubeURL.pathComponents
        if host == "youtu.be" {
            return pathComponents[1]
        }
        
        if host == "youtube.googleapis.com" || pathComponents.first == "www.youtube.com" {
            return pathComponents[2]
        }
        
        if youtubeURL.absoluteString.range(of: "www.youtube.com/embed") != nil {
            return pathComponents[2]
        }
        
        if let queryString = youtubeURL.dictionaryFromQueryString(), let searchParam = queryString["v"] as? String {
            return searchParam
        }
        
        return nil
    }
    
    static func getVideoWithYoutubeID(youtubeID: String) -> Video? {
        
        let urlString = String(format: "%@%@", infoURL, youtubeID)
        guard let url = URL(string: urlString) else { return nil }
        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 5.0
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        var responseString: String = ""
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let group = DispatchGroup()
        group.enter()
        let task = session.dataTask(with: request as URLRequest) { (data, response, _) -> Void in
            if let data = data {
                responseString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            }
            group.leave()
        }
        task.resume()
        group.wait()
        
        let parts = responseString.dictionaryFromQueryStringComponents()
        guard parts.count > 0 else { return nil }

        
        if let fmtStreamMap = parts["url_encoded_fmt_stream_map"] as? String {
            // Live Stream
            if let _: AnyObject = parts["live_playback"] {
                if let hlsvp = parts["hlsvp"] as? String {

                    let context = appDelegate.persistentContainer.viewContext
                    guard let entity = NSEntityDescription.entity(forEntityName: "Video", in: context) else { return nil }
                    let video = NSManagedObject(entity: entity, insertInto: context) as! Video
                    video.fileName = youtubeID
                    video.titleName = youtubeID

                    video.videoUrlString = hlsvp
                    video.date = getCurrentDate()
                    

                    return video

                }
            } else {

                let fmtStreamMapArray = fmtStreamMap.components(separatedBy: ",")

                for videoEncodedString in fmtStreamMapArray {
                    var videoComponents = videoEncodedString.dictionaryFromQueryStringComponents()
                    if !(videoComponents["type"] as! String).contains("mp4") {
                        continue
                    }

                    let context = appDelegate.persistentContainer.viewContext
                    guard let entity = NSEntityDescription.entity(forEntityName: "Video", in: context) else { return nil }
                    let video = NSManagedObject(entity: entity, insertInto: context) as! Video
                    video.fileName = youtubeID
                    video.titleName = youtubeID

                    video.videoUrlString = videoComponents["url"] as? String
                    video.date = getCurrentDate()

                    return video
                }
            }
        }
        
        return nil
    }
    

    private static func getCurrentDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        let date = df.string(from: Date())
        return date
    }
    
}
