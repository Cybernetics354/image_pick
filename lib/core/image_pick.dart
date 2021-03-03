part of image_pick;

class ImagePick {
  static List<CameraDescription>? _cameraDescription;
  static late double _memoryPercentage;
  static WarningPickerCallback? warningPicker;

  static final ImagePick _singleton = ImagePick._();
  ImagePick._();
  static ImagePick get instance => _singleton;

  final ImagePicker _imagePicker = new ImagePicker();

  Future<PickedFile?> getImage(ImagePickConfiguration configuration) async {
    var _source = configuration.imageSource;
    if(_source is ImagePickSourcePicker) {
      return await _getImageWithImagePicker(configuration);
    } else if(_source is ImagePickSourceCamera) {
      return await _getImageFromCamera(configuration);
    }

    return null;
  }
  
  Future<PickedFile?> getImageWithMemoryDecision(ImagePickWithMemoryConfiguration configuration) async {
    double decrement = 1024.0 * 1024.0;
    double _physicalMemory = double.parse((SysInfo.getFreePhysicalMemory() + SysInfo.getFreeVirtualMemory()).toString());

    double _currentMemoryInMB = _physicalMemory / decrement;
    double _memoryMinumum = (double.parse(SysInfo.getTotalPhysicalMemory().toString()) / decrement) * _memoryPercentage;
    if(configuration.picker!.pickerSource == PickerSource.camera) {
      if(_currentMemoryInMB > _memoryMinumum) {
        return await getImage(ImagePickConfiguration(
          imageSource: configuration.picker,
          maxHeight: configuration.maxHeight,
          maxWidth: configuration.maxWidth,
          quality: configuration.quality
        ));
      } else {
        return await getImage(ImagePickConfiguration(
          imageSource: configuration.camera,
          maxHeight: configuration.maxHeight,
          maxWidth: configuration.maxWidth,
          quality: configuration.quality
        ));
      }
    }

    return await getImage(ImagePickConfiguration(
      imageSource: ImagePickSourcePicker(pickerSource: PickerSource.gallery),
      maxHeight: configuration.maxHeight,
      maxWidth: configuration.maxWidth,
      quality: configuration.quality
    ));
  }

  Future<PickedFile?> _getImageWithImagePicker(ImagePickConfiguration configuration) async {
    ImagePickSourcePicker _source = configuration.imageSource as ImagePickSourcePicker;
    ImageSource _imageSource;
    switch (_source.pickerSource) {
      case PickerSource.camera: {
        _imageSource = ImageSource.camera;
        break;
      }

      case PickerSource.gallery: {
        _imageSource = ImageSource.gallery;
        break;
      }
        
      default: {
        _imageSource = ImageSource.camera;
      }
    }

    PickedFile? _pickedFile = await _imagePicker.getImage(
      source: _imageSource,
      maxHeight: configuration.maxHeight,
      maxWidth: configuration.maxWidth,
      imageQuality: configuration.quality,
    );

    return _pickedFile;
  }

  Future<PickedFile?> _getImageFromCamera(ImagePickConfiguration configuration) async {
    ImagePickSourceCamera? _source = configuration.imageSource as ImagePickSourceCamera?;
    if(_cameraDescription != null && _cameraDescription!.length != 0) {
      return await Navigator.push(_source!.context!, MaterialPageRoute(
        builder: (_) => CameraPickMainView(cameras: _cameraDescription, config: configuration)
      ));
    } else {
      throw "Camera tidak ditemukan";
    }
  }

  Future initializeAvailableCamera(double memoryMin, {WarningPickerCallback? warningPickerCallback}) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      _cameraDescription = await availableCameras();
      _memoryPercentage = memoryMin;
      warningPicker = warningPickerCallback;
    } catch (e) {
      initializeAvailableCamera(memoryMin, warningPickerCallback: warningPickerCallback);
    }
  }
}

typedef Future<bool> WarningPickerCallback();