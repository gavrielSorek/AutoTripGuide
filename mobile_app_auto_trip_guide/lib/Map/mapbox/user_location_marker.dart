import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:mapbox_gl/mapbox_gl.dart';

import '../../Utils/background_location_service.dart';
import 'animations.dart';

class LocationMarkerInfo {
  LatLng latLng;
  double heading;

  LocationMarkerInfo({required this.latLng, required this.heading});
}

abstract class UserLocationMarker {
  final MapboxMapController mapController;
  UserSymbolManager? _userSymbolManager;
  Symbol _symbol;
  late final AnimationController _moveAnimationController;
  late final AnimationController _headingAnimationController;
  LocationMarkerInfo _locationMarkerInfo =
      LocationMarkerInfo(latLng: LatLng(0, 0), heading: 0);
  dynamic onMarkerUpdated;
  late HeadingTween _headingTween;
  late LatLngTween _locationTween;
  late Animation<double> _headingAnimation;
  late Animation<LatLng> _moveAnimation;
  late VoidCallback _headingListener;
  late VoidCallback _moveListener;

  UserLocationMarker(this.mapController, this._symbol, this.onMarkerUpdated,
      this._moveAnimationController, this._headingAnimationController) {
    _headingTween = HeadingTween(
      begin: locationMarkerInfo.heading,
      end: locationMarkerInfo.heading,
    );
    // Create a Tween to animate the marker's movement
    _locationTween = LatLngTween(
      begin: locationMarkerInfo.latLng,
      end: locationMarkerInfo.latLng,
    );

    _headingAnimation = _headingTween.animate(_headingAnimationController);
    _headingListener = () {
      _locationMarkerInfo.heading = _headingAnimation.value;
      _updateSymbol();
    };
    _headingAnimation.addListener(_headingListener);

    _moveAnimation = _locationTween.animate(_moveAnimationController);
    _moveListener = () {
      _locationMarkerInfo.latLng = _moveAnimation.value;
      _updateSymbol();
    };
    _moveAnimation.addListener(_moveListener);
  }

  get locationMarkerInfo => _locationMarkerInfo;

  get headingTween => _headingTween;

  get headingAnimationController => _headingAnimationController;

  Future<void> _updateSymbol() async {
    _symbol = Symbol(
        _symbol.id,
        _symbol.options.copyWith(
          SymbolOptions(
              geometry: _locationMarkerInfo.latLng,
              iconRotate: _locationMarkerInfo.heading),
        ));
    await _userSymbolManager!.set(_symbol);
    onMarkerUpdated(_locationMarkerInfo);
  }

  Future<void> start() async {
    _userSymbolManager = UserSymbolManager(mapController,
        iconAllowOverlap: true, textAllowOverlap: true);
    // Get the user's current location
    bg.Coords position = await BackgroundLocationService.locationService.getCurrentLocation();

    // Create a LatLng object from the user's location
    LatLng userLocation = LatLng(position.latitude, position.longitude);
    _locationMarkerInfo.latLng = userLocation;
    await _userSymbolManager!.add(_symbol);
    locationMarkerInfo.heading = mapController.cameraPosition?.bearing ?? 0;
    _updateSymbol();
    BackgroundLocationService.locationService.onLocationChanged.listen((coordinates) {
        _locationTween.begin = _symbol.options.geometry;
        _locationTween.end = LatLng(coordinates.latitude, coordinates.longitude);
        // Reset and start the animation
        _moveAnimationController.reset();
        _moveAnimationController.forward();
    });
  }

  Future<void> stop() async {
    // Remove the marker from the map
    await _userSymbolManager?.remove(_symbol);
    _userSymbolManager?.dispose();
    _moveAnimationController.stop();
    _headingAnimationController.stop();
  }

  dispose() {
    _moveAnimationController.stop();
    _headingAnimationController.stop();
    _moveAnimation.removeListener(_moveListener);
    _headingAnimation.removeListener(_headingListener);
    _userSymbolManager?.dispose();
    _moveAnimationController.dispose();
    _headingAnimationController.dispose();
  }
}

class UserSymbolManager extends AnnotationManager<Symbol> {
  UserSymbolManager(
    MapboxMapController controller, {
    void Function(Symbol)? onTap,
    bool iconAllowOverlap = false,
    bool textAllowOverlap = false,
    bool iconIgnorePlacement = false,
    bool textIgnorePlacement = false,
    bool enableInteraction = true,
    bool rotateIcons = true,
  })  : _iconAllowOverlap = iconAllowOverlap,
        _textAllowOverlap = textAllowOverlap,
        _iconIgnorePlacement = iconIgnorePlacement,
        _textIgnorePlacement = textIgnorePlacement,
        super(
          controller,
          enableInteraction: enableInteraction,
          onTap: onTap,
        );

  bool _iconAllowOverlap;
  bool _textAllowOverlap;
  bool _iconIgnorePlacement;
  bool _textIgnorePlacement;

  @override
  List<LayerProperties> get allLayerProperties => [
        SymbolLayerProperties(
            iconSize: [Expressions.get, 'iconSize'],
            iconImage: [Expressions.get, 'iconImage'],
            iconRotate: [Expressions.get, 'iconRotate'],
            iconOffset: [Expressions.get, 'iconOffset'],
            iconAnchor: [Expressions.get, 'iconAnchor'],
            iconOpacity: [Expressions.get, 'iconOpacity'],
            iconColor: [Expressions.get, 'iconColor'],
            iconHaloColor: [Expressions.get, 'iconHaloColor'],
            iconHaloWidth: [Expressions.get, 'iconHaloWidth'],
            iconHaloBlur: [Expressions.get, 'iconHaloBlur'],
            // note that web does not support setting this in a fully data driven
            // way this is a upstream issue
            textFont: kIsWeb
                ? null
                : [
                    Expressions.caseExpression,
                    [Expressions.has, 'fontNames'],
                    [Expressions.get, 'fontNames'],
                    [
                      Expressions.literal,
                      ["Open Sans Regular", "Arial Unicode MS Regular"]
                    ],
                  ],
            textField: [Expressions.get, 'textField'],
            textSize: [Expressions.get, 'textSize'],
            textMaxWidth: [Expressions.get, 'textMaxWidth'],
            textLetterSpacing: [Expressions.get, 'textLetterSpacing'],
            textJustify: [Expressions.get, 'textJustify'],
            textAnchor: [Expressions.get, 'textAnchor'],
            textRotate: [Expressions.get, 'textRotate'],
            textTransform: [Expressions.get, 'textTransform'],
            textOffset: [Expressions.get, 'textOffset'],
            textOpacity: [Expressions.get, 'textOpacity'],
            textColor: [Expressions.get, 'textColor'],
            textHaloColor: [Expressions.get, 'textHaloColor'],
            textHaloWidth: [Expressions.get, 'textHaloWidth'],
            textHaloBlur: [Expressions.get, 'textHaloBlur'],
            symbolSortKey: [Expressions.get, 'zIndex'],
            iconAllowOverlap: _iconAllowOverlap,
            iconIgnorePlacement: _iconIgnorePlacement,
            textAllowOverlap: _textAllowOverlap,
            textIgnorePlacement: _textIgnorePlacement,
            iconRotationAlignment: "map")
      ];
}
