//
//  LaneNode.swift
//  CrazyRoad
//
//  Created by Roger Perez on 12/8/20.
//

import SceneKit

enum LaneType {
    case grass, road
}


class LaneNode: SCNNode {
    
    let type: LaneType
    
    init(type: LaneType, width: CGFloat) {
        self.type = type
        super.init()
        
        switch type {
        case .grass:
            guard let texture = UIImage(named: "art.scnassets/grass.png") else {
                break
            }
            createLane(width: width, height: 0.4, image: texture)
        case .road:
            guard let texture = UIImage(named: "art.scnassets/asphalt.png") else {
                break
            }
            createLane(width: width, height: 0.05, image: texture)
        }
    }
    
    func createLane(width: CGFloat, height: CGFloat, image: UIImage) {
        let laneGeometry = SCNBox(width: width, height: height, length: 1, chamferRadius: 0)
        laneGeometry.firstMaterial?.diffuse.contents = image
        laneGeometry.firstMaterial?.diffuse.wrapT = .repeat
        laneGeometry.firstMaterial?.diffuse.wrapS = .repeat
        laneGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), 1, 1)
        
        let laneNode = SCNNode(geometry: laneGeometry)
        addChildNode(laneNode)
        addElements(width, laneNode)
    }
    
    func addElements(_ width: CGFloat, _ laneNode: SCNNode) {
        for index in 0..<Int(width) {
            if type == .grass {
                if randomBool(odds: 7) {
                    let vegetation = getVegetation()
//                    x: start at the very right o our lane. New iteration changes locaiton
                    vegetation.position = SCNVector3(x: 10 - Float(index), y: 0, z: 0)
                    laneNode.addChildNode(vegetation)
                }
            } else if type == .road {
                
            }
        }
    }
    
    func getVegetation() -> SCNNode {
        let vegetation = randomBool(odds: 2) ? Models.tree.clone() : Models.hedge.clone()
        return vegetation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
