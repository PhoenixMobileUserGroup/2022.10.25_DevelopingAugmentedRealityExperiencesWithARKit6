//
//  ContentView.swift
//  almalakardemo3
//
//  Created by Robert Al Malak on 10/24/22.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

// Coaching Overlay
// People occlusion
// Environment occlusion
// Reality composer behaviors
// Matrix Transformations

struct ARViewContainer: UIViewRepresentable {
    
    let arView = ARView(frame: .zero)
    
    func makeUIView(context: Context) -> ARView {
        
        arView.debugOptions = [.showWorldOrigin]
        arView.environment.sceneUnderstanding.options = .occlusion
            
        configureSession()
        
        // Add coaching overlay
        addCoachingOverlay(session: arView.session)
        
        // Load the "Box" scene from the "Experience" Reality File
        //let planeAnchor = try! Experience.loadPlane()
        let puppetAnchor = try! Experience.loadPuppet()
        

        
        // move forward - Translate
        let translateMatrix =  float4x4([ 1, 0, 0, 0], /* column 0 */
                                        [ 0, 1, 0, 0 ], /* column 1 */
                                        [ 0, 0, 1, 0 ], /* column 2 */
                                        [ -0.2, 0, -0.2, 1 ]) /* column 3 */
        
        
        // rotate 90 degrees on X axis - Rotate
//        let rotationMatrix = float4x4([ 1, 0, 0, 0 ],        /* column 0 */
//                                      [ 0, a, -b, 0 ],        /* column 1 */
//                                      [ 0, b, a, 0 ],        /* column 2 */
//                                      [ 0, 0, 0, 1 ])        /* column 3 */
        
        // rotate 90 degrees on Z axis - Rotate
//        let rotationMatrix = float4x4([ a, b, 0, 0 ],        /* column 0 */
//                                      [-b, a, 0, 0 ],        /* column 1 */
//                                      [ 0, 0, 1, 0 ],        /* column 2 */
//                                      [ 0, 0, 0, 1 ])        /* column 3 */
        
        
        let a: Float = cos(.pi/2)
        let b: Float = sin(.pi/2)
        
        let rotateMoveMatrix = translateMatrix * float4x4([ a, 0, b, 0 ],        /* column 0 */
                                                          [ 0, 1, 0, 0 ],       /* column 1 */
                                                          [ -b, 0, a, 0 ],        /* column 2 */
                                                          [ 0, 0, 0, 1 ])        /* column 3 */
        
        // scale by 500% - Scale
        let rotateMoveAndScaleMatrix = rotateMoveMatrix * float4x4([ 5, 0, 0, 0 ],        /* column 0 */
                                                                   [ 0, 5, 0, 0 ],        /* column 1 */
                                                                   [ 0, 0, 5, 0 ],        /* column 2 */
                                                                   [ 0, 0, 0, 1 ])        /* column 3 */
        
        

        puppetAnchor.puppetModel?.setTransformMatrix(rotateMoveAndScaleMatrix, relativeTo: nil)
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(puppetAnchor)
        
        return arView
        
    }
    
    
    func addCoachingOverlay(session: ARSession) {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
    }
    
    
    func configureSession() {
        // by default if we are using realitykit this is set to true
        arView.automaticallyConfigureSession = false
        
        // get the default session
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        
        // as this is a sample project we kill the app if there is no occlusion
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }
        config.frameSemantics.insert(.personSegmentationWithDepth)
        
        // which planes we detect
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        config.sceneReconstruction = .mesh
        
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
