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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupPlayer()
        setupFloor()
        setupCamera()
        setupLight()
    }
    
    func setupScene() {
        sceneView = (view as! SCNView)
        scene = SCNScene()
        
        sceneView.scene = scene
        
        scene.rootNode.addChildNode(mapNode)
        
        for _ in 0..<20 {
            let type = randomBool(odds: 3) ? LaneType.grass : LaneType.road
            let lane = LaneNode(type: type, width: 21) // 21 made up
            lane.position = SCNVector3(x: 0, y: 0, z: 5 - Float(laneCount))
            laneCount += 1
            lanes.append(lane)
            mapNode.addChildNode(lane)
        }
    }
    
    func setupPlayer() {
        guard let playerScene = SCNScene(named: "art.scnassets/Chicken.scn") else {
            return
        }
        if let player = playerScene.rootNode.childNode(withName: "player", recursively: true) {
            playerNode = player
            player.position = SCNVector3(x: 0, y: 0.3, z: 0)
        }
        scene.rootNode.addChildNode(playerNode)
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
        cameraNode.eulerAngles = SCNVector3(x: -toRadians(angle: 72), y: toRadians(angle: 9), z: 0)
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
    
    
}
