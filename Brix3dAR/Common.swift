//
//  Common.swift
//  BrixAR
//
//  Created by Todd Bruss on 3/7/18.
//  Copyright © 2018 Todd Bruss. All rights reserved.
//

import SceneKit
import ARKit

var gamestartup = Bool(false)
var firstplane = Bool(false)
var dragplane = Bool(false)

var wallCategory = Int(2)
var paddleCategory = Int(4)
var brixCategory = Int(8)
var ballCategory = Int(16)
var gridCategory = Int(32)

var virtualstick = SCNNode()
var gScale = Float(1.0)
var throttle = Float(0.25)
var bounce = Float(1.5)
var buzz = Bool(true)
var brixCount = Int(125)
var gImageSlices = [[UIImage]]()
var cubeNode = SCNNode()
var restartLevel = Bool(true)
var score = SCNText()
var scoreVal = Int(0)
var gridCounter = Int(0)

func setUpGameBoard(gamenode: SCNNode, scene: SCNScene, slicedImages: [[UIImage]], snapshot: UIImage) {
    gamenode.simdScale = simd_float3(x:gScale, y:gScale, z:gScale)
    
    cubeNode.position = SCNVector3(x:0,y:0,z:0 )
    gamenode.addChildNode(cubeNode)
    
    //Draw Brix
    gImageSlices = slicedImages
    drawManyBrix(slicedImages: gImageSlices)
    
//    let field = SCNPhysicsField.turbulenceField(smoothness: 100, animationSpeed: 100)
//    let fieldNode = SCNNode()
//    field.scope = .insideExtent
//    field.direction.x = 0
//    field.direction.y = 0
//    field.direction.z = 0
//    field.halfExtent = SCNVector3(x:Float(gWidth/1.5), y:Float(gHeight/1.5), z:Float(gDepth/1.5))
//    field.usesEllipsoidalExtent = true
//    fieldNode.position.z = Float(gDepth / 2)
//    fieldNode.physicsField = field
//    fieldNode.physicsField?.falloffExponent = 0.01
//    gamenode.addChildNode(fieldNode)
//    field.strength = 1.0
    
    let zGrid = CGFloat(gDepth / 1.45)
    let xRange = stride(from: -gWidth / 3, through: gWidth / 3, by: gWidth / 3)
    let yRange = stride(from: gHeight / 3, through: -gHeight / 3, by: -gHeight / 3)
    
    let gridZone: [(x: CGFloat, y: CGFloat, z: CGFloat)] = xRange.flatMap { x in
        yRange.map { y in
            (x: x, y: y, z: zGrid)
        }
    }
    
    gridZone.forEach { grid in
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIColor.magenta
        let gridPlane = SCNPlane(width: gWidth / 3, height: gHeight / 3)
        drawPlane(gameNode: gamenode,
                  Name: "grid",
                  Material: gridMaterial,
                  Plane: gridPlane,
                  Opacity: 0.0,
                  X: Float(grid.x),
                  Y: Float(grid.y),
                  Z: Float(grid.z),
                  Type: 1)
    }
    
    //Common Material for the Box
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.lightGray
    
    //Floor
    let floorBox = SCNBox(width: gWidth, height: 0.02, length: gDepth, chamferRadius: 0.02)
    let floorMaterial = SCNMaterial()
    floorMaterial.diffuse.contents = UIColor.cyan
    var opacity = CGFloat(0.2)
    var name = String("floor")
    var x = Float(0)
    var y = Float(-gHeight / 2)
    var z = Float(gDepth / 4)
    
    drawSides(gameNode: gamenode,
              Name: name,
              Material: floorMaterial,
              Box: floorBox, Opacity:
                opacity,
              X: x, Y: y, Z: z
    )
    
    //Top
    let topBox = SCNBox(width: gWidth, height: 0.02, length: gDepth, chamferRadius: 0.02)
    let topMaterial = SCNMaterial()
    topMaterial.diffuse.contents = UIColor.cyan
    opacity = CGFloat(0.2)
    name = String("top")
    x = Float(0)
    y = Float(gHeight / 2)
    z = Float(gDepth / 4)
    
    drawSides(gameNode: gamenode,
              Name: name,
              Material: topMaterial,
              Box: topBox,
              Opacity: opacity,
              X: x, Y: y, Z: z
    )
    
    //Left
    //let leftPlane = SCNPlane(width: 1.5, height: 1.5 )
    let leftBox = SCNBox(width: 0.02, height: gHeight, length: gDepth, chamferRadius: 0.02)
    let leftMaterial = SCNMaterial()
    leftMaterial.diffuse.contents =  UIColor.cyan
    opacity = CGFloat(0.2)
    name = String("left")
    x = Float(-gWidth / 2)
    y = Float(0)
    z = Float(gDepth / 4)
    drawSides(gameNode: gamenode, Name: name, Material: leftMaterial, Box: leftBox, Opacity: opacity, X: x, Y: y, Z: z)
    
    //Right
    //Left
    //let leftPlane = SCNPlane(width: 1.5, height: 1.5 )
    let rightBox = SCNBox(width: 0.02, height: gHeight, length: gDepth, chamferRadius: 0.02)
    let rightMaterial = SCNMaterial()
    rightMaterial.diffuse.contents =  UIColor.cyan
    opacity = CGFloat(0.2)
    name = String("right")
    x = Float(gWidth / 2)
    y = Float(0)
    z = Float(gDepth  / 4)
    drawSides(gameNode: gamenode, Name: name, Material: rightMaterial, Box: rightBox, Opacity: opacity, X: x, Y: y, Z: z)
    
    //Back
    // 640 x 1136 iPhone 5
    //0.64   1.136
    let backBox = SCNBox(width:gWidth, height: gHeight, length: 0.02, chamferRadius: 0.02)
    let backMaterial = SCNMaterial()
    backMaterial.diffuse.contents =  UIColor.darkGray
    opacity = CGFloat(0.2)
    name = String("back")
    x = Float(0)
    y = Float(0)
    z = Float(0)
    drawSides(gameNode: gamenode, Name: name, Material: backMaterial, Box: backBox, Opacity: opacity, X: x, Y: y, Z: z)
    
    let frontBox = SCNBox(width: gWidth, height: gHeight, length: 0.02, chamferRadius: 0.02)
    let frontMaterial = SCNMaterial()
    backMaterial.diffuse.contents =  UIColor.cyan
    opacity = CGFloat(0.0)
    name = String("front")
    x = Float(0)
    y = Float(0)
    z = Float(gDepth / 1.25)
    drawSides(gameNode: gamenode, Name: name, Material: frontMaterial, Box: frontBox, Opacity: opacity, X: x, Y: y, Z: z)
    
    //Paddle
    let paddleMaterial = SCNMaterial()
    paddleMaterial.diffuse.contents = UIColor.blue
    let paddle = SCNBox(width: gWidth/3, height: gWidth/5, length: gWidth/15, chamferRadius: 0)
    opacity = CGFloat(0.5)
    name = String("paddle")
    x = Float(0)
    y = Float(0)
    z = Float(gDepth / 1.6)
    drawPaddle(gameNode: gamenode, Name: name, Material: paddleMaterial, Paddle: paddle, Opacity: opacity, X: x, Y: y, Z: z)
    
    //node.geometry?.firstMaterial?.reflective.contents = Material.emission
    let wait = SCNAction.wait(duration: 0.5)
    //let rotation = SCNAction.rotateBy(x: .pi / 4, y: .pi / 4, z: -.pi / 4, duration: 2)
    //let rotation2 = SCNAction.rotateBy(x: .pi / 8, y: .pi / 16, z: 0, duration: 1)
    
    let moveblocks = SCNAction.moveBy(x: 0, y: 0, z: CGFloat(0.667), duration: 2)
    // let moveblocks = SCNAction.moveBy(x: 0, y: -0.15, z: 1.0, duration: 1.5)
    
    /*
     let runcode = SCNAction.run { (gameNode) in
     gameNode.addChildNode(node)
     }*/
    
    let rc = SCNAction.run{ (cubeNode) in
        let test = cubeNode.childNodes
        
        for i in test {
            i.physicsBody?.resetTransform()
        }
    }
    
    let actionSequence = SCNAction.sequence([wait,moveblocks,rc])
    cubeNode.runAction(actionSequence)
    
    for i in scene.rootNode.childNodes {
        i.castsShadow = false
    }
    
    let h = Float(gHeight)
    let w = Float(gWidth)
    let s = Float(0.2)
    
    let numRows = 9
    let numColumns = 5
    let startX = -w / 2
    let startY = -h / 2
    let startZ = Float(0)
    
    var geoCoords: [(x: Float, y: Float, z: Float)] = []
    
    //Refactored
    for row in 0..<numRows {
        for column in 0..<numColumns {
            let x = startX + (Float(column) * (w / 2 - s / 1))
            let z = startZ + (Float(row) * s)
            geoCoords.append((x: x, y: startY, z: z))
        }
    }
    
    let rndHeights : Array<Float> = [
        0.005,
        0.010,
        0.015
    ]
    
    for g in geoCoords {
        let itemR = Int(arc4random_uniform(3))
        let geo = SCNCylinder(radius: 0.04, height: CGFloat(rndHeights[itemR]))
        let geoMaterial = SCNMaterial()
        geoMaterial.diffuse.contents = UIColor.clear
        opacity = 1.0
        name = "geo"
        x = Float(g.x)
        y = Float(g.y)
        z = Float(g.z)
        drawGeo(gameNode: gamenode, Name: name, Material: geoMaterial, Geo: geo, Opacity: opacity, X: x, Y: y, Z: z)
    }
    
    //Ball
    let ballMaterial = SCNMaterial()
    ballMaterial.diffuse.contents = UIColor.green
    let ball = SCNSphere(radius: 0.04)
    ball.isGeodesic = true
    ball.segmentCount = 12
    opacity = CGFloat(1.0)
    name = String("sphere")
    x = Float(0)
    y = Float(0)
    z = Float(gDepth / 2)
    drawSphere(gameNode: gamenode, Name: name, Material: ballMaterial, Sphere: ball, Opacity: opacity, X: x, Y: y, Z: z)
}

