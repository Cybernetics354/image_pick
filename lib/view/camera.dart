part of image_pick;

class CameraPickMainView extends StatefulWidget {
  final List<CameraDescription> cameras;
  final ImagePickConfiguration config;
  CameraPickMainView({
    @required this.cameras,
    @required this.config,
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
        print("Paused");
        // TODO :: onPaused
        break;
      }

      case AppLifecycleState.inactive: {
        print("Inactive");
        // TODO :: onInactive
        break;
      }

      case AppLifecycleState.resumed: {
        print("Resumed");
        // TODO :: onResumed
        break;
      }

      case AppLifecycleState.detached: {
        print("Detached");
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
        String imgPath = "$path/$imageName.jpg";
        await _cameraController.takePicture(imgPath);

        // resizing if configured
        Imagex.Image img = Imagex.decodeImage(new File(imgPath).readAsBytesSync());
        if ((widget.config.maxWidth > 0 && widget.config.maxWidth < img.width) || (widget.config.maxHeight > 0 && widget.config.maxHeight < img.height)) {
          bool isResized;
          if (widget.config.maxWidth > 0 && img.width >= img.height) {
            img = Imagex.copyResize(img, width: widget.config.maxWidth.toInt());
            isResized = true;

          } else if (widget.config.maxHeight > 0) {
            img = Imagex.copyResize(img, height: widget.config.maxHeight.toInt());
            isResized = true;
          }

          // minimize unnecessary process
          if (isResized) {
            (new File(imgPath)).writeAsBytesSync(Imagex.encodeJpg(img));
          }
        }

        PickedFile _file = PickedFile(imgPath);
        _cameraCyblock.insertEvent(CameraEventPickImage(image: _file));

      } catch (e) {
        print("Tidak bisa Mengambil gambar");
      }
    }
  }

  getImageFromPicker() async {
    var _sharePref = await SharedPreferences.getInstance();
    bool _check = _sharePref.getBool("image_pick_warning");
    if(_check == null || _check == false) {
      if(ImagePick.warningPicker != null) {
        bool _status = await ImagePick.warningPicker();
        if(_status == true) {
          _pickImageFromPicker();
        }

        return;
      }

      bool _status = await showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text("Peringatan"),
          content: Text("Anda akan mengambil gambar dari kamera bawaan HP, dikarenakan memori yang kurang, terdapat kemungkinan nanti akan merestart aplikasi ini, apakah anda akan tetap ingin melanjutkan?"),
          actions: [
            FlatButton(
              child: Text("Lanjutkan"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            FlatButton(
              child: Text("Keluar"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      });

      if(_status == true) {
        _sharePref.setBool("image_pick_warning", true);
        _pickImageFromPicker();
      }

      return;
    }

    _pickImageFromPicker();
  }

  _pickImageFromPicker() async {
    _cameraController?.dispose();
    PickedFile _pickedFile = await ImagePick.instance.getImage(ImagePickConfiguration(
      imageSource: ImagePickSourcePicker(
        pickerSource: PickerSource.camera,
      ),
      maxHeight: widget.config.maxHeight,
      maxWidth: widget.config.maxWidth,
      quality: widget.config.quality
    ));

    if(_pickedFile != null) {
      Navigator.pop(context, _pickedFile);
    } else {
      initializeCamera(0);
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
                            // TODO :: Adding flashlight
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
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 20.0,
            right: 20.0,
            child: GestureDetector(
              onTap: () {
                getImageFromPicker();
              },
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0
                  ),
                  shape: BoxShape.circle
                ),
                child: Icon(Icons.image, color: Colors.white,),
              ),
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