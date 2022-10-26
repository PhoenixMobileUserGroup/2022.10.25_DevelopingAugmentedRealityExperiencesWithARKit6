//
//  ContentView.swift
//  demo1
//
//  Created by Robert Al Malak on 10/22/22.
//

import SwiftUI
import RealityKit
import ARKit

//Create your first RealityKit experience!
//Using Reality Composer
//Working with AnchorEntity and ModelEntity
//Using the ARWorldTrackingConfig


struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    let arView = ARView(frame: .zero)
    
    func makeUIView(context: Context) -> ARView {
        
        
        // Load the "Box" scene from the "Experience" Reality File
        //let anchorEntity = try! Experience.loadBox()
        
        let anchorEntity = createSphere()
        
        //configureSession()
   
        // Add the box anchor to the scene
        arView.scene.anchors.append(anchorEntity)
        
        return arView
        
    }
    
    func createSphere() -> AnchorEntity {
        // create sphere mesh
        let sphereMesh = MeshResource.generateSphere(radius: 0.1)
        // create a material
        let materials = [SimpleMaterial(color: .gray, isMetallic: true)]
        // create ModelEntity with mesh and material
        let modelEntity = ModelEntity(mesh: sphereMesh, materials: materials)
        // create AnchorEntity on specific position and add model entity to it
        let anchorEntity = AnchorEntity(world: [0, 0, -1])
        
        anchorEntity.addChild(modelEntity)
        
        return anchorEntity
    }
    
    func configureSession() {
        // by default if we are using realitykit this is set to true
        arView.automaticallyConfigureSession = false
        
        // get the default session
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        
        // which planes we detect
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        //config.sceneReconstruction = .mesh
        
        // run session
        session.run(config)
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