func drawPlane(gameNode:SCNNode,Name:String,Material:SCNMaterial,Plane:SCNPlane,Opacity:CGFloat,X:Float,Y:Float,Z:Float, Type: Int) {
    
    let node = SCNNode(geometry: Plane)
    node.position.y = node.position.y + Y
    node.position.x = node.position.x + X
    node.position.z = node.position.z + Z
    
    let planeShape = SCNPhysicsShape(geometry: Plane, options: [SCNPhysicsShape.Option(rawValue: SCNPhysicsShape.Option.scale.rawValue) : gScale])
    let physicsbody = SCNPhysicsBody(type: .static, shape: planeShape)
    node.physicsBody = physicsbody
    node.physicsBody?.categoryBitMask = gridCategory
    node.physicsBody?.allowsResting = false
    node.geometry?.firstMaterial = Material
    node.opacity = Opacity
    node.name = Name
    node.renderingOrder = 0
    
    gameNode.addChildNode(node)
}

func drawPaddle(gameNode:SCNNode,Name:String,Material:SCNMaterial,Paddle:SCNBox,Opacity:CGFloat,X:Float,Y:Float,Z:Float) {
    let node = SCNNode(geometry: Paddle)
    node.position.y = node.position.y + Y
    node.position.x = node.position.x + X
    node.position.z = node.position.z + Z
    
    let boxShape = SCNPhysicsShape(geometry: Paddle,
                                   options: [SCNPhysicsShape.Option(rawValue: SCNPhysicsShape.Option.scale.rawValue) : gScale])
    
    
    let physicsbody = SCNPhysicsBody(type: .static, shape: boxShape)
    node.physicsBody = physicsbody
    node.physicsBody?.categoryBitMask = paddleCategory
    node.physicsBody?.collisionBitMask = ballCategory + paddleCategory
    node.physicsBody?.contactTestBitMask = ballCategory + paddleCategory
    node.geometry?.firstMaterial = Material
    node.opacity = Opacity
    node.name = Name
    virtualstick = node
    node.renderingOrder = 0
    
    gameNode.addChildNode(node)
}

