//
//  ViewController.swift
//  ARCar
//
//  Created by Martin Mitrevski on 12.09.18.
//  Copyright © 2018 Mitrevski. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var addCarButton: UIButton!
    @IBOutlet weak var frontButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var carNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupAddButton()
        setupControlButton(frontButton)
        setupControlButton(backButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runWorldTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func createFloor(for planeAnchor: ARPlaneAnchor) -> SCNNode {
        let floorNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                                   height: CGFloat(CGFloat(planeAnchor.extent.z))))
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.init(white: 0, alpha: 0.1)
        floorNode.geometry?.firstMaterial?.isDoubleSided = true
        floorNode.position = SCNVector3(planeAnchor.center.x,
                                        planeAnchor.center.y,
                                        planeAnchor.center.z)
        floorNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        let staticBody = SCNPhysicsBody.static()
        floorNode.physicsBody = staticBody
        return floorNode
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer,
                  didAdd node: SCNNode,
                  for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let floorNode = createFloor(for: planeAnchor)
        node.addChildNode(floorNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  didUpdate node: SCNNode,
                  for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let floorNode = createFloor(for: planeAnchor)
        node.addChildNode(floorNode)
    }
    
    // MARK: - IBAction
    
    @IBAction func addCar(_ sender: UIButton) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43 - 5)
        let currentPositionOfCamera = orientation + location
        
        let scene = SCNScene(named: "art.scnassets/audi.scn")
        carNode = (scene?.rootNode.childNode(withName: "audi", recursively: false))!
        
        carNode.position = currentPositionOfCamera
        self.sceneView.scene.rootNode.addChildNode(carNode)
    }
    
    @IBAction func goFront(_ sender: UIButton) {
        runActionForCarNode(withDistance: 1)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        runActionForCarNode(withDistance: -1)
    }
    
    // MARK: - private
    
    private func runWorldTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    private func setupScene() {
        sceneView.delegate = self
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        sceneView.scene = scene
    }
    
    private func setupAddButton() {
        addCarButton.layer.cornerRadius = 5.0
        addCarButton.clipsToBounds = true
    }
    
    private func setupControlButton(_ button: UIButton) {
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
    }
    
    private func runActionForCarNode(withDistance distance: Float) {
        let action = SCNAction.move(by: SCNVector3Make(0, 0, distance), duration: 1)
        carNode.runAction(action)
    }
    
}
