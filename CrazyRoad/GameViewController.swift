//
//  GameViewController.swift
//  CrazyRoad
//
//  Created by Roger Perez on 12/8/20.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var scene: SCNScene!
    var sceneView: SCNView!
    
    var cameraNode = SCNNode()
    var lightNode = SCNNode()
    var playerNode = SCNNode()
    var mapNode = SCNNode()
    var lanes = [LaneNode]()
    var laneCount = 0
    
    var jumpForwardAction: SCNAction?
    var jumpRightAction: SCNAction?
    var jumpLeftAction: SCNAction?
    var driveRightAction: SCNAction?
    var driveLeftAction: SCNAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupPlayer()
        setupFloor()
        setupCamera()
        setupLight()
        setupGestures()
        setupActions()
        setupTraffic()
    }
    
    func setupScene() {
        sceneView = (view as! SCNView)
        sceneView.delegate = self
        
        scene = SCNScene()
        
        sceneView.scene = scene
        
        scene.rootNode.addChildNode(mapNode)
        
        for _ in 0..<20 {
            createNewLane()
        }
    }
    
    func setupPlayer() {
        guard let playerScene = SCNScene(named: "art.scnassets/Chicken.scn") else {
            return
        }
        if let player = playerScene.rootNode.childNode(withName: "player", recursively: true) {
            playerNode = player
            playerNode.position = SCNVector3(x: 0, y: 0.3, z: 0)
            scene.rootNode.addChildNode(playerNode)
        }
    }
    
    func setupFloor() {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/darkgrass.png")
        floor.firstMaterial?.diffuse.wrapS = .repeat // repeat our texture and not stetch over geometry
        floor.firstMaterial?.diffuse.wrapT = .repeat
        floor.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(12.5, 12.5, 12.5) // 4 dimensional matrix

        
        floor.reflectivity = 0.0
        
        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
    }
    
    func setupCamera() {
        cameraNode.camera = SCNCamera()
//        x 0 keep camera on middle of x axis y:10 above the ground z: camera center
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 0)
//        make camera face downward y:0 face the floor, z:
        cameraNode.eulerAngles = SCNVector3(x: -toRadians(angle: 60), y: toRadians(angle: 20), z: 0)
        scene.rootNode.addChildNode(cameraNode)
 
