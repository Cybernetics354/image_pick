part of image_pick;

class CameraPickMainView extends StatefulWidget {
  final List<CameraDescription> cameras;
  CameraPickMainView({
    @required this.cameras
  });

  @override
  _CameraPickMainViewState createState() => _CameraPickMainViewState();
}

class _CameraPickMainViewState extends State<CameraPickMainView> with WidgetsBindingObserver {
  int selectedCamera = 0;
  bool _supportFlash;
  bool _lightStatus = false;

  final CameraCyblock _cameraCyblock = new CameraCyblock();
  CameraController _cameraController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused: {
        // TODO :: onPaused
        break;
      }

      case AppLifecycleState.inactive: {
        // TODO :: onInactive
        break;
      }

      case AppLifecycleState.resumed: {
        // TODO :: onResumed
        break;
      }

      case AppLifecycleState.detached: {
        // TODO :: onDetached
        break;
      }
        
      default:
    }
  }

  @override
  void initState() { 
    super.initState();
    initializeCamera(0);
    getFlashlight();
  }

  getFlashlight() async {
    // bool _flash = await Lamp.hasLamp;
    // if(mounted) {
    //   setState(() {
    //     _supportFlash = _flash;
    //   });
    // }
  }

  initializeCamera(int index) {
    if(mounted) {
      setState(() {
        _cameraController = new CameraController(widget.cameras[index], ResolutionPreset.high);
      });
    }
    _cameraController.initialize().then((_) {
      if(mounted) {
        setState(() {
        });
      }
    });
  }

  getImage() async {
    Directory _appdirectory;
    try {
      _appdirectory = await getApplicationDocumentsDirectory();
    } catch (e) {
      print("Tidak bisa mengambil path");
    }

    if(_appdirectory != null) {
      String path = _appdirectory.path;
      String imageName = DateTime.now().toString();

      try {
        await _cameraController.takePicture("$path/$imageName.jpg");
        PickedFile _file = PickedFile("$path/$imageName.jpg");
        _cameraCyblock.insertEvent(CameraEventPickImage(image: _file));
      } catch (e) {
        print("Tidak bisa Mengambil gambar");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: !_cameraController.value.isInitialized ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ) : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: StreamBuilder<CameraState>(
                  stream: _cameraCyblock.stream,
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      _cameraCyblock.getState();
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if(snapshot.data is CameraStateEmpty) {
                      return CameraPreview(
                        _cameraController,
                      );
                    } else if(snapshot.data is CameraStatePicked) {
                      CameraStatePicked _data = snapshot.data;
                      return Image.file(File(_data.image.path), fit: BoxFit.cover);
                    }

                    return SizedBox();
                  }
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50.0,
            left: 0.0,
            right: 0.0,
            child: StreamBuilder<CameraState>(
              stream: _cameraCyblock.stream,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  _cameraCyblock.emitValue();
                  return SizedBox();
                }

                if(snapshot.data is CameraStateEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.cameras.length == 2 ? CameraActionButton(
                          child: Icon(Icons.rotate_left, color: Colors.white,),
                          onTap: () {
                            if(selectedCamera == 0) {
                              initializeCamera(1);
                              setState(() {
                                selectedCamera = 1;
                              });
                            } else if(selectedCamera == 1) {
                              initializeCamera(0);
                              setState(() {
                                selectedCamera = 0;
                              });
                            }
                          },
                        ) : SizedBox(),
                        GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: Container(
                            width: 70.0,
                            height: 70.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0
                              )
                            ),
                            child: Center(
                              child: Icon(Icons.camera, color: Colors.white, size: 40.0,)
                            ),
                          ),
                        ),
                        _supportFlash == true ? CameraActionButton(
                          child: Icon(_lightStatus == true ? Icons.lightbulb : Icons.lightbulb_outline, color: Colors.white,),
                          onTap: () async {
                            // if(_lightStatus == false) {
                            //   await Lamp.turnOn();
                            //   setState(() {
                            //     _lightStatus = false;
                            //   });
                            // } else {
                            //   await Lamp.turnOff();
                            //   setState(() {
                            //     _lightStatus = true;
                            //   });
                            // }
                          },
                        ) : SizedBox(width: 50.0,)
                      ],
                    ),
                  );
                } else if(snapshot.data is CameraStatePicked) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CameraActionButton(
                          child: Icon(Icons.close, color: Colors.white,),
                          onTap: () {
                            _cameraCyblock.insertEvent(CameraEventPickAgain());
                          },
                        ),
                        CameraActionButton(
                          child: Icon(Icons.check, color: Colors.white),
                          onTap: () {
                            CameraStatePicked _state = _cameraCyblock.state;
                            Navigator.pop(context, _state.image);
                          },
                        )
                      ],
                    ),
                  );
                }

                return SizedBox();
              }
            ),
          )
        ],
      ),
    );
  }
}

class CameraActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  CameraActionButton({
    @required this.child,
    @required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(
            color: Colors.white,
            width: 2.0
          ),
        ),
        child: Center(
          child: child,
        )
      ),
    );
  }
}