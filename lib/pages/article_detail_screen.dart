import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:video_player/video_player.dart";
import "package:youtube_player_flutter/youtube_player_flutter.dart";

class ArticleDetailScreen extends StatefulWidget {
  final String title;
  final String content;
  final String imageUrl;
  final String videoUrl;

  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.videoUrl,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  String? _downloadUrl;
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _setupVideoController();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl.startsWith('gs://')) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(widget.imageUrl);
        final url = await ref.getDownloadURL();
        setState(() {
          _downloadUrl = url;
        });
      } catch (e) {
        print('Hiba a letöltési URL lekérésekor: $e');
      }
    } else {
      setState(() {
        _downloadUrl = widget.imageUrl;
      });
    }
  }

  void _setupVideoController() {
    if (widget.videoUrl.isEmpty) return;

    final isYouTube = YoutubePlayer.convertUrlToId(widget.videoUrl) != null;

    if (isYouTube) {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl)!;
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false),
      );
    } else {
      _videoController = VideoPlayerController.network(widget.videoUrl);
      _initializeVideoPlayerFuture = _videoController!.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_downloadUrl != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.network(
                    _downloadUrl!, // works well if I set the storage rules well --> Auth, Sign In
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (_youtubeController != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
                  ),
                ),
              if (_videoController != null &&
                  _initializeVideoPlayerFuture != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              VideoPlayer(_videoController!),
                              VideoProgressIndicator(_videoController!,
                                  allowScrubbing: true),
                              Center(
                                child: IconButton(
                                  icon: Icon(
                                    _videoController!.value.isPlaying
                                        ? Icons.pause_circle
                                        : Icons.play_circle,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _videoController!.value.isPlaying
                                          ? _videoController!.pause()
                                          : _videoController!.play();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ),
            ],
          ),
        ));
  }
}
