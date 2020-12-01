library image_pick;

import 'dart:io';

import 'package:camera/camera.dart';
// import 'package:camerawesome/camerapreview.dart';
// import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cyblock/cyblock.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_info/system_info.dart';
import 'package:image/image.dart' as Imagex;

part 'core/image_pick.dart';
part 'model/configuration.dart';
part 'view/camera.dart';
part 'core/cyblock/camera/camera_state.dart';
part 'core/cyblock/camera/camera_cyblock.dart';
part 'core/cyblock/camera/camera_event.dart';
// part 'view/awesome_camera.dart';