func drawSides(gameNode:SCNNode,Name:String,Material:SCNMaterial,Box:SCNBox,Opacity:CGFloat,X:Float,Y:Float,Z:Float) {
    let node = SCNNode(geometry: Box)
    node.position.y = node.position.y + Y
    node.position.x = node.position.x + X
    node.position.z = node.position.z + Z
    
    let boxShape = SCNPhysicsShape(geometry: Box,
                                   options: [SCNPhysicsShape.Option(rawValue: SCNPhysicsShape.Option.scale.rawValue) : gScale])
    
    let physicsbody = SCNPhysicsBody(type: .kinematic, shape: boxShape)
    node.physicsBody = physicsbody
    node.physicsBody?.categoryBitMask = wallCategory
    node.physicsBody?.collisionBitMask = ballCategory
    node.physicsBody?.contactTestBitMask = ballCategory
    node.geometry?.firstMaterial = Material
    node.opacity = Opacity
    node.name = Name
    node.renderingOrder = 0
    gameNode.addChildNode(node)
    
    node.physicsBody?.restitution = 0.7
    
    if Name == "back" {
        
        let scoreMaterial = SCNMaterial()
        scoreMaterial.diffuse.contents = UIColor.orange
        var scoreNode = SCNNode()
        
        //Init Score Label
        score = SCNText(string: "0", extrusionDepth: 0.15 / 2)
        score.flatness = 100
        score.isWrapped = true
        scoreNode = SCNNode(geometry: score)
        scoreNode.geometry?.firstMaterial = scoreMaterial
        
        score.font = UIFont(name: "Arcade Normal", size: 0.15)
        score.chamferRadius = 0.00
        score.containerFrame = CGRect(origin: CGPoint(x:-gWidth/2,y:0.3), size: CGSize(width: gWidth, height: 0.3))
        score.truncationMode = convertFromCATextLayerTruncationMode(CATextLayerTruncationMode.none)
        score.alignmentMode = convertFromCATextLayerAlignmentMode(CATextLayerAlignmentMode.center)
        
        scoreNode.renderingOrder = 0
        node.parent?.addChildNode(scoreNode)
        
    }
}

