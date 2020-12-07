//
//  LoadScene.swift
//  LeefCode
//
//  Created by Alexander Skladanek on 11/30/20.
//
import SpriteKit
//import UIKit
var loaded = false //to determine if the bst/heap have been loaded
var loading = true; //to see if the bst or heap is currently being loaded or if previous dependancies are being loaded
var bstObj : BinaryTree?
var heapObj : Heap?
//sets global variables to Binary Tree and Min Heap from classes in MainScene
//Necessary as global variables because the screens don't pass information.
class LoadScene: SKScene {
    fileprivate var loadingLabel  : SKLabelNode?
    fileprivate var loadingBSTLabel  : SKLabelNode?
    fileprivate var loadingHeapLabel : SKLabelNode?
    var timeBSTLabel  : SKLabelNode?
    var timeHeapLabel : SKLabelNode?
    fileprivate var continueBSTLabel  : SKLabelNode?
    fileprivate var continueHeapLabel : SKLabelNode?
    //Initializes the types of each label and allows the times to be accessed outside of this file if active
    
    class func newLoadScene() -> LoadScene {
        // Load 'LoadScene.sks' as an SKScene.
        guard let scene = LoadScene(fileNamed: "LoadScene") else {
            print("Failed to load LoadScene.sks")
            abort()
        }
        // Set the scale mode to scale to fill the window
        print("Loaded LoadScene.sks")
        scene.scaleMode = .aspectFill
        return scene
    }
    
    func setUpScene() {
        print("Setting up Scene")
        // Get label node from scene and store it for use later
        self.loadingLabel = self.childNode(withName: "//loadingLabel") as? SKLabelNode
        if let loadingLabel = self.loadingLabel {
            loadingLabel.alpha = 0;
            loadingLabel.run(SKAction.fadeIn(withDuration: 0.1))
        }
        self.loadingBSTLabel = self.childNode(withName: "//loadingBSTLabel") as? SKLabelNode
        if let loadingBSTLabel = self.loadingBSTLabel {
            loadingBSTLabel.alpha = 0;
            loadingBSTLabel.run(SKAction.fadeIn(withDuration: 0.1))
        }
        self.loadingHeapLabel = self.childNode(withName: "//loadingHeapLabel") as? SKLabelNode
        if let loadingHeapLabel = self.loadingHeapLabel {
            loadingHeapLabel.alpha = 0;
            loadingHeapLabel.run(SKAction.fadeIn(withDuration: 0.1))
        }
        self.timeBSTLabel = self.childNode(withName: "//timeBSTLabel") as? SKLabelNode
        if let timeBSTLabel = self.timeBSTLabel {
            timeBSTLabel.alpha = 0;
            timeBSTLabel.run(SKAction.fadeIn(withDuration: 0.1))
        }
        self.timeHeapLabel = self.childNode(withName: "//timeHeapLabel") as? SKLabelNode
        if let timeHeapLabel = self.timeHeapLabel {
            timeHeapLabel.alpha = 0;
            timeHeapLabel.run(SKAction.fadeIn(withDuration: 0.1))
        }
        self.continueBSTLabel = self.childNode(withName: "//continueBSTLabel") as? SKLabelNode
        if let continueBSTLabel = self.continueBSTLabel {
            continueBSTLabel.alpha = 0;
            continueBSTLabel.run(SKAction.fadeIn(withDuration: 0.1))
        }
        self.continueHeapLabel = self.childNode(withName: "//continueHeapLabel") as? SKLabelNode
        if let continueHeapLabel = self.continueHeapLabel {
            continueHeapLabel.alpha = 0;
            continueHeapLabel.run(SKAction.fadeIn(withDuration: 0.1)){
                loading = false;//allows bst creation to start AFTER screen loads in
            }
        }
        //initializes all labels to be used in the loading screen, the fade in for each label is necessary to give the screen time to load after the view is passed
    }
    override func didMove(to view: SKView) {
        self.setUpScene()
        //sets up scene when this becomes the visible screen
    }
    
    override func update(_ currentTime: TimeInterval) {
        //checks if the structures have been loaded and then if not, creates them.
        //Unresponsive while loading trees (100% cpu utilization)
        if (!loading && !loaded){
            //initialize tree
            loading = true
            let timeBegin = CACurrentMediaTime()
            bstObj = BinaryTree() //sets up and initializes tree with 100k members
            let timeToComplete = (floor((CACurrentMediaTime() - timeBegin)*100))/100
            print("Load Time BST: " + String(timeToComplete))
            loadingBSTLabel?.text = "Loading BST: " + String(Int(enemyDataSize)) + "/" + String(Int(enemyDataSize))
            timeBSTLabel!.text = "Load Time BST: " + String(timeToComplete) + "s"
            let timeBegin2 = CACurrentMediaTime()
            heapObj = Heap() //sets up and initializes heap with 100k members
            let timeToComplete2 = (floor((CACurrentMediaTime() - timeBegin2)*100))/100
            print("Load Time Heap: " + String(timeToComplete2))
            loadingHeapLabel?.text = "Loading Heap: " + String(Int(heapObj!.size)) + "/" + String(Int(heapObj!.size))
            timeHeapLabel!.text = "Load Time Heap: " + String(timeToComplete2) + "s"
            loaded = true
            loading = false
        }
        // Called before each frame is rendered, hence the text won't update until a full update function has passed
    }
}

#if os(iOS)
// Touch-based event handling
extension LoadScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (loaded){
            guard let touch = touches.first else {
                return
            }
            let touchLocation = touch.location(in: self)
            if ((continueBSTLabel!.contains(touchLocation)) != false){
                let mainScene = MainScene.newMainScene()
                self.view?.presentScene(mainScene)
            }else if ((continueHeapLabel!.contains(touchLocation)) != false){
                    let mainScene = MainScene.newMainScene()
                    heap = true
                    self.view?.presentScene(mainScene)
                //changes screen to the actual game screen based on which label is pressed.
                //Heap = true indicates the heap is being used
                // ^^ = false indicates the bst should be used
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
#endif

