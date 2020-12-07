//
//  MainScene.swift
//  LeefCode
//
//  Created by Alexander Skladanek on 11/30/20.
//

import SpriteKit //basic movement, sprites, label control
import UIKit//imports uiview and progress bar for health bar
var enemyDataSize : Float = 100000
var attackRight = false //button control boolean for update function use
var attacking = false //button control boolean for update function use
var heap = false //stores whether current data structure is heap or bst
var health : Float? //stores during pause menu when healthbar must be deleted
var heapAccessTime: Float? //stores times for viewing on pause menu
var bstAccessTime: Float?
var paused = false; // pause menu control over update function
//global variables
class enemyObj {
    //enemies include sprite nodes and stats
    var spriteNode : SKSpriteNode?
    var val : Float?
    var attack : Float?
    var defense : Float?
    var health : Float?
    var moveSpeed : Float?
    var fought : Bool?
    init (val: Float) { //creating enemy objects and assigning values
        self.val = val
        spriteNode = SKSpriteNode(imageNamed: "candle")
        spriteNode!.name = "enemy"
        attack = val / enemyDataSize; //normalizes stats to the number of enemies
        defense = val / enemyDataSize;
        health = val / enemyDataSize;
        moveSpeed = val / enemyDataSize;
        fought = false
    }
}

class Node { //Nodes for binary tree constructor
    var val : Float?
    var enemy : enemyObj?
    var leftptr : Node?
    var rightptr : Node?
    init (val : Float){ // Node constructor
        self.val = val
        enemy = enemyObj(val: val) //Nodes contain enemy objects
    }
}
func randomIncrement () -> Float { //Returns a random number for incrementing enemy stats
    let randomNum = Float.random(in: 1...1.5)
    return randomNum
}
class BinaryTree {//Binary tree for storing nodes of enemies to access later
    var neededNodes = enemyDataSize;
    var root : Node?
    
    func createRoot() -> Node{
        self.root = Node(val: Float(enemyDataSize/2))
        neededNodes -= 1;
        return self.root!;
        //Creates root node, 50000 is midpoint
    }
    
    func assignLevels(roots : Array<Node>) {
        if (neededNodes > 0) {
            var children = Array<Node>();
            //Creates children vector
            for givenNode in roots {
                givenNode.leftptr = Node(val: Float(Float(givenNode.val!) / randomIncrement()))
                givenNode.rightptr = Node(val: Float(Float(givenNode.val!) * randomIncrement()))
                //Creates new nodes of lesser/greater difficulty, assigns them accordingly
                children.append(givenNode.leftptr!);
                children.append(givenNode.rightptr!);
                neededNodes -= 2;
                //Pushes back new nodes to create their own children, reduces neededNodes by 2
            }
            assignLevels(roots: children);
        }//Will stop if No more needed Nodes, ensures 100000 Nodes.
    }
    
    init(){
        self.root = createRoot();
        var rootVector = Array<Node>()
        rootVector.append(root!)
        self.assignLevels(roots: rootVector);
        //Creates the tree
    }
}

class Heap {
    var size = enemyDataSize
    var heapArray: Array<enemyObj> = Array()
    var startingVal = Float(enemyDataSize/2)
    
    func heapify( n : Int, i : Int) { //heapifies a single value at a time
        var largest = i;
        let l = 2 * i + 1;
        let r = 2 * i + 2;
        
        if (l < n && self.heapArray[l].val! > self.heapArray[largest].val!) {
            largest = l;
        }
        if (r < n && self.heapArray[r].val! > self.heapArray[largest].val!) {
            largest = r;
        }
        
        if (largest != i) {
            self.heapArray.swapAt( i, largest)
            heapify(n: n, i: largest)
        }
    }
    
    func heapSort(n: Int)  { // sorts heap to a minheap
        var i = n / 2 - 1
        while(i >= 0) {
            self.heapify(n: n, i: i)
            i -= 1
        }
        i = n
        while (i > 0) {
            self.heapArray.swapAt( 0 , i);
            self.heapify(n: i, i: 0);
            i -= 1
        }
    }
    
