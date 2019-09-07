//
//  Downloader.swift
//  DownloaderApp
//
//  Created by Виталий Субботин on 30/08/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import RxSwift
import RxAlamofire

class Downloader {
    
    static var videos: [Video] = []
    private static var downloads: [Download] = []
    
    private static let disposeBag = DisposeBag()
    
    private static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private static func fetchVideos() {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        
        do {
            videos = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func downloadVideo(withUrl url: URL) {
        guard let youtubeId = YoutubeUrlParser.getYoutubeIDFromYoutubeURL(youtubeURL: url) else { return }
//        downloadVideo(byId: youtubeId)
        downloadVideoWithRx(byId: youtubeId)
    }
    
    //with URLSession
    private static func downloadVideo(byId id: String) {
       
        self.fetchVideos()
        
        guard let video = YoutubeUrlParser.getVideoWithYoutubeID(youtubeID: id) else { return }
        guard let videoUrl = URL(string: video.videoUrlString!) else { return }
        
        let videosUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationFileUrl = videosUrl.appendingPathComponent(id + ".mp4")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url: videoUrl)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    
                }

                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    self.videos.insert(video, at: 0)
                    self.appDelegate.saveContext()

                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }

            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "undefined error.");
            }
        }
        task.resume()
    }
    
    //with RxAlamofire
    private static func downloadVideoWithRx(byId id: String) {
        self.fetchVideos()
        
        guard let video = YoutubeUrlParser.getVideoWithYoutubeID(youtubeID: id) else { return }
        guard let urlString = video.videoUrlString else { return }

        guard let videoUrl = URL(string: urlString) else { return }
        let request = URLRequest(url: videoUrl)
        
        let videosUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = videosUrl.appendingPathComponent(id + ".mp4")
        

        RxAlamofire.download(request) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            return (destinationFileUrl, .removePreviousFile)
        }
            .subscribe(onNext: { (request) in

                downloads.append(Download(title: id, request: request))

                
            }, onError: { (error) in
                print(error.localizedDescription)
            },
               onCompleted: {
                
                self.videos.insert(video, at: 0)
                self.appDelegate.saveContext()
                print("completed")
            })
            .disposed(by: disposeBag)
        
    }
    
    static func cancelDownload(request: DownloadRequest?) {
        guard let request = request else { return }
        request.cancel()
    }
    
    static func fetchDownloads() -> [Download] {
        return downloads
    }
}
