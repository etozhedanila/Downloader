//
//  ViewController.swift
//  DownloaderApp
//
//  Created by Виталий Субботин on 30/08/2019.
//  Copyright © 2019 Виталий Субботин. All rights reserved.
//

import UIKit
import WebKit
import AVKit


class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {

        guard let url = webView.url else { return }
        print(url)
        Downloader.downloadVideo(withUrl: url)
        let downloadsNVC  = self.tabBarController?.viewControllers![2] as! UINavigationController
        let downloadsTVC =  downloadsNVC.viewControllers[0] as! DownloadsTableViewController
        downloadsTVC.setBadge()
        
       
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        addSwipes()
        
        guard let url = URL(string: "https://youtube.com") else { return }
        
        
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url))
        }
    }
    
    
    
    private func addSwipes() {
        
        let directions: [UISwipeGestureRecognizer.Direction] = [.left, .right]
        for direction in directions {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
            swipe.direction = direction
            
            self.webView.addGestureRecognizer(swipe)
        }
    }
    
    @objc private func swiped(_ sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .right, webView.canGoBack { webView.goBack() }
        if sender.direction == .left, webView.canGoForward { webView.goForward() }
    }
    

    
}

