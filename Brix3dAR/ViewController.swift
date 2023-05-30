//
//  ViewController.swift
//  Brix3dAR
//
//  Created by Todd Bruss on 3/8/18.
//  Copyright © 2018 Todd Bruss. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

var panfingers = 1
var doubletap = 2

var gWidth = CGFloat()
var gHeight = CGFloat()
var gDepth = CGFloat()
var gAmnesty = Bool(false)
class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        //sceneView.debugOptions = .showPhysicsShapes
        sceneView.showsStatistics = false
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        gWidth = CGFloat(1.0)
        gHeight = CGFloat(gWidth * 0.85)
        gDepth = CGFloat(gWidth * 2)
        
        
        let world = SCNPhysicsWorld()
        world.gravity = SCNVector3(x:0, y:0, z:0)
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity = world.gravity
        
        //This is a test
        
        // Add pan gesture for dragging the textNode about
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:))))
        
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        
        gesture.minimumNumberOfTouches = panfingers
        
        if gamestartup {
            
            let pos = gesture.location(in: gesture.view)
            
            //print( virtualstick.position )
            let adjustment = CGFloat((sceneView.frame.width / 2 ))
            let adjustmentY = CGFloat((sceneView.frame.height / 2 ))
            
            let constraintX = CGFloat(64 + 16 )
            if (pos.x >= constraintX && pos.x <= (adjustment * 2) - constraintX) {
                virtualstick.position.x = Float(pos.x / adjustment / 2 - 0.5) * 1
            }
            
            let constraintY = CGFloat(-256)
            if (pos.y >= constraintY && pos.y <= (adjustmentY * 2) - constraintY) {
                virtualstick.position.y = (Float(pos.y / adjustmentY / 2 - 0.5 )) * -1
            }
            
        } else {
            let results = self.sceneView.hitTest(gesture.location(in: gesture.view), types: [ ARHitTestResult.ResultType.existingPlane ])
            guard let result: ARHitTestResult = results.first else {
                return
            }
            
            if let planeAnchor = result.anchor as? ARPlaneAnchor {
                // keep track of selected anchor only
                
                // set isPlaneSelected to true
                let node = sceneView.node(for: planeAnchor)
                
                let position = SCNVector3Make(result.localTransform.columns.3.x, result.localTransform.columns.3.y, result.localTransform.columns.3.z)
                node?.childNodes.first?.position = position
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        configuration.isAutoFocusEnabled = true
        configuration.isLightEstimationEnabled = true
        
        configuration.worldAlignment = .gravity
        // Run the view's session
        sceneView.session.run(configuration)
        
        toggleTorch(on: false)// turn on the flash
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !gamestartup && !firstplane {
            // Place content only for anchors found by plane detection.
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            //firstplane = true
            // Create a SceneKit plane to visualize the plane anchor using its position and extent.
            let box = SCNBox(width: CGFloat(0.75), height: 0.02, length: CGFloat(0.75), chamferRadius: 0.00)
            let planeNode = SCNNode(geometry: box)
            
            planeNode.simdPosition.z = -0.02
            planeNode.simdPosition.y = planeAnchor.center.y
            planeNode.simdPosition.x = planeAnchor.center.x
            
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
            // Make the plane visualization semitransparent to clearly show real-world placement.
            planeNode.opacity = 0.334
            
            // Add the plane visualization to the ARKit-managed node so that it tracks
            // changes in the plane anchor as plane estimation continues.
            //node.addChildNode(planeNode)
            firstplane = true
            node.addChildNode(planeNode)
            
        }
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    
    // selects the anchor at the specified location and removes all other unused anchors
    func selectExistingPlane(location: CGPoint) {
        
        let hitResults = sceneView.hitTest(location, types: .existingPlane)
        if hitResults.count > 0 && !gamestartup {
            if let result: ARHitTestResult = hitResults.first,
               let planeAnchor = result.anchor as? ARPlaneAnchor {
                // keep track of selected anchor only
                gamestartup = true
                
                // set isPlaneSelected to true
                let node = sceneView.node(for: planeAnchor)
                
                for otherplanes in sceneView.scene.rootNode.childNodes {
                    
                    if otherplanes != node {
                        otherplanes.removeFromParentNode()
                    }
                    
                }
                
                
                //This is the Vertical PlaneNode which Apple seems to flip its Y and Z
                //Shortcut Apple? Yup. Don't worry, A mad scientist can fix it.
                node?.childNodes.first?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                
                //This is basically a copy that we add to the sceneView.
                //We are doing this so our 0,0,0 point remains on our wall
                //And all its alignment, orientation, etc is retained, including the Y and Z flip
                let flippedYZ_Node = SCNNode()
                flippedYZ_Node.simdWorldTransform = (node?.simdWorldTransform) ?? simd_float4x4()
                flippedYZ_Node.simdWorldOrientation = (node?.simdWorldOrientation) ?? simd_quatf()
                flippedYZ_Node.simdWorldPosition =  (node?.simdWorldPosition) ?? simd_float3()
                //Only remaining issue is the y and z axis are still flipped
                sceneView.scene.rootNode.addChildNode(flippedYZ_Node)
                
                //Don't worry, we can fix that with our gameNode as as child.
                //flip our gamenode back 90 degrees to get our axis right.
                let gamenode = SCNNode()
                
                if let pos = node?.childNodes.first?.position {
                    gamenode.position = pos
                }
                
                gamenode.eulerAngles.x = -.pi / 2
                flippedYZ_Node.addChildNode(gamenode)
                
                //Why did we do it this way?
                //Because all PhyicsBodys are now retained.
                //Our game always attached to the wall.
                //No f'd up tilting or misalignment with the real world.
                //Apple's Y Z shortcut for vertical planes can
                //royally screw up the PhysicsBody's alignment
                //it can do a kinds of crazy stuff
                
                let snapshot = sceneView.snapshot()
                let slicedImages = splitImage(portraitSnapshot: snapshot, row: 5, column: 5)
                setUpGameBoard(gamenode: gamenode, scene: sceneView.scene,  slicedImages: slicedImages, snapshot: snapshot  )
                
            }
        }
        
    }
    
    
    // moves the plane around the scene
    func moveExistingPlane(location: CGPoint) {
        
    }
    
    
    
    @objc func doubleTapped(_ gesture: UITapGestureRecognizer)  {
        
        gesture.numberOfTapsRequired = doubletap
        
        if !gamestartup {
            let location = gesture.location(in: gesture.view)
            selectExistingPlane(location: location)
        } else {
            return
        }
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
        if  ( contact.nodeA.name == nil || contact.nodeB.name == nil ) {
            return
        }
        
        var A = contact.nodeA
        var B = contact.nodeB
        
        if ( contact.nodeB.name! != "sphere" ) {
            B = contact.nodeA
            A = contact.nodeB
        }
        
        //var hitabrick = false
        if B.name == "sphere" && A.name == "brix" {
            A.removeFromParentNode()
            //hitabrick = true
            brixCount = brixCount - 1
            scoreVal = scoreVal + 1
            
            score.string = String(scoreVal)
            //let count = CGFloat(String(scoreVal).count) //this a red neck way to fix centering
            //score.containerFrame = CGRect(x: (count * -0.15)/2, y: 0.3, width: 0.8, height: 0.3)
            
            if brixCount < 1 && restartLevel {
                brixCount = 125
                restartLevel = false
                drawManyBrix(slicedImages: gImageSlices)
            }
            
            let yellow = SCNAction.run{ (B) in
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.yellow
                B.geometry?.firstMaterial = material
            }
            
            let green = SCNAction.run{ (B) in
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.green
                B.geometry?.firstMaterial = material
            }
            
            let wait = SCNAction.wait(duration: 0.25)
            
            let seq = SCNAction.sequence([yellow,wait,green])
            B.runAction(seq)
            
            
            //Add sound here
        } else if B.name == "sphere" && A.name == "paddle" {
            
            let orange = SCNAction.run{ (B) in
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.orange
                B.geometry?.firstMaterial = material
                
                if buzz {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    B.physicsBody?.applyForce(SCNVector3(x: -1.5, y: -1.5, z: -1.5), asImpulse: true)
                    B.physicsBody?.angularVelocityFactor = SCNVector3(x:-1.5,y:-1.5,z:-1.5)
                }
            }
            
            let green = SCNAction.run{ (B) in
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.green
                B.geometry?.firstMaterial = material
            }
            
            let runner1 = SCNAction.run{ (B) in
                gAmnesty = true
            }
            
            let runner2 = SCNAction.run{ (B) in
                gAmnesty = false
            }
            
            let wait = SCNAction.wait(duration: 1)
            
            let seq = SCNAction.sequence([runner1,orange,wait,green,wait,runner2])
            B.runAction(seq)
            
            
        }
        
        if B.name == "sphere" {
            if A.name == "grid" && !gAmnesty {
                print("grid, Amnesty:", gAmnesty)
                A.name = "gridX"
                A.opacity = 0.15 / 2
                gridCounter += 1
            }

            let Bee = B.physicsBody ?? SCNPhysicsBody()

            Bee.applyForce(SCNVector3(x: Bee.velocity.x * 0.25, y: Bee.velocity.y * 0.25, z: Bee.velocity.z *  0.25), asImpulse: true)

            let max = Float(0.5)

            if Bee.velocity.x > max {
                Bee.velocity.x = max
            } else if Bee.velocity.x < -max  {
                Bee.velocity.x = -max
            }

            if Bee.velocity.y > max {
                Bee.velocity.y = max
            } else if Bee.velocity.y < -max  {
                Bee.velocity.y = -max
            }

            if Bee.velocity.z > max {
                Bee.velocity.z = max
            } else if Bee.velocity.z < -max  {
                Bee.velocity.z = -max
            }
            

        }
    }
}
