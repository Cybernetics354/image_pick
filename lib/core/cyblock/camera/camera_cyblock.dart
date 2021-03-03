part of image_pick;

class CameraCyblock extends Cyblock<CameraState, CameraEvent> {
  CameraCyblock() : super(CameraStateEmpty());

  @override
  void mapEventToState(CameraEvent event) {
    if(event is CameraEventPickImage) {
      _cameraPick(event.image);
    } else if(event is CameraEventPickAgain) {
      _pickAgain();
    }
  }

  _cameraPick(PickedFile image) {
    Imagex.Image img = Imagex.decodeImage(File(image.path).readAsBytesSync())!;
    ImageOrientationState orientationState;

    if(img.width > img.height) {
      orientationState = ImageOrientationState.landscape;
    } else {
      orientationState = ImageOrientationState.portrait;
    }

    emit(CameraStatePicked(image: image, orientation: orientationState));
  }

  _pickAgain() {
    emit(CameraStateEmpty());
  }

  emitValue() {
    emit(state);
  }
}