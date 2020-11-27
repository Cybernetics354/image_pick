# image_pick

An Image picker for Flutter with Memory Decision

## Purpose

I made this package because image picker from flutter sometimes crash and destroy MainActivity when system needs more RAM, so we need to alternative image picker when the condition fullfils

## Usage

First of all, just initialize it in `main`
```dart
void main() {
  runApp(MyApp());
  ImagePick.instance.initializeAvailableCamera(500.0);
}
```

and then you can use it

```dart
FloatingActionButton(
    child: Icon(Icons.camera_alt),
    onPressed: () async {
        PickedFile _image = await ImagePick.instance.getImageWithMemoryDecision(ImagePickWithMemoryConfiguration(
            camera: ImagePickSourceCamera(context: context),
            picker: ImagePickSourcePicker(pickerSource: PickerSource.camera),
        ));

        setState(() {
            _file = _image;
        });
    },
)
```

Happy fluttering, @Cybernetics Core