    init (){ //initializes the heap and fills in the enemy data
        var i = 0
        heapArray.reserveCapacity(Int(size) + 2)
        heapArray.append(enemyObj(val: startingVal))
        while (i < Int(size) / 2 + 1){
            heapArray.insert(enemyObj(val: heapArray[i].val! / randomIncrement()), at: 2 * i + 1)
            heapArray.insert(enemyObj(val: heapArray[i].val! * randomIncrement()), at: 2 * i + 2)
            i += 1;
        }
        //sorts heap to minHeap when its done being created
        self.heapSort(n: Int(size))
    }
}

class MainScene: SKScene , SKPhysicsContactDelegate {
    
    fileprivate var pauseButton : SKSpriteNode?
    fileprivate var healthbar = UIProgressView()
    fileprivate var moveButton : SKSpriteNode?
    fileprivate var moving : Bool?
    var moveTo : CGPoint?
    fileprivate var attackButton : SKSpriteNode?
    var attackLocation : CGPoint?
    fileprivate var characterSprite : SKSpriteNode?
    fileprivate var endLabel : SKLabelNode?
    fileprivate var scoreLabel : SKLabelNode?
    fileprivate var attackSprite : SKSpriteNode?
    //All labels, buttons, and sprites are typed here
    var charSpeed : Float? //is pixels moved per frame
    var attackSpeed : Float? //duration of standard attack in seconds
    var attackPower : Float? //health subtracted per frame
    var enemyCount : Int? //spawned enemies - dead enemies
    var score : Int? //killed enemies
    var range : Float?
    var activeEnemies: Array<enemyObj> = Array()
    var tempRootPtr : Node?
    //View-specific variables
    class func newMainScene() -> MainScene {
        // Load 'MainScene.sks' as an SKScene.
        guard let scene = MainScene(fileNamed: "MainScene") else {
            print("Failed to load MainScene.sks")
            abort()
        }
        // Set the scale mode to scale to fill the window
        print("Loaded MainScene.sks")
        scene.scaleMode = .aspectFill
        return scene
    }
    
    func setUpScene() {
        print("Setting up Main Scene")
        attackRight = false
        attacking = false
        health = 1
        enemyCount = 0
        score = 0
        charSpeed = 0.5
        attackSpeed = 0.5
        attackPower = 0.5
        range = 80.0
        moving = false
        activeEnemies.removeAll()
        //resets variables in case of main menu to newgame where they wouldn't be set to default
        tempRootPtr = bstObj!.root
        //sets tempRootPtr to created binary tree's root
        self.characterSprite = self.childNode(withName: "//leaf") as? SKSpriteNode
        //all label and sprite initializations will follow this format
        self.endLabel = self.childNode(withName: "//endLabel") as? SKLabelNode
        endLabel!.alpha = 0 //makes end screen win/lose invisible
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
        let ui = UIView()
        self.view?.addSubview(ui)
        ui.frame = self.frame
        ui.backgroundColor = UIColor.clear
        ui.center = self.view!.center
        healthbar.progress = health!
        healthbar.progressTintColor = UIColor.green
        healthbar.trackTintColor = UIColor.red
        healthbar.frame = CGRect(x: (view?.frame.maxX)!*0.65 , y: (view?.frame.maxY)!*0.025, width: (view?.frame.maxX)!*0.25, height: (view?.frame.maxY)!*0.05)
        ui.addSubview(healthbar)
        //creates a ui view to transpose the healthbar onto
        self.pauseButton = self.childNode(withName: "//pauseImage") as? SKSpriteNode
        self.moveButton = self.childNode(withName: "//moveImage") as? SKSpriteNode
        self.attackButton = self.childNode(withName: "//attackImage") as? SKSpriteNode
        self.attackSprite = self.childNode(withName: "//attackSprite") as? SKSpriteNode
        //Initializes sprites for buttons and character sprites
        attackSprite!.name = "attackSprite"
        attackSprite!.physicsBody?.isDynamic = false
        attackSprite!.physicsBody?.contactTestBitMask = 1
        attackSprite!.physicsBody?.usesPreciseCollisionDetection = true
        //Sets up physics body so collisions between enemies and attack can be calculated
    }

