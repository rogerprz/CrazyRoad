//
//  GameViewController.swift
//  WildRoad
//
//  Created by Roger Perez on 11/16/20.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var scene: SCNScene!
    var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    func setupScene() {
        sceneView = view as? SCNView
        scene = SCNScene()
        
        sceneView.scene = scene
    }

}
