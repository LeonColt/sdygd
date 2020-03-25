import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePick {
    
    static Future<File> pickImage( final BuildContext context, { final bool crop = false, final bool isCircle = false } ) async {
        final source = await _selectImageSource(context);
        if (source == null) return null;
        final image = await ImagePicker.pickImage(source: source, imageQuality: 80, maxWidth: 1920, maxHeight: 1080 );
        if (image == null) return null;
        if ( crop ) {
            final cropped = await ImageCropper.cropImage(
                sourcePath: image.path,
                cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
                maxWidth: 1920,
                maxHeight: 1080,
            );
            return cropped;
        }
        else return image;
    }
    
    static Future<ImageSource> _selectImageSource(final BuildContext context) async =>
            await showModalBottomSheet(
                context: context,
                elevation: 10.0,
                builder: (BuildContext modalContext) => new ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                        new ListTile(
                            title: new Text(
                                "Batal",
                                style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w700,
                                ),
                            ),
                            leading: const Icon(Icons.close),
                            onTap: () => Navigator.of(modalContext).pop(),
                        ),
                        new ListTile(
                            title: new Text(
                                "Kamera",
                                style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w700,
                                ),
                            ),
                            onTap: () => Navigator.of(modalContext).pop(ImageSource.camera),
                        ),
                        new ListTile(
                            title: new Text(
                                "Galeri",
                                style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w700,
                                ),
                            ),
                            onTap: () => Navigator.of(modalContext).pop(ImageSource.gallery),
                        ),
                    ],
                ),
            );
}