func drawGeo(gameNode:SCNNode,Name:String,Material:SCNMaterial,Geo:SCNCylinder,Opacity:CGFloat,X:Float,Y:Float,Z:Float) {
    let node = SCNNode(geometry: Geo)
    node.position.y = node.position.y + Y
    node.position.x = node.position.x + X
    node.position.z = node.position.z + Z
    
    let shape = SCNPhysicsShape(geometry: Geo,
                                options: [SCNPhysicsShape.Option(rawValue: SCNPhysicsShape.Option.scale.rawValue) : gScale])
    
    let physicsbody = SCNPhysicsBody(type: .kinematic, shape: shape)
    node.physicsBody = physicsbody
    node.physicsBody?.categoryBitMask = wallCategory
    node.physicsBody?.collisionBitMask = ballCategory
    node.physicsBody?.contactTestBitMask = ballCategory
    node.geometry?.firstMaterial = Material
    node.opacity = Opacity
    node.name = Name
    node.renderingOrder = 0
    
    gameNode.addChildNode(node)
}

func drawBrix(gameNode:SCNNode,Name:String,Material:[SCNMaterial],Brix:SCNBox,Opacity:CGFloat,X:Float,Y:Float,Z:Float) {
    
    let node = SCNNode(geometry: Brix)
    node.position.y = node.position.y + Y
    node.position.x = node.position.x + X
    node.position.z = node.position.z + Z
    
    let boxShape = SCNPhysicsShape(geometry: Brix,
                                   options: [SCNPhysicsShape.Option(rawValue: SCNPhysicsShape.Option.scale.rawValue) : gScale])
    
    let physicsbody = SCNPhysicsBody(type: .kinematic, shape: boxShape)
    node.physicsBody = physicsbody
    node.physicsBody?.categoryBitMask = brixCategory
    node.physicsBody?.allowsResting = false
    node.geometry?.materials = Material
    node.opacity = Opacity
    node.name = Name
    node.physicsBody?.restitution = 0.7
    
    node.renderingOrder = 0
    
    gameNode.addChildNode(node)
}

