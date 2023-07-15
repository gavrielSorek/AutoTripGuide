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
    'default': 'assets/images/logo.png',
    'Buildings': 'assets/images/categories/Buildings.jpg',
    'Parks': 'assets/images/categories/Park.jpg',
    'Museums':  'assets/images/categories/Museumes.jpg',
    'Towers':  'assets/images/categories/Towers.jpg',
    'Bridges':  'assets/images/categories/Bridges.jpg',
    'Historic architecture':  'assets/images/categories/Historic_architecture.jpg',
    'Casino':  'assets/images/categories/Casino.jpg',
    'Resorts':  'assets/images/categories/Resort.jpg',
    'Theaters':  'assets/images/categories/Theaters.jpg',
    'Archaeology':  'assets/images/categories/Archaeology.jpg',
    'Beaches':  'assets/images/categories/Beaches.jpg',
    'Geological formations':  'assets/images/categories/Geological_formations.jpg.jpg',
    'Islands':  'assets/images/categories/Island.jpg',
    'Nature reserves':  'assets/images/categories/Nature_reserves.jpg',
    'Rivers':  'assets/images/categories/Rivers.jpg',
    'Waterfalls':  'assets/images/categories/waterfalls.jpg',
    // 'Lagoons':  'assets/images/categories/Island.jpg',
    'Lakes':  'assets/images/categories/Lakes.jpg',
    'Synagogues':  'assets/images/categories/synagogue.jpg',
    'Cathedrals':  'assets/images/categories/Cathedrals.jpg',
    'Churches':  'assets/images/categories/church.jpg',
    'Pools':  'assets/images/categories/Pools.jpg',
    'Climbing':  'assets/images/categories/Climbing.jpg',
    'Diving':  'assets/images/categories/Diving.jpg',
    'Surfing':  'assets/images/categories/Surfing.jpg',
    'Restaurants':  'assets/images/categories/Restaurants.jpg',
    'Picnic sites':  'assets/images/categories/Picnic_sites.jpg',
    'Malls':  'assets/images/categories/Malls.jpg',
    // 'Marketplaces':  'assets/images/categories/Picnic_sites.jpg',


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