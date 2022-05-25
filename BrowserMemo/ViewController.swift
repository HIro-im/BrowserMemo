//
//  ViewController.swift
//  BrowserMemo
//
//  Created by 今橋浩樹 on 2022/05/24.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var initialUrl: String = "https://www.google.com/"
    var receiveUrl: String!
    
    var currentPageName: String = ""
    var currentUrl: String = ""
    
    var bookmarksButtonItem: UIBarButtonItem!
    var goBackButtonItem: UIBarButtonItem!
    var goForwardButtonItem: UIBarButtonItem!
    var goGoogleButtonItem: UIBarButtonItem!

    override func loadView() {
        // webビューの定義
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初回はGoogleを表示させるようにしてwebビューを起動させる
        // 引数にa予めGoogleのURLを入れた変数を渡す
        webViewLoad(initialUrl)
        
        // オブザーバーの設定(表示しているURLとページ名を監視して、変化した際に取得できるようにする)
        self.webView?.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        self.webView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        // メモを追加するためのボタン
        bookmarksButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = bookmarksButtonItem
        
        // ブラウザバック・進むボタン
        goBackButtonItem = UIBarButtonItem(title: "←", style: .plain, target: self, action: #selector(backBarButtonTapped))
        goForwardButtonItem = UIBarButtonItem(title: "→", style: .plain, target: self, action: #selector(forwardBarButtonTapped))
        // Googleへ遷移するボタン
        goGoogleButtonItem = UIBarButtonItem(title: "GG", style: .plain, target: self, action: #selector(ggButtonTapped))
        
        self.navigationItem.leftBarButtonItems = [goBackButtonItem,goForwardButtonItem,goGoogleButtonItem]
        
        
    }
    
    // KVOの破棄
    deinit {
        self.webView?.removeObserver(self, forKeyPath: "URL")
        self.webView?.removeObserver(self, forKeyPath: "title")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // 変更が入った際に、常に現在のURLとページ名を変数に格納する
        if let url = change![NSKeyValueChangeKey.newKey] as? URL {
            let urlString: String = url.absoluteString
            currentUrl = urlString
        }
        
        if let title = change![NSKeyValueChangeKey.newKey] as? String {
            currentPageName = title
        }
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // メモからとってきたURLを使ってwebビューを起動させる
        if let bookmarkUrl = receiveUrl {
            webViewLoad(bookmarkUrl)
        }
        
        // ログ状監視のためのprint(消してもいい)
        print("viewWillAppear browser")
    }
    
    func webViewLoad(_ nextUrl: String) {
        let url = URL(string: nextUrl)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // メモを追加するための処理
    @objc func addButtonTapped() {
        let storyboard = self.storyboard!
        
        // 遷移先のViewControllerを取得
        let next = storyboard.instantiateViewController(withIdentifier: "MemoView") as! MemoViewController
        // 遷移先の変数に引き渡す
        next.nameFromWebView = self.currentPageName
        next.urlFromWebView = self.currentUrl
        next.previewName = 1
        
        // 保存ボタンの役割を切り替えるための識別情報を渡す(1は新規保存)
        next.saveProcess = 1
        // 画面遷移を行う
        self.present(next, animated: true, completion: nil)
        
    }
    
    // webビューを戻す処理
    @objc func backBarButtonTapped() {
        webView.goBack()
    }
    
    // webビューを進める処理
    @objc func forwardBarButtonTapped() {
        webView.goForward()
    }
    
    // webビューをGoogleへ遷移させる処理
    @objc func ggButtonTapped() {
        // Googleを表示する(initialUrlを渡して処理する)
        webViewLoad(initialUrl)
    }
}

