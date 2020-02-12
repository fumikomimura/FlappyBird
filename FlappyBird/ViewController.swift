//
//  ViewController.swift
//  FlappyBird
//
//  Created by 三村文子 on 2020/02/09.
//  Copyright © 2020 三村文子. All rights reserved.
//https://teratail.com/questions/42374



import UIKit
import SpriteKit    //SpriteKitを使うため追加


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SKViewに型を変換する
        let skView = self.view as! SKView
        
        //アプリの動きをわかりやすくするため
        //FPSが極端に落ちないように注意（動きが悪くなる）
        //FPSを表示する
        skView.showsFPS = true
        //ノードの数を表示する
        skView.showsNodeCount = true
                
        //ビューと同じサイズでシーンを作成する GameSceneクラスに変更する
        let scene = GameScene(size:skView.frame.size)
        
        //ビューにシーンを表示する
        skView.presentScene(scene)
        
        // Do any additional setup after loading the view.
    }

 //ステータスバーを消す
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    

}