    //When the screen starts to load, this is called to handle setup
    override func didMove(to view: SKView) {
        if (!paused){ //First initialization, when not coming from pause screen
            self.setUpScene()
            self.physicsWorld.contactDelegate = self
        }else{//when coming from pause screen, the ui needs to be reset but the scene is already set up
            let ui = UIView()
            self.view?.addSubview(ui)
            ui.frame = self.frame
            ui.backgroundColor = UIColor.clear
            ui.center = self.view!.center
            healthbar.progressTintColor = UIColor.green
            healthbar.trackTintColor = UIColor.red
            healthbar.frame = CGRect(x: (view.frame.maxX)*0.65 , y: (view.frame.maxY)*0.025, width: (view.frame.maxX)*0.25, height: (view.frame.maxY)*0.05)
            ui.addSubview(healthbar)
            print(health!)
            healthbar.progress = health!
        }
    }
    
    //Gives random point for enemy to spawn into within screen
    func randomPoint() -> CGPoint {
        let randX = CGFloat.random(in: 0 ... 1) * view!.frame.width - view!.frame.width / 2
        let randY = CGFloat.random(in: 0 ... 1) * view!.frame.height - view!.frame.height / 2
        return CGPoint(x: randX, y: randY)
    }
    
    //calls this function when attack collides with enemy
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.name == "attackSprite"  || contact.bodyB.node?.name == "attackSprite"){
            //checks that two enemies arent colliding
            if (attacking && activeEnemies.count > 0){
                var i = 0
                while (i < activeEnemies.count) {
                    if (!activeEnemies[i].fought!){
                        //if enemy isnt dead, calculates distance and subtracts health based on attackPower
                        let xDist = activeEnemies[i].spriteNode!.position.x - attackSprite!.position.x
                        let yDist = activeEnemies[i].spriteNode!.position.y - attackSprite!.position.y
                        let dist = sqrt(xDist * xDist + yDist * yDist)
                        if (dist < 42){
                            activeEnemies[i].health! -= max((attackPower! - activeEnemies[i].defense!)/60.0, 0.001)
                            //print( String(activeEnemies[i].health!) + " - " + String(attackPower! - activeEnemies[i].defense!/60.0 ) ) for checking balance
                            if (activeEnemies[i].health! <= 0){
                                activeEnemies[i].spriteNode!.alpha = 0
                                activeEnemies[i].spriteNode!.position = CGPoint(x: 1000, y: 1000)
                                activeEnemies[i].spriteNode!.removeFromParent()
                                activeEnemies[i].fought! = true
                                score! += 1
                                scoreLabel!.text = "Score: " + String(score!)
                            }//Add comments here
                        }
                    }
                    i += 1
                }
            }
        }
    }
    
    //Spawns enemy from the Binary Tree
    func bstSpawnEnemy (right : Bool) {
        let timeBegin = CACurrentMediaTime()
        let enemy = tempRootPtr!.enemy!.spriteNode!
        //takes the current node's enemy and initializes it to the screen
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width/4)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.contactTestBitMask = 1
        enemy.physicsBody?.usesPreciseCollisionDetection = true
        enemy.physicsBody?.affectedByGravity = false
        enemy.position = randomPoint()
        //adds a physics collision interface for the enemy created
        self.addChild(enemy)
        print("spawned bst Enemy, right = " + String(right))
        enemyCount! += 1
        activeEnemies.append(tempRootPtr!.enemy!)
        if (right){ //Right for stronger enemy
            if (tempRootPtr?.rightptr != nil){
                tempRootPtr! = tempRootPtr!.rightptr!
                //moves right down the tree for the next enemy
            }else{
                enemyCount! = -1
                //says no more enemies available
            }
        }else{
            if (tempRootPtr?.leftptr != nil){
                tempRootPtr! = tempRootPtr!.leftptr!
            }else{
                enemyCount! = -1
            }
        } // ADD COMMent
        let timeToComplete = (floor((CACurrentMediaTime() - timeBegin)*1000000))/1000000
        bstAccessTime = Float(timeToComplete)
        print("Load Time BST: " + String(timeToComplete))
    }
    
    //Spawning logic for heap
    var j = Int(enemyDataSize / 2)
    func heapSpawnEnemy (right : Bool) {
        print(j)
        let timeBegin = CACurrentMediaTime()
        let enemy = heapObj!.heapArray[j].spriteNode!
        //Obtains enemy from the current index in the heap Array
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width/4)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.contactTestBitMask = 1
        enemy.physicsBody?.usesPreciseCollisionDetection = true
        enemy.physicsBody?.affectedByGravity = false
        enemy.position = randomPoint()
        //creates a collision detection for the enemy
        self.addChild(enemy)
        //Adds enemy to view
        print("spawned heap Enemy, right = " + String(right))
        enemyCount! += 1
        activeEnemies.append((heapObj?.heapArray[j])!)
        //Adds enemy with stats to active enemies for update logic
        if (right){ //Right for stronger enemy
            if (j + Int((enemyDataSize - Float(j)) / 15) < (heapObj?.heapArray.count)!){
                j += Int((enemyDataSize - Float(j)) / 15)
                //goes deeper in the minheap
                while(j < heapObj!.heapArray.count && heapObj!.heapArray[j].fought!){ //If enemy has not been fought yet
                    print("Array Collision -> Going Right")
                    j += 1
                    //moves index to the right until unfought enemy, leading to a harder enemy being selected
                }
                if (j >= heapObj!.heapArray.count){
                    enemyCount! = -1
                    //Double checks j is not out of bounds
                }
            }else{
                enemyCount! = -1
                //sets any more enemies to not be able to spawn
            }
        }else{
            if (j - Int(Float(j) / 15) >= 0 ){
                j -= Int(Float(j) / 15)
                //moves to the index of a weaker enemy
                while(j > 0 && heapObj!.heapArray[j].fought!){ //If enemy has already been fought
                    print("Array Collision -> Going Left")
                    j -= 1
                    //moves index to the left until unfought enemy, leading to a weaker enemy being selected
                }
                if (j < 0){
                    enemyCount! = -1
                    //Double checks j is not out of bounds
                }
            }else{
                enemyCount! = -1
                //sets any more enemies to not be able to spawn
            }
        }
        let timeToComplete = (floor((CACurrentMediaTime() - timeBegin)*1000000))/1000000
        heapAccessTime = Float(timeToComplete)
        print("Load Time Heap: " + String(timeToComplete))
    }
    
    //Move function for enemies
    func customMove (to : SKSpriteNode, from: SKSpriteNode, speed: Float){
        let xDist = from.position.x - to.position.x
        let yDist = from.position.y - to.position.y
        let dist = sqrt(xDist * xDist + yDist * yDist)
        if (dist > CGFloat(speed)){
            from.position.x -= xDist / dist * CGFloat(speed)
            from.position.y -= yDist / dist * CGFloat(speed)
        }else{
            from.position = to.position
        }
    }
    //Move function for character
    func customMove (to : CGPoint, from: SKSpriteNode, speed: Float){
        let xDist = from.position.x - to.x
        let yDist = from.position.y - to.y
        let dist = sqrt(xDist * xDist + yDist * yDist)
        if (dist > CGFloat(speed)){
            from.position.x -= xDist / dist * CGFloat(speed)
            from.position.y -= yDist / dist * CGFloat(speed)
        }else{
            from.position = to
        }//moves up to max speed times the direction of movement
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        //Attack Behavior, sets attacking to true immediately so it's only run once per attack, not once a frame
        if (attackRight && !attacking){
            attacking = true
            attackSprite!.position = characterSprite!.position
            var xDist = attackLocation!.x - attackButton!.position.x
            var yDist = attackLocation!.y - attackButton!.position.y
            let dist = sqrt(xDist * xDist + yDist * yDist)
            xDist = xDist/dist
            yDist = yDist/dist
            let normalizedLocation = CGPoint(x: characterSprite!.position.x + xDist * CGFloat(range!), y: characterSprite!.position.y + yDist * CGFloat(range!))
            //Caclulates a normalized location within the attack button so it serves as a joystick of sorts
            attackSprite!.run(SKAction.move(to: normalizedLocation, duration: TimeInterval(attackSpeed!))){
                attackRight = false
                attacking = false
            }
        }
        
        if (!attacking){
            attackSprite!.position = CGPoint(x: 0, y: 1000)
        }// Removes Sprite from view if not being used
        
        //Enemy Spawn Behavior
        if (enemyCount! == score! || Int.random(in: 0 ... (60 * 5)) < 1 ){
            if (!heap){
                if (enemyCount! >= 0){
                    if (healthbar.progress < 1){
                        bstSpawnEnemy(right: false) //spawn harder enemy
                    }else{
                        bstSpawnEnemy(right: true) //spawn weaker
                    }
                }else{
                    print("out of tree enemies")
                }
            } else{
                if (enemyCount! >= 0){
                    if (healthbar.progress < 1){
                        heapSpawnEnemy(right: false) //spawn harder enemy
                    }else{
                        heapSpawnEnemy(right: true) //spawn weaker
                    }
                }else{
                    print("out of heap enemies")
                }
            }
        }// Spawns an enemy if none are currently on the screen
        
        //Enemy Move and Attack behavior
        var i = 0
        while (i < activeEnemies.count) {
            if (!activeEnemies[i].fought!){
                //cycles through each active (not dead) enemy
                let xDist = activeEnemies[i].spriteNode!.position.x - characterSprite!.position.x
                let yDist = activeEnemies[i].spriteNode!.position.y - characterSprite!.position.y
                let dist = sqrt(xDist * xDist + yDist * yDist)
                if (dist < 25){ //enemy is close enough to player to cause damage
                    if(healthbar.progress > activeEnemies[i].attack! / 60.0){
                        healthbar.progress -= activeEnemies[i].attack! / 60.0
                    }else{
                        healthbar.progress = 0
                    }
                }
                customMove(to: characterSprite!, from: activeEnemies[i].spriteNode!, speed: activeEnemies[i].moveSpeed!)
            }
            i += 1
        } //enemy controller for movement and damage for all on screen enemies
        
        //Check Win logic
        if (enemyCount! < 0 && score! == activeEnemies.count){
            //insert win logic here
            //print("Win! Score: " + String(score!))
            endLabel!.alpha = 0
            endLabel!.text = "Win! Score: " + String(score!)
            endLabel!.run(SKAction.fadeIn(withDuration: 1)){
                self.isPaused = true
            }
        } //win logic to display win
        
        //Healing when not moving
        if (!moving!){
            if (healthbar.progress < 1 && healthbar.progress != 0){
                healthbar.progress += 0.03/60.0 //Heal per frame
            }
        }
        
        //Charcter stats improvement, per frame
        charSpeed! += 0.01/60.0 //move faster over time
        attackPower! += 0.06/60.0 //kill enemies with less frames
        if (attackSpeed! > 0.001/60.0){
            attackSpeed! -= 0.001/60.0 //attack sprite moves faster
        }
        
        //Lose logic
        if (healthbar.progress <= 0){
            //print("Lose! Score: " + String(score!))
            endLabel!.alpha = 0
            endLabel!.text = "Lose! Score: " + String(score!)
            endLabel!.run(SKAction.fadeIn(withDuration: 1)){
                self.isPaused = true
            }
        }
        
        //Character move logic
        if(moving!){
            customMove(to: moveTo!, from: characterSprite!, speed: Float(charSpeed!))
            if(characterSprite!.position == moveTo){
                moving = false
            }
        }
    }
}

