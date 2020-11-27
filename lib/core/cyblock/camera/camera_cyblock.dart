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
    emit(CameraStatePicked(image: image));
  }

  _pickAgain() {
    emit(CameraStateEmpty());
  }

  emitValue() {
    emit(state);
  }
}