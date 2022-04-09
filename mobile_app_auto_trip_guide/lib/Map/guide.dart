import 'package:final_project/Map/location_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'BlurryDialog.dart';

class Guide {
  BuildContext context;
  GuideData guideData;
  Guide(this.context, this.guideData);

  void setMapPoiColor(MapPoi mapPoi, Color color) {
    mapPoi.iconButton!.iconState!.setColor(Colors.black);
  }
  handleMapPoiVoice(MapPoi mapPoi) {
    setMapPoiColor(mapPoi, Colors.black);
    BlurryDialog  alert = BlurryDialog("Do you want to hear about this poi",mapPoi.poi.poiName!,(){
      Navigator.of(context).pop();


    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );


  }
  handleMapPoiText(MapPoi mapPoi) {
    setMapPoiColor(mapPoi, Colors.black);



  }
}

// _showDialog(BuildContext context)
// {
//
//   VoidCallback continueCallBack = () => {
//     Navigator.of(context).pop(),
//     // code on continue comes here
//
//   };
//   BlurryDialog  alert = BlurryDialog("Abort","Are you sure you want to abort this operation?",continueCallBack);
//
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }