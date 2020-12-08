part of image_pick;

abstract class CameraState {}

class CameraStatePicked extends CameraState {
  final PickedFile image;
  final ImageOrientationState orientation; 
  CameraStatePicked({
    @required this.image,
    @required this.orientation
  });
}

class CameraStateEmpty extends CameraState {}

enum ImageOrientationState {
  landscape,
  portrait
}