#if os(iOS)
// Touch-based event handling
public var tempScene : SKScene?
extension MainScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touchSet = touches
        var i = 0
        while (i < touches.count){
            let touch = touchSet.popFirst()
            let touchLocation = touch!.location(in: self)
            if (attackButton!.frame.contains(touchLocation)){
                attackRight = true
                attackLocation = touchLocation
                //Enables attack to function during the next update
            }else {
                moveTo = touchLocation
                moving = true
                //Enables movement to function during the next update
            }
            i += 1
        }
        //Goes through touch set and changes booleans to reflect correct actions for the update function
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touchSet = touches
        var i = 0
        while (i < touches.count){
            let touch = touchSet.popFirst()
            let touchLocation = touch!.location(in: self)
            if (attackButton!.frame.contains(touchLocation)){
                attackRight = true
                attackLocation = touchLocation
            }else {
                moveTo = touchLocation
                moving = true
            }
            i += 1
        }
        //Same as touchesBegan event handler
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if ((pauseButton!.contains(touchLocation))){
            health = healthbar.progress
            //saves health as global variable
            self.view!.subviews.first!.removeFromSuperview()
            //removes healthbar and ui view
            let pauseScene = PauseScene.newPauseScene()
            tempScene = self
            //saves view as a global variable
            isPaused = true
            paused = true
            self.view?.presentScene(pauseScene)
            //goes to pause screen
        }
        //Pause button functionality
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
#endif
