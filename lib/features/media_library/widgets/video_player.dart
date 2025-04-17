import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class MediaVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool showControls;
  final VoidCallback onToggleControls;
  const MediaVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.showControls,
    required this.onToggleControls,
  });

  @override
  State<MediaVideoPlayer> createState() => _MediaVideoPlayerState();
}

class _MediaVideoPlayerState extends State<MediaVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
        _errorMessage = '';
      });
    } on PlatformException catch (e) {
      print('Error initializing video player: $e');
      String message = 'Could not load video.';
      if (e.code == 'VideoError' &&
          e.message?.contains('NO_EXCEEDS_CAPABILITIES') == true) {
        message = 'Video format not supported by this device.';
      }
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _errorMessage = message; // Set the error message
        });
      }
    } catch (e) {
      print('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != '') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: widget.onToggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (widget.showControls)
            IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),
          if (widget.showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black26,
                child: Container(
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    colors: VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.grey.withAlpha(90),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
