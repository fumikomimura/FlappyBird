//
//  GameScene.swift
//  FlappyBird 横スクロール型アクションゲーム
//
//  Created by 三村文子 on 2020/02/09.
//  Copyright © 2020 三村文子. All rights reserved
//setupItemとかにエラーがでてたから、}の位置を変えたら、今度他のエラーがたくさん出てきた。
//setupWallのところを参照にする


//SpriteketをインポートするためUIkitから置き換えた
import SpriteKit
import AVFoundation

//classの修正も忘れずに行う
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var itemNode:SKSpriteNode!  //❤️課題用　追加
    
    //衝突判定を行いたい物体にカテゴリーを設定
    let birdCategory: UInt32 = 1 << 0     //0...00001
    let groundCategory: UInt32 = 1 << 1   //0...00010
    let wallCategory: UInt32 = 1 << 2     //0...00100
    let scoreCategory: UInt32 = 1 << 3    //0...01000
    let itemCategory: UInt32 = 1 << 4     //❤️ 課題　追加
    let itemScoreCategory: UInt32 = 1 << 5
    
    //スコア用　クラス変数
    var score = 0
    var itemScore = 0
    
    //スコアを画面上に表示するため
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!  //❤️課題　アイテムスコア用　追加
    //ベストスコアを保存するため、"UserDefaults.standard"で"UserDefaults"を取得
    let userDefaults:UserDefaults = UserDefaults.standard
    
    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        //重力を設定 gravityメソッド　　-4を変更するとゲーム性に影響有り
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        //背景色を設定 RGB値を指定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //ゲームオーバーになった時スクロールを一括で止めることができるように作成
        //画面には表示されないからSKSpriteNodeではなくSKNodeクラスを使う
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //アイテム用ノード　❤️ 課題　追加
        //spritNodeに画像（texture）を設定する？
        let texture = itemNode
        itemNode = SKSpriteNode()
        scrollNode.addChild(itemNode)
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        setupItem()   //❤️課題　追加
    }
    
    func setupGround() {
        //地面の画像を読み込む
        //SKテクスチャクラスにfilteringModeプロパティに.nearestと設定すると処理速度を高める設定になる
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2  //＋2は地面を多めに並べるため
        
        //スクロールするアクションを作成
        //5秒かけて左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        //左スクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            //スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud() {
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分をスクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width ,y: 0, duration: 20)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width ,y: 0, duration:  0)
        
        
        //左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 //一番後ろになるようにする
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            //スプライトアニメーションに設定する
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall() {
        //壁に画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //鳥が通り抜ける隙間の長さを鳥のサイズの３倍とする
        let slit_length = birdSize.height * 3
        
        //隙間一の上下の振れ幅を鳥のサイズの３倍とする
        let random_y_range = birdSize.height * 3
        
        //下の壁のY軸下限位置（中央位置から下方向の最大振れ幅で壁を表示する位置）を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを載せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50  //雲より手前、地面より奥
            
            //0~random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            //Y軸の下限にランダムな値をあ足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            //下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            //スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            //上の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size() .height + slit_length)
            
            //スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            //衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            
            //スコアアップ用のノード　壁の上下に触れるとスコアがアップする
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf:CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        //次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation,waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird() {
        
        //鳥の画像を２種類取り込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        //２種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        //physicsBodyで 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        //衝突したときに回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        //bird.physicsBody?.contactTestBitMask = itemCategory
        
        //アニメーションを設定
        bird.run(flap)
        
        //スプライトを追加する
        addChild(bird)
    }
    
    //画面をタップした時に呼ばれる
    override  func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            //鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            //鳥の縦方向に力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
        
    }
    //SKPhysicsContactDelegateのメソッド。衝突した時の呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        //ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            // ベストスコア更新か確認する  したから持ってきた  3
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "BestScore:(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
                
            } else {
                //壁か地面と衝突した
                print("GameOver")
                //スクロールを停止させる speedが0だと動かないということ
                scrollNode.speed = 0
                
                bird.physicsBody?.collisionBitMask = groundCategory
                
                let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
                bird.run(roll, completion:{
                    self.bird.speed = 0
                })
            }
            //ベストスコア更新か確認する　　1
            //            var bestScore = userDefaults.integer(forKey: "BEST")
            //            if score > bestScore {
            //                bestScore = score
            //                bestScoreLabelNode.text = "BestScore:(bestScore)"
            //                userDefaults.set(bestScore, forKey: "BEST")
            //                userDefaults.synchronize()
            //
            
            //アイテムと衝突した
            if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
                print("ItemGet")
                itemScore += 1
                itemScoreLabelNode.text = "ItemScore:\(itemScore)"
                
                //        } else {
                //            //壁か地面と衝突した
                //            print("GameOver")
                //            //スクロールを停止させる speedが0だと動かないということ
                //            scrollNode.speed = 0
                //
                //            bird.physicsBody?.collisionBitMask = groundCategory
                //
                //            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
                //            bird.run(roll, completion:{
                //                self.bird.speed = 0
                //            })
                //            //ベストスコア更新か確認する   2  上に
                //            var bestScore = userDefaults.integer(forKey: "BEST")
                //            if score > bestScore {
                //                bestScore = score
                //                bestScoreLabelNode.text = "BestScore:(bestScore)"
                //                userDefaults.set(bestScore, forKey: "BEST")
                //                userDefaults.synchronize()
                //            }
            }
        }
        //リスタート用のrestart()メソッド
        func restart() {
            score = 0
            scoreLabelNode.text = "Score:\(score)"
            
            bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.height * 0.7)
            bird.physicsBody?.velocity = CGVector.zero
            bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
            bird.zRotation = 0
            
            wallNode.removeAllChildren()
            
            //restartメソッドを呼び出した時、スピードがまた元に戻るようにしてある
            bird.speed = 1
            scrollNode.speed = 1
        }
    }
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 //一番前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y:self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 //一番て前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score: \(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        //❤️課題　アイテムスコアを追加する
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y:self.frame.size.height - 120)
        itemScoreLabelNode.zPosition = 100 //一番て前に表示する
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let itemScore = userDefaults.integer(forKey: "ITEM")
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
        self.addChild(itemScoreLabelNode)
    }
}
//❤️アイテムのメソッド　　課題用　追加　壁を修正してみた　---ここからーーーー
func setupItem() {
    // 壁の画像を読み込む
    let itemTexture = SKTexture(imageNamed: "heart")
    itemTexture.filteringMode = .linear
    
    // 移動する距離を計算
    let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width)
    
    // 画面外まで移動するアクションを作成
    let moveItem = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)
    
    // 自身を取り除くアクションを作成
    let removeItem = SKAction.removeFromParent()
    
    // 2つのアニメーションを順に実行するアクションを作成
    let itemAnimation = SKAction.sequence([moveItem, removeItem])
    
    // 鳥の画像サイズを取得
    let birdSize = SKTexture(imageNamed: "bird_a").size()
    
    // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
    let slit_length = birdSize.height * 3
    
    // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
    let random_y_range = birdSize.height * 3
    
    // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
    let groundSize = SKTexture(imageNamed: "ground").size()
    let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
    let under_item_lowest_y = center_y - slit_length / 2 - itemTexture.size().height / 2 - random_y_range / 2
    
    // アイテムを生成するアクションを作成
    let createItemAnimation = SKAction.run({
        // 壁関連のノードを乗せるノードを作成
        let item = SKNode()
        item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 150, y: 0)  //アイテムの出現場所の座標　xを150にした
        item.zPosition = -50 // 雲より手前、地面より奥　　zposition＝画像の重ねかた
        
        // 0〜random_y_rangeまでのランダム値を生成
        let random_y = CGFloat.random(in: 0..<random_y_range)
        // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
        let under_item_y = under_item_lowest_y + random_y
        
        // 下側の壁を作成
        let under = SKSpriteNode(texture: itemTexture)
        under.position = CGPoint(x: 0,y: under_item_y)
        
        item.addChild(under)
        
        //            // 上側のアイテムを作成　　上下両方はいらないかも
        
        let upper = SKSpriteNode(texture: itemTexture)
        upper.position = CGPoint(x: 0, y: under_item_y + itemTexture.size().height + slit_length)
        
        item.addChild(upper)
        
        item.physicsBody?.categoryBitMask
        item.physicsBody?.contactTestBitMask
        
        //⭐️アイテムスコア用入力
        let itemScoreNode = SKNode()
        itemScoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
        itemScoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
        itemScoreNode.physicsBody?.isDynamic = false
        itemScoreNode.physicsBody?.categoryBitMask = self.itemScoreCategory
        itemScoreNode.physicsBody?.contactTestBitMask = self.birdCategory
        
        item.addChild(itemScoreNode)
        
        item.run(itemAnimation)
        
        self.itemNode.addChild(item)
    })
    
    // 次の壁作成までの時間待ちのアクションを作成
    let waitAnimation = SKAction.wait(forDuration: 2)
    
    // アイテムを作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
    let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))
    
    itemNode.run(repeatForeverAnimation)
    
    
    
    //https://hawksnowlog.blogspot.com/2017/11/spritekit-with-sound-effects.html
    //https://tukumosanzou.hatenablog.com/entry/2018/07/10/010153
    //❤️アイテム取得音を設定
    //    func play(music:String, loop: Bool) {
    //        if #available(iOS 11.1, *) {
    //            let play = SKAudioNode(fileNamed: "itemget")
    //            play.addChild(play)     //⭐️play入れるとエラー消えた。なぜ？
    //            play.run(
    //
    //            SKAction.sequence([SKAction.run {
    //        play.run(SKAction.play())
    //    }
    //    ])
    //     )
    //  } else {
    //            let play = SKAction.playSoundFileNamed("itemget",waitForCompletion: true)
    //            //  play.run()
    //        }
    //}

func play(music:String, loop: Bool) {
    if #available(iOS 11.1, *) {
        let play = SKAudioNode(fileNamed: "itemget")
        self.addChild(play)
        self.run(
            SKAction.sequence([//SKAction.wait(forDuration: 0.1),
                SKAction.run {
                    play.run(SKAction.play())
        }
            ]))
    } else {
        let play = SKAction.playSoundFileNamed("itemget" , waitForCompletion: true)
        self.run(play)
    }
    }
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass
 the selected object to the new view controller.
 }
 */


