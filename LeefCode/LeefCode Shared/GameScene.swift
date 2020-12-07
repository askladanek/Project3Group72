//
//  GameScene.swift
//  LeefCode Shared
//
//  Created by Alexander Skladanek on 11/30/20.
//

import SpriteKit

class GameScene: SKScene {
    fileprivate var titleLabel : SKLabelNode?
    fileprivate var newGameLabel : SKLabelNode?
    fileprivate var creditsLabel : SKLabelNode?
    //Sets data types for interactable labels on main menu
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        // Set the scale mode to scale to fill the window
        scene.scaleMode = .aspectFill
        return scene
    }
    func setUpScene() {
        // Get label node from scene and store it for use later
        self.titleLabel = self.childNode(withName: "//titleLabel") as? SKLabelNode
        if let titleLabel = self.titleLabel {
            titleLabel.alpha = 0.0
            titleLabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
        self.newGameLabel = self.childNode(withName: "//newGameLabel") as? SKLabelNode
        if let newGameLabel = self.newGameLabel {
            newGameLabel.alpha = 0.0
            newGameLabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
        self.creditsLabel = self.childNode(withName: "//creditsLabel") as? SKLabelNode
        if let creditsLabel = self.creditsLabel {
            creditsLabel.alpha = 0.0
            creditsLabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
        //Fades the main menu screen into view
    }
    override func didMove(to view: SKView) {
        self.setUpScene()
        //initializes the screen when the app is started
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS)
// Touch-based event handling
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
          return
        }
        let touchLocation = touch.location(in: self)
        if ((newGameLabel?.contains(touchLocation)) != nil && (newGameLabel?.contains(touchLocation)) != false){
            let loadScene = LoadScene.newLoadScene()
            self.view?.presentScene(loadScene)
        }
        //Detects if the new game has been tapped, moves the load screen into view if so
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
#endif


