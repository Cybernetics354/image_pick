// part of image_pick;

// class AwesomeCameraMainView extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   AwesomeCameraMainView({
//     @required this.cameras
//   });
//   @override
//   _AwesomeCameraMainViewState createState() => _AwesomeCameraMainViewState();
// }

// class _AwesomeCameraMainViewState extends State<AwesomeCameraMainView> with WidgetsBindingObserver {
//   int selectedCamera = 0;
//   bool _supportFlash = true;
//   bool _lightStatus = false;

//   final CameraAwesomeController _cameraAwesomeController = new CameraAwesomeController();
//   final CameraCyblock _cameraCyblock = new CameraCyblock();
//   PictureController _pictureController = new PictureController();

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     switch (state) {
//       case AppLifecycleState.paused: {
//         // TODO :: onPaused
//         break;
//       }

//       case AppLifecycleState.inactive: {
//         // TODO :: onInactive
//         break;
//       }

//       case AppLifecycleState.resumed: {
//         // TODO :: onResumed
//         break;
//       }

//       case AppLifecycleState.detached: {
//         // TODO :: onDetached
//         break;
//       }
        
//       default:
//     }
//   }

//   getImage() async {
//     Directory _appdirectory;
//     try {
//       _appdirectory = await getApplicationDocumentsDirectory();
//     } catch (e) {
//       print("Tidak bisa mengambil path");
//     }

//     if(_appdirectory != null) {
//       String path = _appdirectory.path;
//       String imageName = DateTime.now().toString();

//       try {
//         await _pictureController.takePicture("$path/$imageName.jpg");
//         PickedFile _file = PickedFile("$path/$imageName.jpg");
//         _cameraCyblock.insertEvent(CameraEventPickImage(image: _file));
//       } catch (e) {
//         print("Tidak bisa Mengambil gambar");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: AnimatedSwitcher(
//               duration: Duration(milliseconds: 400),
//               transitionBuilder: (child, animation) {
//                 return ScaleTransition(
//                   scale: animation,
//                   child: FadeTransition(
//                     opacity: animation,
//                     child: child,
//                   ),
//                 );
//               },
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 child: StreamBuilder<CameraState>(
//                   stream: _cameraCyblock.stream,
//                   builder: (context, snapshot) {
//                     if(snapshot.connectionState == ConnectionState.waiting) {
//                       _cameraCyblock.getState();
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     }

//                     if(snapshot.data is CameraStateEmpty) {
//                       return CameraAwesomeView(
//                         controller: _cameraAwesomeController,
//                       );
//                     } else if(snapshot.data is CameraStatePicked) {
//                       CameraStatePicked _data = snapshot.data;
//                       return Image.file(File(_data.image.path), fit: BoxFit.cover);
//                     }

//                     return SizedBox();
//                   }
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 50.0,
//             left: 0.0,
//             right: 0.0,
//             child: StreamBuilder<CameraState>(
//               stream: _cameraCyblock.stream,
//               builder: (context, snapshot) {
//                 if(snapshot.connectionState == ConnectionState.waiting) {
//                   _cameraCyblock.emitValue();
//                   return SizedBox();
//                 }

//                 if(snapshot.data is CameraStateEmpty) {
//                   return Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 40.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         widget.cameras.length == 2 ? CameraActionButton(
//                           child: Icon(Icons.rotate_left, color: Colors.white,),
//                           onTap: () {
//                             if(selectedCamera == 0) {
//                               _cameraAwesomeController.sensor = ValueNotifier(Sensors.FRONT);
//                               setState(() {
//                                 selectedCamera = 1;
//                               });
//                             } else if(selectedCamera == 1) {
//                               _cameraAwesomeController.sensor = ValueNotifier(Sensors.BACK);
//                               setState(() {
//                                 selectedCamera = 0;
//                               });
//                             }
//                           },
//                         ) : SizedBox(),
//                         GestureDetector(
//                           onTap: () {
//                             getImage();
//                           },
//                           child: Container(
//                             width: 70.0,
//                             height: 70.0,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.transparent,
//                               border: Border.all(
//                                 color: Colors.white,
//                                 width: 2.0
//                               )
//                             ),
//                             child: Center(
//                               child: Icon(Icons.camera, color: Colors.white, size: 40.0,)
//                             ),
//                           ),
//                         ),
//                         _supportFlash == true ? CameraActionButton(
//                           child: Icon(_lightStatus == true ? Icons.lightbulb : Icons.lightbulb_outline, color: Colors.white,),
//                           onTap: () async {
//                             if(_lightStatus == false) {
//                               setState(() {
//                                 _cameraAwesomeController.switchFlash = ValueNotifier(CameraFlashes.ALWAYS);
//                                 _lightStatus = true;
//                               });
//                             } else {
//                               _cameraAwesomeController.switchFlash = ValueNotifier(CameraFlashes.NONE);
//                               setState(() {
//                                 _lightStatus = false;
//                               });
//                             }
//                           },
//                         ) : SizedBox()
//                       ],
//                     ),
//                   );
//                 } else if(snapshot.data is CameraStatePicked) {
//                   return Container(
//                     padding: EdgeInsets.symmetric(horizontal: 40.0),
//                     width: MediaQuery.of(context).size.width,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CameraActionButton(
//                           child: Icon(Icons.close, color: Colors.white,),
//                           onTap: () {
//                             _cameraCyblock.insertEvent(CameraEventPickAgain());
//                           },
//                         ),
//                         CameraActionButton(
//                           child: Icon(Icons.check, color: Colors.white),
//                           onTap: () {
//                             CameraStatePicked _state = _cameraCyblock.state;
//                             Navigator.pop(context, _state.image);
//                           },
//                         )
//                       ],
//                     ),
//                   );
//                 }

//                 return SizedBox();
//               }
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class CameraAwesomeController {
//   ValueNotifier<Sensors> sensor = ValueNotifier(Sensors.BACK);
//   ValueNotifier<Size> photoSize = ValueNotifier(null);
//   ValueNotifier<CameraFlashes> switchFlash = ValueNotifier(CameraFlashes.NONE);
//   ValueNotifier<double> brightness = ValueNotifier(1);
// }

// class CameraAwesomeView extends StatefulWidget {
//   final CameraAwesomeController controller;
//   CameraAwesomeView({
//     @required this.controller
//   });

//   @override
//   _CameraAwesomeViewState createState() => _CameraAwesomeViewState();
// }

// class _CameraAwesomeViewState extends State<CameraAwesomeView> {
//   @override
//   Widget build(BuildContext context) {
//     return CameraAwesome(
//       sensor: widget.controller.sensor,
//       photoSize: widget.controller.photoSize,
//       brightness: widget.controller.brightness,
//       switchFlashMode: widget.controller.switchFlash,
//       selectDefaultSize: (size) {
//         widget.controller.photoSize = ValueNotifier(size[0]);
//         return size[0];
//       },
//       onPermissionsResult: (permission) {
//         if(permission == false) {
//           Navigator.pop(context);
//         }
//       },
//     );
//   }
// }