//
//  DownloadsTableViewController.swift
//  DownloaderApp
//
//  Created by Виталий Субботин on 03/09/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import UIKit

class DownloadsTableViewController: UITableViewController {
    
    var downloads: [Download] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorInset = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloads = Downloader.fetchDownloads()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return downloads.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DownloadsTableViewCell.id, for: indexPath) as! DownloadsTableViewCell

        cell.titleLabel?.text = downloads[indexPath.row].title

        cell.animateProgress(download: downloads[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        Downloader.cancelDownload(request: downloads[indexPath.row].request)
    }
    
    func setBadge() {
        
        if let tabBarItem = tabBarController?.tabBar.items![2] {
            tabBarItem.badgeValue = "\(Downloader.fetchDownloads().count )"
        }

    }
    
    
}
