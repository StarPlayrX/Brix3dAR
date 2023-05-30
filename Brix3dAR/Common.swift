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
   
    
    let zGrid = CGFloat(gDepth / 1.75)
    
    let gridZone : Array<(x:CGFloat,y:CGFloat,z:CGFloat)> = [
        (x: -gWidth / 3, y: gHeight / 3,  z: zGrid),
        (x: 0,           y: gHeight / 3,  z: zGrid),
        (x: gWidth / 3,  y: gHeight / 3,  z: zGrid),
        (x: -gWidth / 3, y: 0,            z: zGrid),
        (x: 0,           y: 0,            z: zGrid),
        (x: gWidth / 3,  y: 0,            z: zGrid),
        (x: -gWidth / 3, y: -gHeight / 3, z: zGrid),
        (x: 0,           y: -gHeight / 3, z: zGrid),
        (x: gWidth / 3,  y: -gHeight / 3, z: zGrid),
    ]
    
    for grid in gridZone {
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIColor.magenta
        let gridPlane = SCNPlane(width: gWidth / 3, height: gHeight / 3)
        let opacity = CGFloat(0.0)
        let name = String("grid")
        let x = grid.x
        let y = grid.y
        let z = grid.z
        drawPlane(gameNode: gamenode,
                  Name: name,
                  Material: gridMaterial,
                  Plane: gridPlane,
                  Opacity: opacity, X: Float(x), Y: Float(y), Z: Float(z), Type: 1)
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
        //node.geometry?.firstMaterial?.reflective.contents = Material.emission
        //let wait = SCNAction.wait(duration: 0.5)
        // let rotation = SCNAction.rotateBy(x: .pi, y: .pi, z: .pi, duration: 6)
        //let moveblocks = SCNAction.moveBy(x: 0, y: 0, z: 0, duration: 2)
        // let moveblocks = SCNAction.moveBy(x: 0, y: -0.15, z: 1.0, duration: 1.5)

        //let actionSequence = SCNAction.sequence([wait,moveblocks])
        // node.runAction(actionSequence)

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
    let images1a = [
        slicedImages[0][0], //front
        slicedImages[0][4], //right
        slicedImages[0][4], //back
        slicedImages[0][0], //left
        slicedImages[0][0], //top
        slicedImages[2][0], //bottom
    ]
    let materials1a = map(images: images1a)
    
    let images2a = [
        slicedImages[0][1], //front
        slicedImages[0][4], //right
        slicedImages[0][3], //back 
        slicedImages[0][0], //left
        slicedImages[0][1], //top
        slicedImages[2][1], //bottom
    ]
    let materials2a = map(images: images2a)
    
    let images3a = [
        slicedImages[0][2], //front
        slicedImages[0][4], //right
        slicedImages[0][2], //back
        slicedImages[0][0], //left
        slicedImages[0][2], //top
        slicedImages[2][2]  //bottom
    ]
    let materials3a = map(images: images3a)
    
    //4a
    let images4a = [
        slicedImages[0][3], //front
        slicedImages[0][4], //right
        slicedImages[0][1], //back
        slicedImages[0][0], //left
        slicedImages[0][3], //top
        slicedImages[2][3]  //bottom
    ]
    let materials4a = map(images: images4a)
    
    //5a
    let images5a = [
        slicedImages[0][4], //front
        slicedImages[0][4], //right
        slicedImages[0][0], //back
        slicedImages[0][0], //left
        slicedImages[0][4], //top
        slicedImages[2][4]  //bottom
    ]
    let materials5a = map(images: images5a)
    
    
    
    let images1b = [
        slicedImages[1][0], //front
        slicedImages[1][4], //right
        slicedImages[1][4], //back 
        slicedImages[1][0], //left
        slicedImages[0][0], //top
        slicedImages[2][0]  //bottom
    ]
    let materials1b = map(images: images1b)
    
    let images2b = [
        slicedImages[1][1], //front
        slicedImages[1][4], //right
        slicedImages[1][3], //back 
        slicedImages[1][0], //left
        slicedImages[0][1], //top
        slicedImages[2][1], //bottom
    ]
    let materials2b = map(images: images2b)
    
    let images3b = [
        slicedImages[1][2], //front
        slicedImages[1][4], //right
        slicedImages[1][2], //back 
        slicedImages[1][0], //left
        slicedImages[0][2], //top
        slicedImages[2][2]  //bottom
    ]
    let materials3b = map(images: images3b)
    
    
    //4b
    let images4b = [
        slicedImages[1][3], //front
        slicedImages[1][4], //right
        slicedImages[1][1], //back 
        slicedImages[1][0], //left
        slicedImages[0][3], //top
        slicedImages[2][3]  //bottom
    ]
    let materials4b = map(images: images4b)
    
    //5b
    let images5b = [
        slicedImages[1][4], //front
        slicedImages[1][4], //right
        slicedImages[1][0], //back 
        slicedImages[1][0], //left
        slicedImages[0][4], //top
        slicedImages[2][4]  //bottom
    ]
    let materials5b = map(images: images5b)
    
    
    let images1c = [
        slicedImages[2][0], //front
        slicedImages[2][4], //right
        slicedImages[2][4], //back 
        slicedImages[2][0], //left
        slicedImages[0][0], //top
        slicedImages[2][0]  //bottom
    ]
    let materials1c = map(images: images1c)
    
    let images2c = [
        slicedImages[2][1], //front
        slicedImages[2][4], //right
        slicedImages[2][3], //back 
        slicedImages[2][0], //left
        slicedImages[0][1], //top
        slicedImages[2][1]  //bottom
    ]
    
    let materials2c = map(images: images2c)
    
    let images3c = [
        slicedImages[2][2], //front
        slicedImages[2][4], //right
        slicedImages[2][2], //back 
        slicedImages[2][0], //left
        slicedImages[0][2], //top
        slicedImages[2][2]  //bottom
    ]
    let materials3c = map(images: images3c)
    
    
    //4c
    let images4c = [
        slicedImages[2][3], //front
        slicedImages[2][4], //right
        slicedImages[2][1], //back 
        slicedImages[2][0], //left
        slicedImages[0][3], //top
        slicedImages[2][3]  //bottom
    ]
    let materials4c = map(images: images4c)
    
    //5c
    let images5c = [
        slicedImages[2][4], //front
        slicedImages[2][4], //right
        slicedImages[2][0], //back 
        slicedImages[2][0], //left
        slicedImages[0][4], //top
        slicedImages[2][4]  //bottom
    ]
    let materials5c = map(images: images5c)
    
    
    //x 1-4
    let images1x = [
        slicedImages[3][0], //front
        slicedImages[3][4], //right
        slicedImages[3][4], //back 
        slicedImages[3][0], //left
        slicedImages[0][0], //top
        slicedImages[3][0]  //bottom
    ]
    let materials1x = map(images: images1x)
    
    
    let images2x = [
        slicedImages[3][1], //front
        slicedImages[3][4], //right
        slicedImages[3][3], //back 
        slicedImages[3][0], //left
        slicedImages[0][1], //top
        slicedImages[3][1]  //bottom
    ]
    let materials2x = map(images: images2x)
    
    let images3x = [
        slicedImages[3][2], //front
        slicedImages[3][4], //right
        slicedImages[3][2], //back 
        slicedImages[3][0], //left
        slicedImages[0][2], //top
        slicedImages[3][2]  //bottom
    ]
    let materials3x = map(images: images3x)
    
    let images4x = [
        slicedImages[3][3], //front
        slicedImages[3][4], //right
        slicedImages[3][1], //back 
        slicedImages[3][0], //left
        slicedImages[0][3], //top
        slicedImages[3][3]  //bottom
    ]
    let materials4x = map(images: images4x)
    
    
    let images5x = [
        slicedImages[3][4], //front
        slicedImages[3][4], //right
        slicedImages[3][0], //back 
        slicedImages[3][0], //left
        slicedImages[0][4], //top
        slicedImages[3][4]  //bottom
    ]
    let materials5x = map(images: images5x)
    
    
    
    //x5 1-4
    let images1x5 = [
        slicedImages[4][0], //front
        slicedImages[4][4], //right
        slicedImages[4][4], //back 
        slicedImages[4][0], //left
        slicedImages[0][0], //top
        slicedImages[4][0]  //bottom
    ]
    let materials1x5 = map(images: images1x5)
    
    
    let images2x5 = [
        slicedImages[4][1], //front
        slicedImages[4][4], //right
        slicedImages[4][3], //back 
        slicedImages[4][0], //left
        slicedImages[0][1], //top
        slicedImages[4][1]  //bottom
    ]
    let materials2x5 = map(images: images2x5)
    
    let images3x5 = [
        slicedImages[4][2], //front
        slicedImages[4][4], //right
        slicedImages[4][2], //back 
        slicedImages[4][0], //left
        slicedImages[0][2], //top
        slicedImages[4][2]  //bottom
    ]
    let materials3x5 = map(images: images3x5)
    
    let images4x5 = [
        slicedImages[4][3], //front
        slicedImages[4][4], //right
        slicedImages[4][1], //back 
        slicedImages[4][0], //left
        slicedImages[0][3], //top
        slicedImages[4][3]  //bottom
    ]
    let materials4x5 = map(images: images4x5)
    
    
    let images5x5 = [
        slicedImages[4][4], //front
        slicedImages[4][4], //right
        slicedImages[4][0], //back 
        slicedImages[4][0], //left
        slicedImages[0][4], //top
        slicedImages[4][4]  //bottom
    ]
    let materials5x5 = map(images: images5x5)
    
    
    
    // second set
    let images1d = [
        slicedImages[0][0], //front
        slicedImages[0][3], //right
        slicedImages[0][4], //back 
        slicedImages[0][1], //left
        slicedImages[1][0], //top
        slicedImages[3][0]  //bottom
    ]
    let materials1d = map(images: images1d)
    
    let images2d = [
        slicedImages[0][1], //front
        slicedImages[0][3], //right
        slicedImages[0][3], //back 
        slicedImages[0][1], //left
        slicedImages[1][1], //top
        slicedImages[3][1]  //bottom
    ]
    let materials2d = map(images: images2d)
    
    let images3d = [
        slicedImages[0][2], //front
        slicedImages[0][3], //right
        slicedImages[0][2], //back 
        slicedImages[0][1], //left
        slicedImages[1][2], //top
        slicedImages[3][2]  //bottom
    ]
    let materials3d = map(images: images3d)
    
    //4d
    let images4d = [
        slicedImages[0][3], //front
        slicedImages[0][3], //right
        slicedImages[0][1], //back 
        slicedImages[0][1], //left
        slicedImages[1][3], //top
        slicedImages[3][3]  //bottom
    ]
    let materials4d = map(images: images4d)
    
    //5d
    let images5d = [
        slicedImages[0][4], //front
        slicedImages[0][3], //right
        slicedImages[0][0], //back 
        slicedImages[0][1], //left
        slicedImages[1][4], //top
        slicedImages[3][4]  //bottom
    ]
    let materials5d = map(images: images5d)
    
    
    
    let images1e = [
        slicedImages[1][0], //front
        slicedImages[1][3], //right
        slicedImages[1][4], //back 
        slicedImages[1][1], //left
        slicedImages[1][0], //top
        slicedImages[3][0]  //bottom
    ]
    let materials1e = map(images: images1e)
    
    
    let images2e = [
        slicedImages[1][1], //front
        slicedImages[1][3], //right
        slicedImages[1][3], //back
        slicedImages[1][1], //left
        slicedImages[1][1], //top
        slicedImages[3][1]  //bottom
    ]
    let materials2e = map(images: images2e)
    
    
    let images3e = [
        slicedImages[1][2], //front
        slicedImages[1][3], //right
        slicedImages[1][2], //back 
        slicedImages[1][1], //left
        slicedImages[1][2], //top
        slicedImages[3][2], //bottom
    ]
    let materials3e = map(images: images3e)
    
    
    //4e
    let images4e = [
        slicedImages[1][3], //front
        slicedImages[1][3], //right
        slicedImages[1][1], //back 
        slicedImages[1][1], //left
        slicedImages[1][3], //top
        slicedImages[3][3], //bottom
    ]
    let materials4e = map(images: images4e)
    
    
    //5e
    let images5e = [
        slicedImages[1][4], //front
        slicedImages[1][3], //right
        slicedImages[1][0], //back 
        slicedImages[1][1], //left
        slicedImages[1][4], //top
        slicedImages[3][4], //bottom
    ]
    let materials5e = map(images: images5e)
    
    
    
    let images1f = [
        slicedImages[2][0], //front
        slicedImages[2][3], //right
        slicedImages[2][4], //back 
        slicedImages[2][1], //left
        slicedImages[1][0], //top
        slicedImages[3][0]  //bottom
    ]
    let materials1f = map(images: images1f)
    
    let images2f = [
        slicedImages[2][1], //front
        slicedImages[2][3], //right
        slicedImages[2][3], //back 
        slicedImages[2][1], //left
        slicedImages[1][1], //top
        slicedImages[3][1]  //bottom
    ]
    let materials2f = map(images: images2f)
    
    let images3f = [
        slicedImages[2][2], //front
        slicedImages[2][3], //right
        slicedImages[2][2], //back 
        slicedImages[2][1], //left
        slicedImages[1][2], //top
        slicedImages[3][2], //bottom
    ]
    let materials3f = map(images: images3f)
    
    
    //4f
    let images4f = [
        slicedImages[2][3], //front
        slicedImages[2][3], //right
        slicedImages[2][1], //back 
        slicedImages[2][1], //left
        slicedImages[1][3], //top
        slicedImages[3][3], //bottom
    ]
    let materials4f = map(images: images4f)
    
    
    //5f
    let images5f = [
        slicedImages[2][4], //front
        slicedImages[2][3], //right
        slicedImages[2][0], //back 
        slicedImages[2][1], //left
        slicedImages[1][4], //top
        slicedImages[3][4], //bottom
    ]
    let materials5f = map(images: images5f)
    
    
    //y 1-4
    let images1y = [
        slicedImages[3][0], //front
        slicedImages[3][3], //right
        slicedImages[3][4], //back 
        slicedImages[3][1], //left
        slicedImages[1][0], //top
        slicedImages[3][0]  //bottom
    ]
    let materials1y = map(images: images1y)
    
    let images2y = [
        slicedImages[3][1], //front
        slicedImages[3][3], //right
        slicedImages[3][3], //back 
        slicedImages[3][1], //left
        slicedImages[1][1], //top
        slicedImages[3][1]  //bottom
    ]
    let materials2y = map(images: images2y)
    
    let images3y = [
        slicedImages[3][2], //front
        slicedImages[3][3], //right
        slicedImages[3][2], //back 
        slicedImages[3][1], //left
        slicedImages[1][2], //top
        slicedImages[3][2], //bottom
    ]
    let materials3y = map(images: images3y)
    
    let images4y = [
        slicedImages[3][3], //front
        slicedImages[3][3], //right
        slicedImages[3][1], //back 
        slicedImages[3][1], //left
        slicedImages[1][3], //top
        slicedImages[3][3], //bottom
    ]
    let materials4y = map(images: images4y)
    
    
    let images5y = [
        slicedImages[3][4], //front
        slicedImages[3][3], //right
        slicedImages[3][0], //back 
        slicedImages[3][1], //left
        slicedImages[1][4], //top
        slicedImages[3][4], //bottom
    ]
    let materials5y = map(images: images5y)
    
    
    
    //y5 1-4
    let images1y5 = [
        slicedImages[4][0], //front
        slicedImages[4][3], //right
        slicedImages[4][4], //back 
        slicedImages[4][1], //left
        slicedImages[1][0], //top
        slicedImages[3][0]  //bottom
    ]
    let materials1y5 = map(images: images1y5)
    
    let images2y5 = [
        slicedImages[4][1], //front
        slicedImages[4][3], //right
        slicedImages[4][3], //back 
        slicedImages[4][1], //left
        slicedImages[1][1], //top
        slicedImages[3][1]  //bottom
    ]
    let materials2y5 = map(images: images2y5)
    
    let images3y5 = [
        slicedImages[4][2], //front
        slicedImages[4][3], //right
        slicedImages[4][2], //back 
        slicedImages[4][1], //left
        slicedImages[1][2], //top
        slicedImages[3][2], //bottom
    ]
    let materials3y5 = map(images: images3y5)
    
    let images4y5 = [
        slicedImages[4][3], //front
        slicedImages[4][3], //right
        slicedImages[4][1], //back 
        slicedImages[4][1], //left
        slicedImages[1][3], //top
        slicedImages[3][3], //bottom
    ]
    let materials4y5 = map(images: images4y5)
    
    
    let images5y5 = [
        slicedImages[3][4], //front
        slicedImages[4][3], //right
        slicedImages[3][0], //back 
        slicedImages[3][1], //left
        slicedImages[1][4], //top
        slicedImages[3][4], //bottom
    ]
    let materials5y5 = map(images: images5y5)
    
    
    
    
    //front set
    let images1g = [
        slicedImages[0][0], //front
        slicedImages[0][2], //right
        slicedImages[0][4], //back 
        slicedImages[0][2], //left
        slicedImages[2][0], //top
        slicedImages[2][0], //bottom
    ]
    let materials1g = map(images: images1g)
    
    let images2g = [
        slicedImages[0][1], //front
        slicedImages[0][2], //right
        slicedImages[0][3], //back 
        slicedImages[0][2], //left
        slicedImages[2][1], //top
        slicedImages[2][1]  //bottom
    ]
    let materials2g = map(images: images2g)
    
    let images3g = [
        slicedImages[0][2], //front
        slicedImages[0][2], //right
        slicedImages[0][2], //back 
        slicedImages[0][2], //left
        slicedImages[2][2], //top
        slicedImages[2][2]  //bottom
    ]
    let materials3g = map(images: images3g)
    
    
    //4g
    let images4g = [
        slicedImages[0][3], //front
        slicedImages[0][2], //right
        slicedImages[0][1], //back 
        slicedImages[0][2], //left
        slicedImages[2][3], //top
        slicedImages[2][3]  //bottom
    ]
    let materials4g = map(images: images4g)
    
    
    
    //5g
    let images5g = [
        slicedImages[0][4], //front
        slicedImages[0][2], //right
        slicedImages[0][0], //back 
        slicedImages[0][2], //left
        slicedImages[2][4], //top
        slicedImages[2][4]  //bottom
    ]
    let materials5g = map(images: images5g)
    
    
    
    let images1h = [
        slicedImages[1][0], //front
        slicedImages[1][2], //right
        slicedImages[1][4], //back 
        slicedImages[1][2], //left
        slicedImages[2][0], //top
        slicedImages[2][0]  //bottom
    ]
    let materials1h = map(images: images1h)
    
    let images2h = [
        slicedImages[1][1], //front
        slicedImages[1][2], //right
        slicedImages[1][3], //back 
        slicedImages[1][2], //left
        slicedImages[2][1], //top
        slicedImages[2][1]  //bottom
    ]
    let materials2h = map(images: images2h)
    
    
    let images3h = [
        slicedImages[1][2], //front
        slicedImages[1][2], //right
        slicedImages[1][2], //back 
        slicedImages[1][2], //left
        slicedImages[2][2], //top
        slicedImages[2][2]  //bottom
    ]
    let materials3h = map(images: images3h)
    
    
    //4h
    let images4h = [
        slicedImages[1][3], //front
        slicedImages[1][2], //right
        slicedImages[1][1], //back 
        slicedImages[1][2], //left
        slicedImages[2][3], //top
        slicedImages[2][3]  //bottom
    ]
    let materials4h = map(images: images4h)
    
    
    //5h
    let images5h = [
        slicedImages[1][4], //front
        slicedImages[1][2], //right
        slicedImages[1][0], //back 
        slicedImages[2][2], //left
        slicedImages[2][4], //top
        slicedImages[2][4]  //bottom
    ]
    let materials5h = map(images: images5h)
    
    
    let images1i = [
        slicedImages[2][0], //front
        slicedImages[2][2], //right
        slicedImages[2][4], //back 
        slicedImages[2][2], //left
        slicedImages[2][0], //top
        slicedImages[2][0]  //bottom
    ]
    let materials1i = map(images: images1i)
    
    let images2i = [
        slicedImages[2][1], //front
        slicedImages[2][2], //right
        slicedImages[2][3], //back 
        slicedImages[2][2], //left
        slicedImages[2][1], //top
        slicedImages[2][1]  //bottom
    ]
    let materials2i = map(images: images2i)
    
    
    let images3i = [
        slicedImages[2][2], //front
        slicedImages[2][2], //right
        slicedImages[2][2], //back 
        slicedImages[2][2], //left
        slicedImages[2][2], //top
        slicedImages[2][2]  //bottom
    ]
    let materials3i = map(images: images3i)
    
    
    //4i
    let images4i = [
        slicedImages[2][3], //front
        slicedImages[2][2], //right
        slicedImages[2][1], //back 
        slicedImages[2][2], //left
        slicedImages[2][3], //top
        slicedImages[2][3]  //bottom
    ]
    let materials4i = map(images: images4i)
    
    
    
    //5i
    let images5i = [
        slicedImages[2][4], //front
        slicedImages[2][2], //right
        slicedImages[2][0], //back 
        slicedImages[2][2], //left
        slicedImages[2][4], //top
        slicedImages[2][4]  //bottom
    ]
    let materials5i = map(images: images5i)
    
    
    //z 1-4
    let images1z = [
        slicedImages[3][0], //front
        slicedImages[3][2], //right
        slicedImages[3][4], //back 
        slicedImages[3][2], //left
        slicedImages[2][0], //top
        slicedImages[2][0]  //bottom
    ]
    let materials1z = map(images: images1z)
    
    let images2z = [
        slicedImages[3][1], //front
        slicedImages[3][2], //right
        slicedImages[3][3], //back 
        slicedImages[3][2], //left
        slicedImages[2][1], //top
        slicedImages[2][1]  //bottom
    ]
    let materials2z = map(images: images2z)
    
    
    let images3z = [
        slicedImages[3][2], //front
        slicedImages[3][2], //right
        slicedImages[3][2], //back 
        slicedImages[3][2], //left
        slicedImages[2][2], //top
        slicedImages[2][2]  //bottom
    ]
    let materials3z = map(images: images3z)
    
    
    //4z
    let images4z = [
        slicedImages[3][3], //front
        slicedImages[3][2], //right
        slicedImages[3][1], //back 
        slicedImages[3][2], //left
        slicedImages[2][3], //top
        slicedImages[2][3]  //bottom
    ]
    let materials4z = map(images: images4z)
    
    
    //5z
    let images5z = [
        slicedImages[3][4], //front
        slicedImages[3][2], //right
        slicedImages[3][0], //back 
        slicedImages[3][2], //left
        slicedImages[2][4], //top
        slicedImages[2][4]  //bottom
    ]
    let materials5z = map(images: images5z)
    
    
    
    //z 1-4
    let images1z5 = [
        slicedImages[4][0], //front
        slicedImages[4][2], //right
        slicedImages[4][4], //back 
        slicedImages[4][2], //left
        slicedImages[2][0], //top
        slicedImages[2][0]  //bottom
    ]
    let materials1z5 = map(images: images1z5)
    
    let images2z5 = [
        slicedImages[4][1], //front
        slicedImages[4][2], //right
        slicedImages[4][3], //back 
        slicedImages[4][2], //left
        slicedImages[2][1], //top
        slicedImages[2][1]  //bottom
    ]
    let materials2z5 = map(images: images2z5)
    
    
    let images3z5 = [
        slicedImages[4][2], //front
        slicedImages[4][2], //right
        slicedImages[4][2], //back 
        slicedImages[4][2], //left
        slicedImages[2][2], //top
        slicedImages[2][2]  //bottom
    ]
    let materials3z5 = map(images: images3z5)
    
    
    //4i
    let images4z5 = [
        slicedImages[4][3], //front
        slicedImages[4][2], //right
        slicedImages[4][1], //back 
        slicedImages[4][2], //left
        slicedImages[2][3], //top
        slicedImages[2][3]  //bottom
    ]
    let materials4z5 = map(images: images4z5)
    
    
    //5z
    let images5z5 = [
        slicedImages[4][4], //front
        slicedImages[4][2], //right
        slicedImages[4][0], //back 
        slicedImages[4][2], //left
        slicedImages[2][4], //top
        slicedImages[2][4]  //bottom
    ]
    let materials5z5 = map(images: images5z5)
    
    
    
    
    //1ga
    let images1ga = [
        slicedImages[0][0], //front
        slicedImages[0][1], //right
        slicedImages[0][4], //back 
        slicedImages[0][3], //left
        slicedImages[3][0], //top
        slicedImages[1][0], //bottom
    ]
    let materials1ga = map(images: images1ga)
    
    let images2ga = [
        slicedImages[0][1], //front
        slicedImages[0][1], //right
        slicedImages[0][3], //back 
        slicedImages[0][3], //left
        slicedImages[3][1], //top
        slicedImages[1][1]  //bottom
    ]
    let materials2ga = map(images: images2ga)
    
    let images3ga = [
        slicedImages[0][2], //front
        slicedImages[0][1], //right
        slicedImages[0][2], //back 
        slicedImages[0][3], //left
        slicedImages[3][2], //top
        slicedImages[1][2]  //bottom
    ]
    let materials3ga = map(images: images3ga)
    
    
    //4g
    let images4ga = [
        slicedImages[0][3], //front
        slicedImages[0][1], //right
        slicedImages[0][1], //back 
        slicedImages[0][3], //left
        slicedImages[3][3], //top
        slicedImages[1][3]  //bottom
    ]
    let materials4ga = map(images: images4ga)
    
    
    
    //5ga
    let images5ga = [
        slicedImages[0][4], //front
        slicedImages[0][1], //right
        slicedImages[0][0], //back 
        slicedImages[0][3], //left
        slicedImages[3][4], //top
        slicedImages[1][4]  //bottom
    ]
    let materials5ga = map(images: images5ga)
    
    
    
    let images1ha = [
        slicedImages[1][0], //front
        slicedImages[1][1], //right
        slicedImages[1][4], //back 
        slicedImages[1][3], //left
        slicedImages[3][0], //top
        slicedImages[1][0]  //bottom
    ]
    let materials1ha = map(images: images1ha)
    
    let images2ha = [
        slicedImages[1][1], //front
        slicedImages[1][1], //right
        slicedImages[1][3], //back 
        slicedImages[1][3], //left
        slicedImages[3][1], //top
        slicedImages[1][1]  //bottom
    ]
    let materials2ha = map(images: images2ha)
    
    
    let images3ha = [
        slicedImages[1][2], //front
        slicedImages[1][1], //right
        slicedImages[1][2], //back 
        slicedImages[1][3], //left
        slicedImages[3][2], //top
        slicedImages[1][2]  //bottom
    ]
    let materials3ha = map(images: images3ha)
    
    
    //4h
    let images4ha = [
        slicedImages[1][3], //front
        slicedImages[1][1], //right
        slicedImages[1][1], //back 
        slicedImages[1][3], //left
        slicedImages[3][3], //top
        slicedImages[1][3]  //bottom
    ]
    let materials4ha = map(images: images4ha)
    
    
    //5h
    let images5ha = [
        slicedImages[1][4], //front
        slicedImages[1][1], //right
        slicedImages[1][0], //back 
        slicedImages[1][3], //left
        slicedImages[3][4], //top
        slicedImages[1][4]  //bottom
    ]
    let materials5ha = map(images: images5ha)
    
    
    let images1ia = [
        slicedImages[2][0], //front
        slicedImages[2][1], //right
        slicedImages[2][4], //back 
        slicedImages[2][3], //left
        slicedImages[3][0], //top
        slicedImages[1][0]  //bottom
    ]
    let materials1ia = map(images: images1ia)
    
    let images2ia = [
        slicedImages[2][1], //front
        slicedImages[2][1], //right
        slicedImages[2][3], //back 
        slicedImages[2][3], //left
        slicedImages[3][1], //top
        slicedImages[1][1]  //bottom
    ]
    let materials2ia = map(images: images2ia)
    
    
    let images3ia = [
        slicedImages[2][2], //front
        slicedImages[2][1], //right
        slicedImages[2][2], //back 
        slicedImages[2][3], //left
        slicedImages[3][2], //top
        slicedImages[1][2]  //bottom
    ]
    let materials3ia = map(images: images3ia)
    
    
    //4ia
    let images4ia = [
        slicedImages[2][3], //front
        slicedImages[2][1], //right
        slicedImages[2][1], //back 
        slicedImages[2][3], //left
        slicedImages[3][3], //top
        slicedImages[1][3]  //bottom
    ]
    let materials4ia = map(images: images4ia)
    
    
    
    //5ia
    let images5ia = [
        slicedImages[2][4], //front
        slicedImages[2][1], //right
        slicedImages[2][0], //back 
        slicedImages[2][3], //left
        slicedImages[3][4], //top
        slicedImages[1][4]  //bottom
    ]
    let materials5ia = map(images: images5ia)
    
    
    //za 1-4
    let images1za = [
        slicedImages[3][0], //front
        slicedImages[3][1], //right
        slicedImages[3][4], //back 
        slicedImages[3][3], //left
        slicedImages[3][0], //top
        slicedImages[1][0]  //bottom
    ]
    let materials1za = map(images: images1za)
    
    let images2za = [
        slicedImages[3][1], //front
        slicedImages[3][1], //right
        slicedImages[3][3], //back 
        slicedImages[3][3], //left
        slicedImages[3][1], //top
        slicedImages[1][1]  //bottom
    ]
    let materials2za = map(images: images2za)
    
    
    let images3za = [
        slicedImages[3][2], //front
        slicedImages[3][1], //right
        slicedImages[3][2], //back 
        slicedImages[3][3], //left
        slicedImages[3][2], //top
        slicedImages[1][2]  //bottom
    ]
    let materials3za = map(images: images3za)
    
    
    //4z
    let images4za = [
        slicedImages[3][3], //front
        slicedImages[3][1], //right
        slicedImages[3][1], //back 
        slicedImages[3][3], //left
        slicedImages[3][3], //top
        slicedImages[1][3]  //bottom
    ]
    let materials4za = map(images: images4za)
    
    
    //5z
    let images5za = [
        slicedImages[3][4], //front
        slicedImages[3][1], //right
        slicedImages[3][0], //back 
        slicedImages[3][3], //left
        slicedImages[3][4], //top
        slicedImages[1][4]  //bottom
    ]
    let materials5za = map(images: images5za)
    
    
    
    //z 1-4
    let images1z5a = [
        slicedImages[4][0], //front
        slicedImages[4][1], //right
        slicedImages[4][4], //back 
        slicedImages[4][3], //left
        slicedImages[3][0], //top
        slicedImages[1][0]  //bottom
    ]
    let materials1z5a = map(images: images1z5a)
    
    let images2z5a = [
        slicedImages[4][1], //front
        slicedImages[4][1], //right
        slicedImages[4][3], //back 
        slicedImages[4][3], //left
        slicedImages[3][1], //top
        slicedImages[1][1]  //bottom
    ]
    let materials2z5a = map(images: images2z5a)
    
    
    let images3z5a = [
        slicedImages[4][2], //front
        slicedImages[4][1], //right
        slicedImages[4][2], //back 
        slicedImages[4][3], //left
        slicedImages[3][2], //top
        slicedImages[1][2]  //bottom
    ]
    let materials3z5a = map(images: images3z5a)
    
    
    //4i
    let images4z5a = [
        slicedImages[4][3], //front
        slicedImages[4][1], //right
        slicedImages[4][1], //back 
        slicedImages[4][3], //left
        slicedImages[3][3], //top
        slicedImages[1][3]  //bottom
    ]
    let materials4z5a = map(images: images4z5a)
    
    //5z5a
    let images5z5a = [
        slicedImages[4][4], //front
        slicedImages[4][1], //right
        slicedImages[4][0], //back 
        slicedImages[4][3], //left
        slicedImages[3][4], //top
        slicedImages[1][4]  //bottom
    ]
    let materials5z5a = map(images: images5z5a)
    
    //1gb
    let images1gb = [
        slicedImages[0][0], //front
        slicedImages[0][0], //right
        slicedImages[0][4], //back 
        slicedImages[0][4], //left
        slicedImages[4][0], //top
        slicedImages[0][0], //bottom
    ]
    let materials1gb = map(images: images1gb)
    
    let images2gb = [
        slicedImages[0][1], //front
        slicedImages[0][0], //right
        slicedImages[0][3], //back 
        slicedImages[0][4], //left
        slicedImages[4][1], //top
        slicedImages[0][1]  //bottom
    ]
    let materials2gb = map(images: images2gb)
    
    let images3gb = [
        slicedImages[0][2], //front
        slicedImages[0][0], //right
        slicedImages[0][2], //back 
        slicedImages[0][4], //left
        slicedImages[4][2], //top
        slicedImages[0][2]  //bottom
    ]
    let materials3gb = map(images: images3gb)
    
    
    //4g
    let images4gb = [
        slicedImages[0][3], //front
        slicedImages[0][0], //right
        slicedImages[0][1], //back 
        slicedImages[0][4], //left
        slicedImages[4][3], //top
        slicedImages[0][3]  //bottom
    ]
    let materials4gb = map(images: images4gb)
    
    
    //5ga
    let images5gb = [
        slicedImages[0][4], //front
        slicedImages[0][0], //right
        slicedImages[0][0], //back 
        slicedImages[0][4], //left
        slicedImages[4][4], //top
        slicedImages[0][4]  //bottom
    ]
    let materials5gb = map(images: images5gb)  //materials5ga
    
    
    
    let images1hb = [
        slicedImages[1][0], //front
        slicedImages[1][0], //right
        slicedImages[1][4], //back 
        slicedImages[1][4], //left
        slicedImages[4][0], //top
        slicedImages[0][0]  //bottom
    ]
    let materials1hb = map(images: images1hb)
    
    let images2hb = [
        slicedImages[1][1], //front
        slicedImages[1][0], //right
        slicedImages[1][3], //back 
        slicedImages[1][4], //left
        slicedImages[4][1], //top
        slicedImages[0][1]  //bottom
    ]
    let materials2hb = map(images: images2hb)
    
    
    let images3hb = [
        slicedImages[1][2], //front
        slicedImages[1][0], //right
        slicedImages[1][2], //back 
        slicedImages[1][4], //left
        slicedImages[4][2], //top
        slicedImages[0][2]  //bottom
    ]
    let materials3hb = map(images: images3hb)
    
    
    //4h
    let images4hb = [
        slicedImages[1][3], //front
        slicedImages[1][0], //right
        slicedImages[1][1], //back 
        slicedImages[1][4], //left
        slicedImages[4][3], //top
        slicedImages[0][3]  //bottom
    ]
    let materials4hb = map(images: images4hb)
    
    
    //5h
    let images5hb = [
        slicedImages[1][4], //front
        slicedImages[1][0], //right
        slicedImages[1][0], //back 
        slicedImages[1][4], //left
        slicedImages[4][4], //top
        slicedImages[0][4]  //bottom
    ]
    let materials5hb = map(images: images5hb)
    
    
    let images1ib = [
        slicedImages[2][0], //front
        slicedImages[2][0], //right
        slicedImages[2][4], //back 
        slicedImages[2][4], //left
        slicedImages[4][0], //top
        slicedImages[0][0]  //bottom
    ]
    let materials1ib = map(images: images1ib)
    
    let images2ib = [
        slicedImages[2][1], //front
        slicedImages[2][0], //right
        slicedImages[2][3], //back 
        slicedImages[2][4], //left
        slicedImages[4][1], //top
        slicedImages[0][1]  //bottom
    ]
    let materials2ib = map(images: images2ib)
    
    
    let images3ib = [
        slicedImages[2][2], //front
        slicedImages[2][0], //right
        slicedImages[2][2], //back 
        slicedImages[2][4], //left
        slicedImages[4][2], //top
        slicedImages[0][2]  //bottom
    ]
    let materials3ib = map(images: images3ib)
    
    
    //4ia
    let images4ib = [
        slicedImages[2][3], //front
        slicedImages[2][0], //right
        slicedImages[2][1], //back 
        slicedImages[2][4], //left
        slicedImages[4][3], //top
        slicedImages[0][3]  //bottom
    ]
    let materials4ib = map(images: images4ib)
    
    
    
    //5ia
    let images5ib = [
        slicedImages[2][4], //front
        slicedImages[2][0], //right
        slicedImages[2][0], //back 
        slicedImages[2][4], //left
        slicedImages[4][4], //top
        slicedImages[0][4]  //bottom
    ]
    let materials5ib = map(images: images5ib)
    
    
    //za 1-4
    let images1zb = [
        slicedImages[3][0], //front
        slicedImages[3][0], //right
        slicedImages[3][4], //back 
        slicedImages[3][4], //left
        slicedImages[4][0], //top
        slicedImages[0][0]  //bottom
    ]
    let materials1zb = map(images: images1zb)
    
    let images2zb = [
        slicedImages[3][1], //front
        slicedImages[3][0], //right
        slicedImages[3][3], //back 
        slicedImages[3][4], //left
        slicedImages[4][1], //top
        slicedImages[0][1]  //bottom
    ]
    let materials2zb = map(images: images2zb)
    
    
    let images3zb = [
        slicedImages[3][2], //front
        slicedImages[3][0], //right
        slicedImages[3][2], //back 
        slicedImages[3][4], //left
        slicedImages[4][2], //top
        slicedImages[0][2]  //bottom
    ]
    let materials3zb = map(images: images3zb)
    
    
    //4z
    let images4zb = [
        slicedImages[3][3], //front
        slicedImages[3][0], //right
        slicedImages[3][1], //back 
        slicedImages[3][4], //left
        slicedImages[4][3], //top
        slicedImages[0][3]  //bottom
    ]
    let materials4zb = map(images: images4zb)
    
    
    //5z
    let images5zb = [
        slicedImages[3][4], //front
        slicedImages[3][0], //right
        slicedImages[3][0], //back 
        slicedImages[3][4], //left
        slicedImages[4][4], //top
        slicedImages[0][4]  //bottom
    ]
    let materials5zb = map(images: images5zb)
    
    
    
    //z 1-4
    let images1z5b = [
        slicedImages[4][0], //front
        slicedImages[4][0], //right
        slicedImages[4][4], //back 
        slicedImages[4][4], //left
        slicedImages[4][0], //top
        slicedImages[0][0]  //bottom
    ]
    let materials1z5b = map(images: images1z5b)
    
    let images2z5b = [
        slicedImages[4][1], //front
        slicedImages[4][0], //right
        slicedImages[4][3], //back 
        slicedImages[4][4], //left
        slicedImages[4][1], //top
        slicedImages[0][1]  //bottom
    ]
    let materials2z5b = map(images: images2z5b)
    
    
    let images3z5b = [
        slicedImages[4][2], //front
        slicedImages[4][0], //right
        slicedImages[4][2], //back 
        slicedImages[4][4], //left
        slicedImages[4][2], //top
        slicedImages[0][2]  //bottom
    ]
    let materials3z5b = map(images: images3z5b)
    
    
    //4i
    let images4z5b = [
        slicedImages[4][3], //front
        slicedImages[4][0], //right
        slicedImages[4][1], //back 
        slicedImages[4][4], //left
        slicedImages[4][3], //top
        slicedImages[0][3]  //bottom
    ]
    let materials4z5b = map(images: images4z5b)
    
    
    //5z
    let images5z5b = [
        slicedImages[4][4], //front
        slicedImages[4][0], //right
        slicedImages[4][0], //back 
        slicedImages[4][4], //left
        slicedImages[4][4], //top
        slicedImages[0][4]  //bottom
    ]
    let materials5z5b = map(images: images5z5b)
    
    
    
    
    let back : Array<(x:Double,y:Double,z:Double)> = [
        (x:-0.25,y:0.250,z:-0.500),(x:-0.125,y:0.250,z:-0.500),(x:0,y:0.250,z:-0.500),(x:0.125,y:0.250,z:-0.500),(x:0.25,y:0.250,z:-0.500),
        (x:-0.25,y:0.125,z:-0.500),(x:-0.125,y:0.125,z:-0.500),(x:0,y:0.125,z:-0.500),(x:0.125,y:0.125,z:-0.500),(x:0.25,y:0.125,z:-0.500),
        (x:-0.25,y:0.000,z:-0.500),(x:-0.125,y:0.000,z:-0.500),(x:0,y:0.000,z:-0.500),(x:0.125,y:0.000,z:-0.500),(x:0.25,y:0.000,z:-0.500),
        (x:-0.25,y:-0.125,z:-0.500),(x:-0.125,y:-0.125,z:-0.500),(x:0,y:-0.125,z:-0.500),(x:0.125,y:-0.125,z:-0.500),(x:0.25,y:-0.125,z:-0.500),
        (x:-0.25,y:-0.250,z:-0.500),(x:-0.125,y:-0.250,z:-0.500),(x:0,y:-0.250,z:-0.500),(x:0.125,y:-0.250,z:-0.500),(x:0.25,y:-0.250,z:-0.500)
    ]
    
    let middle : Array<(x:Double,y:Double,z:Double)> = [
        (x:-0.25,y:0.2500,z:-0.375),(x:-0.125,y:0.2500,z:-0.375),(x:0,y:0.250,z:-0.375),(x:0.125,y:0.250,z:-0.375),(x:0.25,y:0.250,z:-0.375),
        (x:-0.25,y:0.1250,z:-0.375),(x:-0.125,y:0.1250,z:-0.375),(x:0,y:0.125,z:-0.375),(x:0.125,y:0.125,z:-0.375),(x:0.25,y:0.125,z:-0.375),
        (x:-0.25,y:0.0000,z:-0.375),(x:-0.125,y:0.0000,z:-0.375),(x:0,y:0.000,z:-0.375),(x:0.125,y:0.000,z:-0.375),(x:0.25,y:0.000,z:-0.375),
        (x:-0.25,y:-0.125,z:-0.375),(x:-0.125,y:-0.125,z:-0.375),(x:0,y:-0.125,z:-0.375),(x:0.125,y:-0.125,z:-0.375),(x:0.25,y:-0.125,z:-0.375),
        (x:-0.25,y:-0.250,z:-0.375),(x:-0.125,y:-0.250,z:-0.375),(x:0,y:-0.250,z:-0.375),(x:0.125,y:-0.250,z:-0.375),(x:0.25,y:-0.250,z:-0.375)
    ]
    
    let middle2 : Array<(x:Double,y:Double,z:Double)> = [
        (x:-0.25,y:0.2500,z:-0.250),(x:-0.125,y:0.2500,z:-0.250),(x:0,y:0.2500,z:-0.250),(x:0.125,y:0.2500,z:-0.250),(x:0.25,y:0.2500,z:-0.250),
        (x:-0.25,y:0.1250,z:-0.250),(x:-0.125,y:0.1250,z:-0.250),(x:0,y:0.1250,z:-0.250),(x:0.125,y:0.1250,z:-0.250),(x:0.25,y:0.1250,z:-0.250),
        (x:-0.25,y:0.0000,z:-0.250),(x:-0.125,y:0.0000,z:-0.250),(x:0,y:0.0000,z:-0.250),(x:0.125,y:0.0000,z:-0.250),(x:0.25,y:0.0000,z:-0.250),
        (x:-0.25,y:-0.125,z:-0.250),(x:-0.125,y:-0.125,z:-0.250),(x:0,y:-0.125,z:-0.250),(x:0.125,y:-0.125,z:-0.250),(x:0.25,y:-0.125,z:-0.250),
        (x:-0.25,y:-0.250,z:-0.250),(x:-0.125,y:-0.250,z:-0.250),(x:0,y:-0.250,z:-0.250),(x:0.125,y:-0.250,z:-0.250),(x:0.25,y:-0.250,z:-0.250)
    ]
    
    let middle3 : Array<(x:Double,y:Double,z:Double)> = [
        (x:-0.25,y:0.2500,z:-0.125),(x:-0.125,y:0.2500,z:-0.125),(x:0,y:0.2500,z:-0.125),(x:0.125,y:0.2500,z:-0.125),(x:0.25,y:0.2500,z:-0.125),
        (x:-0.25,y:0.1250,z:-0.125),(x:-0.125,y:0.1250,z:-0.125),(x:0,y:0.1250,z:-0.125),(x:0.125,y:0.1250,z:-0.125),(x:0.25,y:0.1250,z:-0.125),
        (x:-0.25,y:0.0000,z:-0.125),(x:-0.125,y:0.0000,z:-0.125),(x:0,y:0.0000,z:-0.125),(x:0.125,y:0.0000,z:-0.125),(x:0.25,y:0.0000,z:-0.125),
        (x:-0.25,y:-0.125,z:-0.125),(x:-0.125,y:-0.125,z:-0.125),(x:0,y:-0.125,z:-0.125),(x:0.125,y:-0.125,z:-0.125),(x:0.25,y:-0.125,z:-0.125),
        (x:-0.25,y:-0.250,z:-0.125),(x:-0.125,y:-0.250,z:-0.125),(x:0,y:-0.250,z:-0.125),(x:0.125,y:-0.250,z:-0.125),(x:0.25,y:-0.250,z:-0.125)
    ]
    
    let front : Array<(x:Double,y:Double,z:Double)> = [
        (x:-0.25,y:0.2500,z:-0.000),(x:-0.125,y:0.2500,z:-0.000),(x:0,y:0.2500,z:-0.000),(x:0.125,y:0.2500,z:-0.000),(x:0.25,y:0.2500,z:-0.000),
        (x:-0.25,y:0.1250,z:-0.000),(x:-0.125,y:0.1250,z:-0.000),(x:0,y:0.1250,z:-0.000),(x:0.125,y:0.1250,z:-0.000),(x:0.25,y:0.1250,z:-0.000),
        (x:-0.25,y:0.0000,z:-0.000),(x:-0.125,y:0.0000,z:-0.000),(x:0,y:0.0000,z:-0.000),(x:0.125,y:0.0000,z:-0.000),(x:0.25,y:0.0000,z:-0.000),
        (x:-0.25,y:-0.125,z:-0.000),(x:-0.125,y:-0.125,z:-0.000),(x:0,y:-0.125,z:-0.000),(x:0.125,y:-0.125,z:-0.000),(x:0.25,y:-0.125,z:-0.000),
        (x:-0.25,y:-0.250,z:-0.000),(x:-0.125,y:-0.250,z:-0.000),(x:0,y:-0.250,z:-0.000),(x:0.125,y:-0.250,z:-0.000),(x:0.25,y:-0.250,z:-0.000)
    ]
    
    
    var blocks = Array<(x:Double,y:Double,z:Double)>()
    blocks.append(contentsOf: back)
    blocks.append(contentsOf: middle)
    blocks.append(contentsOf: middle2)
    blocks.append(contentsOf: middle3)
    blocks.append(contentsOf: front)
    
    let materialArray : Array<([SCNMaterial])> = [
        
        //Back
        materials1a,materials2a,materials3a,materials4a,materials5a,
        materials1b,materials2b,materials3b,materials4b,materials5b,
        materials1c,materials2c,materials3c,materials4c,materials5c,
        materials1x,materials2x,materials3x,materials4x,materials5x,
        materials1x5,materials2x5,materials3x5,materials4x5,materials5x5,
        
        //Middle
        materials1d,materials2d,materials3d,materials4d,materials5d,
        materials1e,materials2e,materials3e,materials4e,materials5e,
        materials1f,materials2f,materials3f,materials4f,materials5f,
        materials1y,materials2y,materials3y,materials4y,materials5y,
        materials1y5,materials2y5,materials3y5,materials4y5,materials5y5,
        
        //Middle2
        materials1g,materials2g,materials3g,materials4g,materials5g,
        materials1h,materials2h,materials3h,materials4h,materials5h,
        materials1i,materials2i,materials3i,materials4i,materials5i,
        materials1z,materials2z,materials3z,materials4z,materials5z,
        materials1z5,materials2z5,materials3z5,materials4z5,materials5z5,
        
        //Middle3
        materials1ga,materials2ga,materials3ga,materials4ga,materials5ga,
        materials1ha,materials2ha,materials3ha,materials4ha,materials5ha,
        materials1ia,materials2ia,materials3ia,materials4ia,materials5ia,
        materials1za,materials2za,materials3za,materials4za,materials5za,
        materials1z5a,materials2z5a,materials3z5a,materials4z5a,materials5z5a,
        
        //Front
        materials1gb,materials2gb,materials3gb,materials4gb,materials5gb,
        materials1hb,materials2hb,materials3hb,materials4hb,materials5hb,
        materials1ib,materials2ib,materials3ib,materials4ib,materials5ib,
        materials1zb,materials2zb,materials3zb,materials4zb,materials5zb,
        materials1z5b,materials2z5b,materials3z5b,materials4z5b,materials5z5b,
        
        ]
    
    var counter = -1;
    brixCount = 0;
    //Draws the brix
    for coords in blocks {
        counter += 1
        brixCount += 1
        
        let brix = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        let opacity = CGFloat(1.0)
        let name = String("brix")
        let x = Float(coords.x)
        let y = Float(coords.y)
        let z = Float(coords.z)
        drawBrix(gameNode: cubeNode, Name: name, Material: materialArray[counter], Brix: brix, Opacity: opacity, X: x, Y: y, Z: z)
        
        if brixCount == 30 {
           // break
        }
    }
    
    restartLevel = true;
    
}
     

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerTruncationMode(_ input: CATextLayerTruncationMode) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerAlignmentMode(_ input: CATextLayerAlignmentMode) -> String {
	return input.rawValue
}
