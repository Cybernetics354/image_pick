part of image_pick;

class ImagePickConfiguration {
  ImagePickSource? imageSource;
  double? maxWidth = 1400.0;
  double? maxHeight = 1400.0;
  int? quality = 90;

  ImagePickConfiguration({
    required this.imageSource,
    this.maxHeight,
    this.maxWidth,
    this.quality
  });
}

abstract class ImagePickSource {}

enum PickerSource { camera, gallery }

class ImagePickSourcePicker extends ImagePickSource {
  PickerSource? pickerSource;

  ImagePickSourcePicker({
    this.pickerSource
  });
}

class ImagePickSourceCamera extends ImagePickSource {
  BuildContext? context;
  
  ImagePickSourceCamera({
    this.context
  });
}

class ImagePickWithMemoryConfiguration {
  ImagePickSourceCamera? camera;
  ImagePickSourcePicker? picker;
  double? maxWidth;
  double? maxHeight;
  int? quality;

  ImagePickWithMemoryConfiguration({
    this.camera,
    this.picker,
    this.maxHeight,
    this.maxWidth,
    this.quality
  });
}