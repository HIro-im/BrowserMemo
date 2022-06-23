//
//  ViewController.swift
//  BrowserMemo
//
//  Created by 今橋浩樹 on 2022/05/24.
//

import UIKit
import WebKit
import RealmSwift
import Dispatch

class ViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    var initialUrl: String = "https://www.google.com/"
    var receiveUrl: String!
    
    var currentPageName: String = ""
    var currentUrl: String = ""
    
    var bookmarksButtonItem: UIBarButtonItem!
    var goBackButtonItem: UIBarButtonItem!
    var goForwardButtonItem: UIBarButtonItem!
    var goGoogleButtonItem: UIBarButtonItem!
    
    let dateFormatter = DateFormatter()
    
    var realm = try! Realm()
    
    var progressView = UIProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        // 初回はGoogleを表示させるようにしてwebビューを起動させる
        // 引数に予めGoogleのURLを入れた変数を渡す
        webViewLoad(initialUrl)
        // KVOが最初は動かないので、GoogleのURLを予め渡しておく
        currentUrl = initialUrl
        // NavigationBarの下にUIprogressViewをBar形式で配置
        self.progressView = UIProgressView(frame: CGRect(x: 0.0, y:(self.navigationController?.navigationBar.frame.size.height)! - 3.0, width: self.view.frame.size.width, height: 3.0))
        self.progressView.progressViewStyle = .bar
        self.navigationController?.navigationBar.addSubview(self.progressView)

        
        // オブザーバーの設定(表示しているURLとページ名を監視して、変化した際に取得できるようにする)
        self.webView?.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        self.webView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        // こちらは読み込み状態の監視
        self.webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.webView?.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        
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
        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress", context: nil)
        self.webView?.removeObserver(self, forKeyPath: "loading", context: nil)
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
        
        if keyPath == "estimatedProgress" {
            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
        }
        else if keyPath == "loading" {
            if self.webView.isLoading {
                self.progressView.setProgress(0.1, animated: true)
            } else {
                // 一旦仮置で遅延処理で対応(didFinish)
                Thread.sleep(forTimeInterval: 0.4)
                self.progressView.setProgress(0.0, animated: false)
            }
        }
        
//        if (keyPath == "estimatedProgress") {
//            // alphaを1にする(表示)
//            self.progressView.alpha = 1.0
//            // estimatedProgressが変更されたときにプログレスバーの値を変更
//            self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
//
//            // estimatedProgressが1.0になったらアニメーションを使って非表示にして、アニメーション完了時0.0をセットする
//            if (self.webView.estimatedProgress >= 1.0) {
//                UIView.animate(withDuration: 0.3,
//                               delay: 0.3,
//                               options: [.curveEaseOut],
//                               animations: { [weak self] in
//                    self?.progressView.alpha = 0.0
//                }, completion: {
//                    (finished: Bool) in
//                    self.progressView.setProgress(0.0,animated: false)
//                })
//            }
//
//        }
        
        //        if keyPath == "estimatedProgress" {
        //            if self.webView.estimatedProgress >= 1.0 {
        //                let queue = DispatchQueue.main
        //                queue.async {
        //                    self.progressView.setProgress(1.0, animated: true)
        //                    let queue = DispatchQueue.global(qos: .userInteractive)
        //                    queue.async {
        //                        self.progressView.setProgress(0.0, animated: false)
        //                    }
        //                }
        //            } else {
        //                self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
        //            }
        //        }
        //
        //        if keyPath == "loading" {
        //            if self.webView.isLoading {
        //
        //            } else {
        //
        //            }
        //        }
        //

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
        
    // メモを追加するための処理
    @objc func addButtonTapped() {
        let storyboard = self.storyboard!
        
        // 遷移先のViewControllerを取得
        let next = storyboard.instantiateViewController(withIdentifier: "MemoView") as! MemoViewController
        // 遷移先の変数に引き渡す
        next.nameFromWebView = self.currentPageName
        next.urlFromWebView = self.currentUrl
        next.openMode = switchOpenMode.forCreate.rawValue
                
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
    
    // GGボタンを押すとwebビューをGoogleへ遷移させる処理
    @objc func ggButtonTapped() {
        // Googleを表示する(initialUrlを渡して処理する)
        webViewLoad(initialUrl)
    }

    // webビューを作る処理
    func webViewLoad(_ nextUrl: String) {
        let url = URL(string: nextUrl)!
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish,currentURL:\(currentUrl)")
        print("didFinish,currentName:\(currentPageName)")

        // URLが初回ページ(Google)と同じであればrealmには登録しない
        if currentUrl != initialUrl {
            historyRegister(currentUrl, currentPageName)
        }

    }
    
    // 履歴への登録処理
    func historyRegister(_ registerURL: String, _ registerPageName: String) {
        
        let dt = Date()

        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")

        print(dateFormatter.string(from: dt))
        print(registerURL)
        print(registerPageName)
        
        let history = WatchDate()
        
        history.URL = registerURL
        history.pageName = registerPageName
        history.watchDate = dateFormatter.string(from: dt)

        
        try! realm.write {
            realm.add(history)
        }
        
        let objects = realm.objects(WatchDate.self).sorted(byKeyPath: "watchDate", ascending: false)
        print(objects)
        

        
    }


}