func drawSphere(gameNode:SCNNode,Name:String,Material:SCNMaterial,Sphere:SCNSphere,Opacity:CGFloat,X:Float,Y:Float,Z:Float) {
    
    let node = SCNNode(geometry: Sphere)
    node.position.y = node.position.y + Y
    node.position.x = node.position.x + X
    node.position.z = node.position.z + Z
    
    //to this:
    let sphereShape
    = SCNPhysicsShape(geometry: Sphere, options: [SCNPhysicsShape.Option(rawValue: SCNPhysicsShape.Option.scale.rawValue) : gScale])
    
    let physicsbody = SCNPhysicsBody(type: .dynamic, shape: sphereShape )
    
    node.physicsBody = physicsbody
    node.physicsBody?.categoryBitMask = ballCategory
    node.physicsBody?.contactTestBitMask = ballCategory + gridCategory + wallCategory + brixCategory + paddleCategory
    node.physicsBody?.collisionBitMask = ballCategory + wallCategory + brixCategory + paddleCategory
    node.geometry?.firstMaterial = Material
    node.opacity = Opacity
    
    node.name = Name
    node.physicsBody?.allowsResting = false
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        node.physicsBody?.applyForce(SCNVector3(x: -0.5, y: -1, z: -0.5), asImpulse: true)
        node.physicsBody?.restitution = 0.6
        node.castsShadow = true
        gameNode.addChildNode(node)
    }
}

// This maps are colors / images 
func map(images: [UIImage]) -> [SCNMaterial] {
    let materials = images.map { images -> SCNMaterial in
        let material = SCNMaterial()
        material.diffuse.contents = images
        material.locksAmbientWithDiffuse = true
        return material
    }
    return materials
}

func cropImageToSquare(image: UIImage) -> UIImage? {
    var imageHeight = image.size.height
    var imageWidth = image.size.width
    
    if imageHeight > imageWidth {
        imageHeight = imageWidth
    }
    else {
        imageWidth = imageHeight
    }
    
    let size = CGSize(width: imageWidth, height: imageHeight)
    
    let refWidth : CGFloat = CGFloat(image.cgImage!.width)
    let refHeight : CGFloat = CGFloat(image.cgImage!.height)
    
    let x = (refWidth - size.width) / 2
    let y = (refHeight - size.height) / 2
    
    let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
    if let imageRef = image.cgImage!.cropping(to: cropRect) {
        return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
    } else {
        return image //if it fails return our image
    }
    
}

/// Slice image into array of tiles
func splitImage(portraitSnapshot: UIImage, row : Int , column : Int) -> [[UIImage]]{
    
    //Square up the image
    let snapshot = cropImageToSquare(image: portraitSnapshot)!
    
    let height =  (snapshot.size.height) /  CGFloat (row) //height of each image tile
    let width =  (snapshot.size.width)  / CGFloat (column)  //width of each image tile
    
    let scale = (snapshot.scale) //scale conversion factor is needed as UIImage make use of "points" whereas CGImage use pixels.
    
    var imageArr = [[UIImage]]() // will contain small pieces of image
    for y in 0..<row{
        var yArr = [UIImage]()
        for x in 0..<column{
            
            UIGraphicsBeginImageContextWithOptions(
                CGSize(width:width, height:height),
                false, 0)
            let i =  snapshot.cgImage?.cropping(to:  CGRect.init(x: CGFloat(x) * width * scale, y:  CGFloat(y) * height * scale  , width: width * scale  , height: height * scale) )
            
            let newImg = UIImage.init(cgImage: i!)
            
            yArr.append(newImg)
            
            UIGraphicsEndImageContext();
            
        }
        
        imageArr.append(yArr)
    }
    return imageArr
}

