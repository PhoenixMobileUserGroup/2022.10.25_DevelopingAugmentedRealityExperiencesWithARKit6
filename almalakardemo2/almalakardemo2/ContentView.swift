//
//  ContentView.swift
//  almalakardemo2
//
//  Created by Robert Al Malak on 10/24/22.
//

import SwiftUI
import RealityKit
import ARKit

//Handling user input
//Hit-test / Ray casting
//4k video (iOS 16, ARKit 6)
//High resolution capture (iOS 16, ARKit 6)
//HDR (iOS 16, ARKit 6)
//AR Session Delegate
//Debugging


typealias OnClickHandler = (() -> Void)

struct ContentView : View {
    
    @State var onClick: OnClickHandler = { }
    
    var body: some View {
        let arView = ARViewContainer(onClick: $onClick)
        return VStack {
            arView
            ZStack {
                VStack {
                    Button(
                        action: onClick,
                        label: { Text("Add Sphere") }
                    ).buttonStyle(.borderedProminent)
                }.frame(height: 50)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    let arView = ARView(frame: .init(x: 1, y: 1, width: 1, height: 1), cameraMode: .ar, automaticallyConfigureSession: false)
    var sessionDelegate: ARViewSessionDelegate = ARViewSessionDelegate()
    
    @Binding var onClick: OnClickHandler
    
    func makeUIView(context: Context) -> ARView {
        
        arView.debugOptions = [.showWorldOrigin, .showSceneUnderstanding]

        DispatchQueue.global(qos: .background).async {
            self.onClick = {

                if let result = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal).first {
                    let modelSphere = createModelSphere()

                    let anchorEntity = AnchorEntity(raycastResult: result)
                    anchorEntity.addChild(modelSphere)

                    // Add the box anchor to the scene
                    arView.scene.anchors.append(anchorEntity)
                }

//                 only supported with high resolution capture is enabled, non binning
//                 arView.session.captureHighResolutionFrame { frame, error in
//                     do something with high res frame, e.g.  save it in images
//                 }
            }
        }
        
        configureSession()
        
        let anchorEntity = createAnchoredSphere()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(anchorEntity)
        
        return arView
        
    }
    
    func configureSession() {
        // by default if we are using realitykit this is set to true
        arView.automaticallyConfigureSession = false
        
        // get the default session
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        
        if #available(iOS 16.0, *) {
            if let hiResFormat = ARWorldTrackingConfiguration.recommendedVideoFormatFor4KResolution {
                config.videoFormat = hiResFormat
            }
        } else {
            // Fallback on earlier versions
        }
        
        
        if #available(iOS 16.0, *) {
            if let hiResFormat = ARWorldTrackingConfiguration.recommendedVideoFormatForHighResolutionFrameCapturing {
                config.videoFormat = hiResFormat
            }
        } else {
            // Fallback on earlier versions
        }
        
        if #available(iOS 16.0, *) {
            // only allowed with non binned capture
            if config.videoFormat.isVideoHDRSupported {
                config.videoHDRAllowed = true
            }
        } else {
            // Fallback on earlier versions
        }
        
        // which planes we detect
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        config.sceneReconstruction = .meshWithClassification
        
        // run session
        session.run(config)
        
        // set delegate
        session.delegate = sessionDelegate
    }
    
    
    func createModelSphere() -> ModelEntity {
        // create sphere mesh
        let sphereMesh = MeshResource.generateSphere(radius: 0.1)
        // create a material
        let materials = [SimpleMaterial(color: .gray, isMetallic: true)]
        // create ModelEntity with mesh and material
        let modelEntity = ModelEntity(mesh: sphereMesh, materials: materials)
        
        return modelEntity
    }
    
    func createAnchoredSphere() -> AnchorEntity {
        let modelEntity = createModelSphere()
        // create AnchorEntity on specific position and add model entity to it
        let anchorEntity = AnchorEntity(world: [0, 0, -1])
        
        anchorEntity.addChild(modelEntity)
        
        return anchorEntity
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

class ARViewSessionDelegate: NSObject, ARSessionDelegate {
    
    // process each frame that was updated
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
    
    // check for new anchors
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
