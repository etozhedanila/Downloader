//
//  DownloadTableViewController.swift
//  DownloaderApp
//
//  Created by Виталий Субботин on 30/08/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import UIKit
import AVKit
import CoreData

class VideosTableViewController: UITableViewController {
    
    var videos: [Video] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var player: AVPlayer!
    
    var titles: [String] = []
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        print(#function)
        let alert = UIAlertController(title: "New Download", message: "Input url of video", preferredStyle: .alert)
        let download = UIAlertAction(title: "Download", style: .default) { (_) in
            if let urlString = alert.textFields![0].text, let url = URL(string: urlString) {
                Downloader.downloadVideo(withUrl: url)
            }
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(download)
        alert.addAction(cancel)
        alert.addTextField { (textField) in
            textField.placeholder = "https://www.youtube.com"
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if !tableView.isEditing {
            sender.title = "Edit"
            for i in 0..<videos.count {
                let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! VideosTableViewCell
                let title = cell.getTitle()
                titles[i] = title
                videos[i].titleName = title
                print(title)
            }
            appDelegate.saveContext()
            videos.sort(by: { $0.titleName! < $1.titleName! })
            tableView.reloadData()
        }
        else {
            sender.title = "Done"
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView.init(frame: .zero)
        tableView.separatorInset = .zero
        
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchVideos()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return videos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideosTableViewCell.id, for: indexPath) as! VideosTableViewCell

        cell.configure(video: videos[indexPath.row])
        titles.append(videos[indexPath.row].titleName ?? " ")

        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if !tableView.isEditing {
            playVideo(withIndexPath: indexPath)
        }
    }
    

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteVideo(atIndexPath: indexPath)
            tableView.reloadData()
        }
    }
}



extension VideosTableViewController {
    
    private func fetchVideos() {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        
        do {
            videos = try context.fetch(fetchRequest)
            
        } catch {
            print(error.localizedDescription)
        }
        videos.sort(by: { $0.titleName! < $1.titleName! })
        tableView.reloadData()
    }
    
    private func deleteVideo(atIndexPath indexPath: IndexPath) {
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()

        guard let fileName = videos[indexPath.row].fileName else { return }
        
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent(fileName + ".mp4")
        
        do {
            try filemanager.removeItem(atPath: destinationPath)
        } catch {
            print(error.localizedDescription)
        }
        
        if let result = try? context.fetch(fetchRequest) {
            let sortedResult = result.sorted(by: { $0.titleName! < $1.titleName!} )
            context.delete(sortedResult[indexPath.row])
            videos.remove(at: indexPath.row)
        }
    }
    
    private func playVideo(withIndexPath indexPath: IndexPath) {
        guard let videosUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        guard let fileName = videos[indexPath.row].fileName else { return }
        
        let destinationFileUrl = videosUrl.appendingPathComponent(fileName + ".mp4")
        self.player = AVPlayer(url: destinationFileUrl)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            
            self.player.play()
        }
    }
}
