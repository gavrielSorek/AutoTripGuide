import 'dart:async';
import 'dart:math';

import 'package:final_project/Adjusted%20Libs/story_view/story_controller.dart';
import 'package:flutter/material.dart';
import 'story_view.dart';
import 'utils.dart';

class AdjustedStoryView extends StatefulWidget {
  /// The pages to be displayed.
  final List<StoryItem?> storyItems;

  /// Callback for when a full cycle of the story is shown. This will be called
  /// each time the full story completes when [repeat] is set to `true`.
  final VoidCallback? onComplete;

  /// Callback for when a vertical swipe gesture is detected. If you do not
  /// want to listen to such event, do not provide it. For instance,
  /// for inline stories inside ListViews, it is preferable to not provide
  /// this callback to enable scroll events on the ListView.
  final Function(Direction?)? onVerticalSwipeComplete;

  /// Callback for when a story is currently being shown.
  final ValueChanged<StoryItem>? onStoryShow;

  /// Where the progress indicator should be placed.
  final ProgressPosition progressPosition;

  /// Should the story be repeated forever?
  final bool repeat;

  // Controls the playback of the stories
  final StoryController controller;

  final int maxItemsPerStory;

  final dynamic sortFunc;

  final dynamic onStoryTap;

  AdjustedStoryView({
    required this.maxItemsPerStory,
    this.sortFunc,
    required this.onComplete,
    required this.onVerticalSwipeComplete,
    required this.onStoryShow,
    required this.progressPosition,
    required this.repeat,
    required this.controller,
    required this.storyItems,
    this.onStoryTap,
  });

  @override
  State<StatefulWidget> createState() {
    return AdjustedStoryViewState();
  }
}

class AdjustedStoryViewState extends State<AdjustedStoryView> {
  int currentStoryIndex = 0;
  StoryItem? currentStory;
  late StoryView currentStoryView;
  StreamSubscription<PlaybackState>? _playbackSubscription;
  StreamSubscription<double>? _progressSubscription;
  StreamSubscription<StoryItem>? _wantedStorySubscription;
  StoryController _currentStoryViewStoryController = StoryController();

  @override
  void initState() {
    super.initState();
    _playbackSubscription =
        widget.controller.playbackNotifier.listen((playbackStatus) {
          switch (playbackStatus) {
            case PlaybackState.play:
              _currentStoryViewStoryController.play();
              break;
            case PlaybackState.pause:
              _currentStoryViewStoryController.pause();
              break;
            case PlaybackState.next:
              if (currentStory?.id == widget.storyItems[(currentStoryIndex + 1) * widget.maxItemsPerStory - 1]?.id) {
                setState(() {
                  currentStoryIndex++;
                });
              } else {
                _currentStoryViewStoryController.next();
              }
              break;
            case PlaybackState.previous:
              _currentStoryViewStoryController.previous();
              break;
          }
        });

    _progressSubscription = widget.controller.progressNotifier.listen((value) {
      _currentStoryViewStoryController.progressNotifier.add(value);
    });

    _wantedStorySubscription = widget.controller.wantedStoryItemNotifier.listen((value) {
      _currentStoryViewStoryController.wantedStoryItemNotifier.add(value);
    });

  }

  StoryView buildNewStoryView() {
    _currentStoryViewStoryController.dispose();
    _currentStoryViewStoryController = StoryController();

    return StoryView(
      controller: _currentStoryViewStoryController,
      repeat: false,
      progressPosition: widget.progressPosition,
      onStoryShow: (storyItem) {
        if (widget.onStoryShow != null) {
          currentStory = storyItem;
          widget.onStoryShow!(storyItem);
        }
      },
      onComplete: () {
        if ((currentStoryIndex + 1)* widget.maxItemsPerStory >=
                widget.storyItems.length &&
            widget.onComplete != null) {
          widget.onComplete!();
        } else {
          setState(() {
            currentStoryIndex++;
          });
        }
      },
      storyItems: _getCurrentStoryItems(),
      onStoryTap: widget.onStoryTap,
      onVerticalSwipeComplete: widget.onVerticalSwipeComplete,
    );
  }

  @override
  Widget build(BuildContext context) {
    currentStoryView = buildNewStoryView();
    return currentStoryView;
  }

  List<StoryItem?> _getCurrentStoryItems() {
    int startIndex = currentStoryIndex * widget.maxItemsPerStory;
    int endIndex = min(startIndex + widget.maxItemsPerStory, widget.storyItems.length);
    return widget.storyItems.sublist(startIndex, endIndex);
  }
  @override
  void dispose() {
    _playbackSubscription?.cancel();
    _progressSubscription?.cancel();
    _wantedStorySubscription?.cancel();
    super.dispose();
  }
}
