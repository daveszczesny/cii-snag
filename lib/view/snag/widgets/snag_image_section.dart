import 'package:cii/view/utils/image.dart';
import 'package:flutter/widgets.dart';

class SnagImageSection extends StatelessWidget {
  final List<String> imageFilePaths;
  final String selectedImage;
  final Function({String p}) onChange;
  final Function(String, String) saveAnnotatedImage;
  final Function(String) setAsMainImage;
  final Function(String) getAnnotatedImage;

  const SnagImageSection({
    super.key,
    required this.imageFilePaths,
    required this.selectedImage,
    required this.onChange,
    required this.saveAnnotatedImage,
    required this.setAsMainImage,
    required this.getAnnotatedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        if (imageFilePaths.isEmpty) ... [
          buildImageInput_V3(context, onChange, imageFilePaths)
        ] else ... [
          showImageWithEditAbility(
            context,
            selectedImage.isNotEmpty ? selectedImage : getAnnotatedImage(imageFilePaths[0]),
            saveAnnotatedImage
          )
        ],

        const SizedBox(height: 14.0),
        if (imageFilePaths.isNotEmpty) ... [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildImageShowcase(
                context,
                onChange,
                saveAnnotatedImage,
                imageFilePaths,
                onLongPress: setAsMainImage
              ),
              if (imageFilePaths.length < 5) ... [
                buildImageInput_V3(context, onChange, imageFilePaths, large: false)
              ],
            ],
          ),
          const SizedBox(height: 28.0)
        ]
      ]
    );
  }
}
