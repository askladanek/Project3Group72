//
//  PauseScene.swift
//  LeefCode
//
//  Created by Alexander Skladanek on 11/30/20.
//

import SpriteKit

class PauseScene: SKScene {
    
    fileprivate var resumeLabel  : SKLabelNode?
    fileprivate var heapLabel  : SKLabelNode?
    fileprivate var bstLabel  : SKLabelNode?
    fileprivate var heapAccessLabel  : SKLabelNode?
    fileprivate var bstAccessLabel  : SKLabelNode?
    fileprivate var menuLabel  : SKLabelNode?
    //initialized label types for buttons in the pause menu
    class func newPauseScene() -> PauseScene {
        // Load 'PauseScene.sks' as an SKScene.
        guard let scene = PauseScene(fileNamed: "PauseScene") else {
            print("Failed to load PauseScene.sks")
            abort()
        }
        // Set the scale mode to scale to fill the window
        print("Loaded PauseScene.sks")
        scene.scaleMode = .aspectFill
        return scene
    }
    func setUpScene() {
        print("Setting up Scene")
        self.resumeLabel = self.childNode(withName: "//resumeLabel") as? SKLabelNode
        if let resumeLabel = self.resumeLabel {
            resumeLabel.alpha = 1;
        }
        self.heapLabel = self.childNode(withName: "//heapLabel") as? SKLabelNode
        if let heapLabel = self.heapLabel {
            heapLabel.alpha = 1;
        }
        self.bstLabel = self.childNode(withName: "//bstLabel") as? SKLabelNode
        if let bstLabel = self.bstLabel {
            bstLabel.alpha = 1;
        }
        self.menuLabel = self.childNode(withName: "//menuLabel") as? SKLabelNode
        if let menuLabel = self.menuLabel {
            menuLabel.alpha = 1;
        }
        self.heapAccessLabel = self.childNode(withName: "//heapAccessLabel") as? SKLabelNode
        if let heapAccessLabel = self.heapAccessLabel {
            heapAccessLabel.alpha = 1;
            heapAccessLabel.text = String(heapAccessTime ?? 0.000000) + " seconds"
        }
        self.bstAccessLabel = self.childNode(withName: "//bstAccessLabel") as? SKLabelNode
        if let bstAccessLabel = self.bstAccessLabel {
            bstAccessLabel.alpha = 1;
            bstAccessLabel.text = String(bstAccessTime ?? 0.000000) + " seconds"

        }
        if (heap){
            heapLabel!.fontColor = UIColor.green // green means active, blue means available
            bstLabel!.fontColor = UIColor.blue
        }else{
            heapLabel!.fontColor = UIColor.blue
            bstLabel!.fontColor = UIColor.green
        }
        //initializes all labels to be used in the pause screen
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        //unused because pause screen is called when the game is not updating, hence isPaused
    }
}

#if os(iOS)
// Touch-based event handling
extension PauseScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
          return
        }
        let touchLocation = touch.location(in: self)
        if ((resumeLabel!.contains(touchLocation))){
            let mainScene = tempScene
            self.view?.presentScene(mainScene)
            //recieves global tempScene and returns to that screen
        }else if (heapLabel!.contains(touchLocation)){
            heap = true
            heapLabel!.fontColor = UIColor.green
            bstLabel!.fontColor = UIColor.blue
            //changes to using heap
        }else if (bstLabel!.contains(touchLocation)){
            heap = false
            heapLabel!.fontColor = UIColor.blue
            bstLabel!.fontColor = UIColor.green
            //changes to using bst
        }else if (menuLabel!.contains(touchLocation)){
            heap = false
            heapLabel!.fontColor = UIColor.blue
            bstLabel!.fontColor = UIColor.green
            print("deallocating")
            bstObj = nil
            heapObj = nil
            tempScene = nil
            paused = false
            loaded = false
            loading = true
            let gameScene = GameScene.newGameScene()
            self.view?.presentScene(gameScene)
            //Deallocates all structures and returns to the first screen.
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
#endif
