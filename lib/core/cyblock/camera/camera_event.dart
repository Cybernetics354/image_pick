part of image_pick;

abstract class CameraEvent {}

class CameraEventPickImage extends CameraEvent {
  final PickedFile image;
  CameraEventPickImage({
    required this.image
  });
}

class CameraEventPickAgain extends CameraEvent {}