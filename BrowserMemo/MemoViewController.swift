//
//  MemoViewController.swift
//  BrowserMemo
//
//  Created by 今橋浩樹 on 2022/05/26.
//

import UIKit
import RealmSwift

class MemoViewController: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var pageNameField: UITextField!
    @IBOutlet weak var linkUrl: UILabel!
    @IBOutlet weak var memoField: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var composeButtonItem: UIBarButtonItem!
    var trashButtonItem: UIBarButtonItem!
    
    // 現在の最新ID
    var currentId: Int = 0
    
    var realm = try! Realm()
    
    // 遷移元を識別するための情報
    var previewName: Int?
    
    // webビューから値を受け取るための変数
    var nameFromWebView: String?
    var urlFromWebView: String?
    
    // リスト選択時に値を受け取りための変数
    var receivedId: Int?
    
    // リスト選択時のID
    var selectedId: Int = 0
    
    // 保存・取消ボタンの処理を切り替えるための変数
    var switchProcess: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 遷移元によらずページ名は表示させても編集不可とする
        pageNameField.isEnabled = false
        
        // URLが書いてあるラベルをタップすると処理が行われるようにしている
        let tapGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(tapURL))
        self.linkUrl.addGestureRecognizer(tapGestureRecognizer)
        
        // UITextView以外のビューをタップすることで、キーボードが閉じる関数を呼び出せるようにしている
        let tapGR = UIGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // falseにすることで、UIGestureRecognizerがジェスチャーを受け取った以降のタップ関連のイベントも実施されるようにする
        // (逆に言うと、デフォルトだとこれがtrueなので、falseにしないと他のタップを認識してくれなくなる)
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        // キーボードの出現及び消えることを通知して、位置をずらす関数を呼び出せるようにしている
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // ラベルの設定
        
        // 角丸のサイズ
        linkUrl.layer.cornerRadius = 10.0
        // labelのときは必須
        linkUrl.clipsToBounds = true
        // 枠線の幅
        linkUrl.layer.borderWidth = 0.0
        // 枠線の色
        linkUrl.layer.borderColor = UIColor.white.cgColor
        
        // 遷移元によってテキストに格納する情報及び選択できるボタン等を変更する
        switch previewName {
        case 1:
            // webビューからの場合
            cancelButton.isHidden = false
            saveButton.isHidden = false
            memoField.isEditable = true
            memoField.isSelectable = true
            
            // webビューから現在のwebページに関する情報を取得
            pageNameField.text = nameFromWebView
            linkUrl.text = urlFromWebView
            
            // 新規追加レコードのため、最新のIDを取得して、登録時にこの数値に1を足して登録させる
            let memoData = realm.objects(Memo.self)
            
            if (memoData != nil && memoData.count != 0) {
                currentId = memoData.value(forKeyPath: "@max.id") as! Int
            }
            
        case 2:
            // リストからの場合
            cancelButton.isHidden = true
            saveButton.isHidden = true
            memoField.isEditable = false
            memoField.isSelectable = false
            
            // メモを修正・削除するためのボタン
            composeButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeButtonTapped))
            trashButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(trashButtonTapped))
            self.navigationItem.rightBarButtonItems = [composeButtonItem, trashButtonItem]
            
            // 選択されたデータを取り出すため、IDに合致したデータを参照する
            let selectedData = realm.objects(Memo.self).filter("id == %@", receivedId)
            
            pageNameField.text = selectedData[0].pageName
            linkUrl.text = selectedData[0].URL
            memoField.text = selectedData[0].memo
            selectedId = receivedId!
            
        default :
            print("another")
        }

    }
    
    // URLリンクタップ時の処理
    @objc func tapURL() {
        // タブバーコントロール内の一番左のビューに遷移するため、[0]のビューを示し、ナビゲーションコントローラとしてキャストする
        if let nextVC = tabBarController?.viewControllers?[0] as? UINavigationController {
            // そこの最初のスタック(スタック内の一番最後にある部分を示している?)が遷移したいビューコントローラクラスなら、値を入れる
            if let topVC = nextVC.topViewController as? ViewController {
                topVC.receiveUrl = linkUrl.text
                tabBarController?.selectedViewController = nextVC
            }
        }
    }
    
    // キーボードを消すためのメソッド
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // キーボードが現れたときのメソッド
    @objc func keyboardWillShow(notification: NSNotification) {
        // キーボードがメモ欄以外のもので表示された場合は、ここで処理を止めるためreturnを行う(出現時に何でも呼ばれてしまう)
        if !memoField.isFirstResponder {
            return
        }
        
        // ViewControllerのframeのy座標が0の時(=Viewが上に上がっていない時)は、cgRectVale(キーボードの高さ)を取り出して
        // その分上にViewを移動させる(iOSは左上の座標が(0,0)で、右方向、下方向に行くとプラスになるから、上方向はマイナスで動かす)
        if self.view.frame.origin.y == 0 {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardRect.height
            }
        }
    }
    
    // キーボードが消えたときのメソッド
    @objc func keyboardWillHide(notification: NSNotification) {
        // ViewControllerのframeのy座標が0以外の時(=Viewが上に上がっている時)は、y座標を0にしてもとに戻す
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    

    // 取消ボタンタップ時の処理
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        // メモ編集画面にたどり着いた方法によって取消ボタンの処理を変更する
        switch switchProcess {
        case 1:
            // webビューからの場合(switchProcess=1)は、モーダルでの表示のためdismissを使う
            self.dismiss(animated: true, completion: nil)
            
        case 2:
            // 詳細画面の修正ボタンからの場合(switchProcess=2)は、ボタンの表示・非表示や編集可否をもとに戻す(遷移ではないので)
            
            // 戻るボタン・編集ボタン・削除ボタンを表示する
            self.navigationItem.rightBarButtonItems = [composeButtonItem, trashButtonItem]
            self.navigationItem.hidesBackButton = false
            
            // メモ欄を編集不能にする
            memoField.isEditable = false
            memoField.isSelectable = false
            
            // 取消ボタン・保存ボタンの表示
            cancelButton.isHidden = true
            saveButton.isHidden = true
            
        default:
            // たどり着くはずがないが一旦仮置
            print("another")
            
        }
    }
    
    
    // 保存ボタンタップ時の処理
    @IBAction func saveButtonAction(_ sender: Any) {
        
        // メモ編集画面にたどり着いた方法によって取消ボタンの処理を変更する
        switch switchProcess {
        case 1:
            // webビューからの場合(switchProcess=1)は、新規登録のための保存を行う
            let memo = Memo()
            // オートインクリメントがないので、最新のID(currentId)に1を足して登録する
            memo.id = currentId + 1
            memo.pageName = pageNameField.text!
            memo.URL = linkUrl.text!
            memo.memo = memoField.text!
            
            try! realm.write {
                realm.add(memo)
            }
            
            self.dismiss(animated: true, completion: nil)
            
        case 2:
            // 詳細画面の修正ボタンからの場合(switchProcess=2)は、修正登録のための保存を行う
            // 削除したいデータを検索する
            let editData = realm.objects(Memo.self).filter("id == %@", selectedId)
            
            // メモ欄をtextViewにあるデータで更新する
            do {
                try realm.write {
                    editData[0].memo = memoField.text!
                }
            } catch {
                print("erro \(error)")
            }
            
            // リストに遷移するための処理(pushだと階層が深くなってしまって、戻るボタンが表示されてしまうため、popを使う)
            navigationController?.popViewController(animated: true)
            
        default:
            // たどり着くはずがないが一旦仮置
            print("another")
        }
    }
    
    // メモを修正するための処理
    @objc func composeButtonTapped() {
        // 保存・取消ボタンの役割を切り替えるための識別情報を渡す(2は編集保存)
        switchProcess = 2
        
        // 戻るボタン・編集ボタン・削除ボタンを非表示にする
        // (統一感を出すために戻るボタンを非表示にする)
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.hidesBackButton = true
        
        // メモ欄を編集可能にする
        memoField.isEditable = true
        memoField.isSelectable = true
        
        // 取消ボタン・保存ボタンの表示を行う
        cancelButton.isHidden = false
        saveButton.isHidden = false
        
    }
    
    // メモを削除するための処理
    @objc func trashButtonTapped() {
        
        // 削除したいデータを検索する
        let deleteData = realm.objects(Memo.self).filter("id == %@", selectedId)
        
        do {
            try realm.write {
                realm.delete(deleteData)
            }
        } catch {
            print("Error \(error)")
        }
        
        // リストに遷移するための処理(pushだと階層が深くなってしまって、戻るボタンが表示されてしまうため、popを使う)
        navigationController?.popViewController(animated: true)
        
    }

}
