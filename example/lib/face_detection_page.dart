import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

final int base = 460;

final List<Color> colors = [
  Colors.orange,
  Colors.deepOrange,
  Colors.yellow,
  Colors.purple,
  Colors.red,
  Colors.white,
  Colors.black,
  Colors.grey,
  Colors.blue,
  Colors.green,
];

class FaceDetectionPage extends StatefulWidget {
  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late ARKitController arkitController;
  ARKitNode? node;
  ARKitNode? leftEye;
  ARKitNode? rightEye;
  ARKitNode? leftTemple;
  ARKitNode? rightTemple;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Face Detection Sample')),
        body: Container(
          child: ARKitSceneView(
            configuration: ARKitConfiguration.faceTracking,
            onARKitViewCreated: onARKitViewCreated,
          ),
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (anchor is! ARKitFaceAnchor) return;

    final material = ARKitMaterial(fillMode: ARKitFillMode.lines);
    anchor.geometry.materials.value = [material];

    node = ARKitNode(geometry: anchor.geometry);
    arkitController.add(node!, parentNodeName: anchor.nodeName);

    /* leftEye = _createEye(anchor.leftEyeTransform);
    arkitController.add(leftEye!, parentNodeName: anchor.nodeName);
    rightEye = _createEye(anchor.rightEyeTransform);
    arkitController.add(rightEye!, parentNodeName: anchor.nodeName); */

    /* for (var i = 0; i < 10; i++) {
      final node = _createPoint(anchor.vertices[base + i], i);
      arkitController.add(node, parentNodeName: anchor.nodeName);
    } */

    leftTemple = _createPoint(anchor.vertices[467], 0, false);
    arkitController.add(leftTemple!, parentNodeName: anchor.nodeName);

    rightTemple = _createPoint(anchor.vertices[888], 2, false);
    arkitController.add(rightTemple!, parentNodeName: anchor.nodeName);
  }

  ARKitNode _createPoint(dynamic position, int index, [bool special = false]) {
    final p = vector.Vector3(position[0], position[1], position[2]);

    return ARKitNode(
      position: p,
      geometry: ARKitSphere(
        materials: [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.color(colors[index]),
          ),
        ],
        radius: special ? .006 : .003,
      ),
    );
  }

  ARKitNode _createEye(Matrix4 transform) {
    final position = vector.Vector3(
      transform.getColumn(3).x,
      transform.getColumn(3).y,
      transform.getColumn(3).z,
    );
    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(Colors.yellow),
    );
    final sphere = ARKitBox(
        materials: [material], width: 0.03, height: 0.03, length: 0.03);

    return ARKitNode(geometry: sphere, position: position);
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitFaceAnchor && mounted) {
      arkitController.updateFaceGeometry(node!, anchor.identifier);
      /* _updateEye(leftEye!, faceAnchor.leftEyeTransform,
          faceAnchor.blendShapes['eyeBlink_L'] ?? 0);
      _updateEye(rightEye!, faceAnchor.rightEyeTransform,
          faceAnchor.blendShapes['eyeBlink_R'] ?? 0); */

      print(leftTemple!.position.distanceTo(rightTemple!.position));
    }
  }

  void _updateEye(ARKitNode node, Matrix4 transform, double blink) {
    final scale = vector.Vector3(1, 1 - blink, 1);
    node.scale = scale;
  }
}