//Turn the touch on
func toggleTorch(on: Bool) {
    guard let device = AVCaptureDevice.default(for: AVMediaType.video)
    else {return}
    
    if device.hasTorch {
        do {
            try device.lockForConfiguration()
            
            if on == true {
                device.torchMode = .on // set on
            } else {
                device.torchMode = .off // set off
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    } else {
        print("Torch is not available")
    }
}

func drawManyBrix(slicedImages: [[UIImage]]) {
    //DrawBrix
    ///Back Set
    var materials: [[SCNMaterial]] = []
    
    typealias Patterns = [(front: Int, right: Int, back: Int, left: Int, top: Int, bottom: Int)]
    
    func imageSlicer(
        patterns: [(front: Int, right: Int, back: Int, left: Int, top: Int, bottom: Int)],
        front: Int, right: Int, back: Int, left: Int, top: Int, bottom: Int
    ) -> [[SCNMaterial]] {
        var mat = [[SCNMaterial]]()
        
        for pattern in patterns {
            let images = [
                slicedImages[front][pattern.front],
                slicedImages[right][pattern.right],
                slicedImages[back][pattern.back],
                slicedImages[left][pattern.left],
                slicedImages[top][pattern.top],
                slicedImages[bottom][pattern.bottom]
            ]
            
            let m = map(images: images)
            mat.append(m)
        }
        
        return mat
    }
    
    func faces(top: Int, bottom: Int, patterns: Patterns) {
        for i in 0...4 {
            let faceMaterials = imageSlicer(
                patterns: patterns,
                front: i,
                right: i,
                back: i,
                left: i,
                top: top,
                bottom: bottom
            )
            
            materials.append(contentsOf: faceMaterials)
        }
    }
    
    let patternsA: [(front: Int, right: Int, back: Int, left: Int, top: Int, bottom: Int)] = [
        (0, 4, 4, 0, 0, 0),
        (1, 4, 3, 0, 1, 1),
        (2, 4, 2, 0, 2, 2),
        (3, 4, 1, 0, 3, 3),
        (4, 4, 0, 0, 4, 4)
    ]
    
    faces(top: 0, bottom: 2, patterns: patternsA)
    
    let patternsB: [(front: Int, right: Int, back: Int, left: Int, top: Int, bottom: Int)] = [
        (0, 3, 4, 1, 0, 0),
        (1, 3, 3, 1, 1, 1),
        (2, 3, 2, 1, 2, 2),
        (3, 3, 1, 1, 3, 3),
        (4, 3, 0, 1, 4, 4)
    ]
    
    faces(top: 1, bottom: 3, patterns: patternsB)
    
    let patternsC: [(front: Int, right: Int, back: Int, left: Int, top: Int, bottom: Int)] = [
        (0, 2, 4, 2, 0, 0),
        (1, 2, 3, 2, 1, 1),
        (2, 2, 2, 2, 2, 2),
        (3, 2, 1, 2, 3, 3),
        (4, 2, 0, 2, 4, 4)
    ]
    
    faces(top: 2, bottom: 2, patterns: patternsC)
    
    let patternsD: [(front: Int, right: Int, back: Int, left: Int, top: Int, bottom: Int)] = [
        (0, 1, 4, 3, 0, 0),
        (1, 1, 3, 3, 1, 1),
        (2, 1, 2, 3, 2, 2),
        (3, 1, 1, 3, 3, 3),
        (4, 1, 0, 3, 4, 4)
    ]
    
    faces(top: 3, bottom: 1, patterns: patternsD)
    
    let patternsE: [(front: Int, right: Int, back: Int, left: Int, top: Int, bottom: Int)] = [
        (0, 0, 4, 4, 0, 0),
        (1, 0, 3, 4, 1, 1),
        (2, 0, 2, 4, 2, 2),
        (3, 0, 1, 4, 3, 3),
        (4, 0, 0, 4, 4, 4)
    ]
    
    faces(top: 4, bottom: 0, patterns: patternsE)
    
    func generateBlocks() -> [(x: Double, y: Double, z: Double)] {
        let X = stride(from: -0.25, through: 0.25, by:  0.125).map {  $0 }
        let Y = stride(from:  0.25, through: -0.25, by: -0.125).map { $0 }
        let Z = stride(from: -0.5, through:  0.0, by:   0.125).map {  $0 }
        
        let blocks = Z.flatMap { z in
            Y.flatMap { y in
                X.map { x in
                    (x, y, z)
                }
            }
        }
        
        return blocks
    }
    
    let blocks = generateBlocks()
    
    brixCount = materials.count
    
    for (index, coords) in blocks.enumerated() {
        let brix = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        let opacity = CGFloat(1.0)
        let name = String("brix")
        let x = Float(coords.x)
        let y = Float(coords.y)
        let z = Float(coords.z)
        
        drawBrix(gameNode: cubeNode, Name: name, Material: materials[index], Brix: brix, Opacity: opacity, X: x, Y: y, Z: z)
    }
    
    restartLevel = true
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerTruncationMode(_ input: CATextLayerTruncationMode) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerAlignmentMode(_ input: CATextLayerAlignmentMode) -> String {
    return input.rawValue
}
