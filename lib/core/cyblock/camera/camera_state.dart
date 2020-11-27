part of image_pick;

abstract class CameraState {}

class CameraStatePicked extends CameraState {
  final PickedFile image;
  CameraStatePicked({
    @required this.image
  });
}

class CameraStateEmpty extends CameraState {}