//        STRAIGHT DOWN CAMERA
//        cameraNode.camera = SCNCamera()
////        x 0 keep camera on middle of x axis y:10 above the ground z: camera center
//        cameraNode.position = SCNVector3(x: 0, y: 10, z: 0)
////        make camera face downward y:0 face the floor, z:
//        cameraNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0)
//        scene.rootNode.addChildNode(cameraNode)
    }
    
    func setupLight() {
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        
        let directionalNode = SCNNode()
        directionalNode.light = SCNLight()
        directionalNode.light?.type = .directional
        directionalNode.light?.castsShadow = true
        directionalNode.light?.shadowColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        directionalNode.position = SCNVector3(x: -5, y: 5, z: 0)
        directionalNode.eulerAngles = SCNVector3(x: 0, y: -toRadians(angle: 90), z: -toRadians(angle: 45))
        
        lightNode.addChildNode(ambientNode)
        lightNode.addChildNode(directionalNode)
        lightNode.position = cameraNode.position
        scene.rootNode.addChildNode(lightNode)
    }
    func setupGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = .up
        sceneView.addGestureRecognizer(swipeUp)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeft.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)
    }
    
    func setupActions() {
        // if we want to move our player forward we need to jump up and move forward
        let moveUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration: 0.1)
        let moveDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration: 0.1)
        moveUpAction.timingMode = .easeOut
        moveDownAction.timingMode = .easeIn
        let jumpAction = SCNAction.sequence([moveUpAction,moveDownAction])
        
        let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1.0, duration: 0.2)
        let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration: 0.2)
        let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration: 0.2)
        
        let turnForwardAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 180), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnRightAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: -90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        
        jumpForwardAction = SCNAction.group([turnForwardAction, jumpAction, moveForwardAction])
        jumpRightAction = SCNAction.group([turnRightAction, jumpAction, moveRightAction])
        jumpLeftAction = SCNAction.group([turnLeftAction, jumpAction, moveLeftAction])
        
        // Moves car by 1 sec at a time.
        driveRightAction = SCNAction.repeatForever(SCNAction.moveBy(x: 2.0, y: 0, z: 0, duration: 1))
        driveLeftAction = SCNAction.repeatForever(SCNAction.moveBy(x: -2.0, y: 0, z: 0, duration: 1)) 

    }
    
    func setupTraffic() {
        for lane in lanes {
            if let trafficNode = lane.trafficNode {
                addActions(for: trafficNode)
            }
        }
    }
    
    func jumpForward() {
        if let action = jumpForwardAction {
            addLanes()
            playerNode.runAction(action)
        }
    }
    
    func updatePositions() {
//        update camera to view camera.
        let diffX = (playerNode.position.x + 1 - cameraNode.position.x) // add 1 to offset to right
        let diffZ = (playerNode.position.z + 2 - cameraNode.position.z) // offset to the back.
        cameraNode.position.x += diffX
        cameraNode.position.z += diffZ
        
        lightNode.position = cameraNode.position
    }
    
    func updateTraffic() {
//        ensures that vehicles that go outside the map will be moved back to the start.
        for lane in lanes {
            guard let trafficNode = lane.trafficNode else {
                continue
            }
            for vehicle in trafficNode.childNodes {
                if vehicle.position.x > 10 {
                    vehicle.position.x = -10
                } else if vehicle.position.x < -10 {
                    vehicle.position.x = 10
                }
            }
        }
    }
    
    func addLanes() {
        for _ in 0...1 {
            createNewLane()
        }
        
        removeUnusedLanes()
    }
    
    func removeUnusedLanes() {
//        removing used lanes by removing the children from map node.
        for child in mapNode.childNodes {
            if !sceneView.isNode(child, insideFrustumOf: cameraNode) && child.worldPosition.z > playerNode.worldPosition.z {
                child.removeFromParentNode()
                lanes.removeFirst()
                print("Removed unused lane")
            }
        }
    }
    
    func createNewLane() {
        let type = randomBool(odds: 3) ? LaneType.grass : LaneType.road
        let lane = LaneNode(type: type, width: 21) // 21 made up
        lane.position = SCNVector3(x: 0, y: 0, z: 5 - Float(laneCount))
        laneCount += 1
        lanes.append(lane)
        mapNode.addChildNode(lane)
        
        if let trafficNode = lane.trafficNode {
            addActions(for: trafficNode)
        }
    }
    
    func addActions(for trafficNode: TrafficNode) {
        guard let driveAction = trafficNode.directionRight ? driveRightAction : driveLeftAction else {
            return
        }
//        change speed of vehicles. Don't use zero so it won't crash
        driveAction.speed = 1/CGFloat(trafficNode.type + 1) + 0.5
        for vehicle in trafficNode.childNodes {
            vehicle.runAction(driveAction)
        }
        
    }
    
}

// updatePositions frames continously using loop.
extension GameViewController: SCNSceneRendererDelegate {
//    called after render actions have been evaluated
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updatePositions()
        updateTraffic()
    }
}

extension GameViewController {
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.up:
            jumpForward()
        case UISwipeGestureRecognizer.Direction.right:
            if playerNode.position.x < 10 {
                if let action = jumpRightAction {
                    playerNode.runAction(action)
                }
            }
        case UISwipeGestureRecognizer.Direction.left:
            if playerNode.position.x > -10 {
                if let action = jumpLeftAction {
                    playerNode.runAction(action)
                }
            }
        default:
            break
        }
    }
}
