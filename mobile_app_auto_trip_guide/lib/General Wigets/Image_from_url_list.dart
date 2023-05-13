import 'package:flutter/material.dart';

class ImageFromUrlList extends StatefulWidget {
  final List<String> imageUrlList;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String category;

  ImageFromUrlList({
    required this.imageUrlList,
    this.height,
    this.width,
    this.fit,
    this.category = 'default',
  });

  @override
  _ImageFromUrlListState createState() => _ImageFromUrlListState();
}

class _ImageFromUrlListState extends State<ImageFromUrlList> {
  int currentIndex = 0;

  final Map<String, String> categoryToAssetName = {
    'default': 'assets/images/auto_trip_guide_logo.png',
   // 'Churches': 'assets/images/churches.png',
  };

  @override
  Widget build(BuildContext context) {
    String defaultAssetName =
        categoryToAssetName[widget.category] ?? categoryToAssetName['default']!;

    if (widget.imageUrlList.isEmpty) {
      return Image.asset(
        defaultAssetName,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      );
    }

    return FutureBuilder(
      future: precacheImage(
          NetworkImage(widget.imageUrlList[currentIndex]), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError && currentIndex < widget.imageUrlList.length - 1) {
            setState(() {
              currentIndex++;
            });
          } else if (snapshot.hasError && currentIndex == widget.imageUrlList.length - 1) {
            return Image.asset(
              defaultAssetName,
              height: widget.height,
              width: widget.width,
              fit: widget.fit,
            );
          }
          return Image.network(
            widget.imageUrlList[currentIndex],
            height: widget.height,
            width: widget.width,
            fit: widget.fit,
          );
        } else {
          return SizedBox(
            height: widget.height,
            width: widget.width,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}