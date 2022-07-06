import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoPage extends StatefulWidget {
  String pathVideo;
  VideoPage(this.pathVideo, {Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: FutureBuilder(
            future: fileName(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data != null) {
                return snapshot.data;
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          centerTitle: true,
        ),
        body: widget.pathVideo != null
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer.file(
                  widget.pathVideo,
                  betterPlayerConfiguration: const BetterPlayerConfiguration(
                      fullScreenByDefault: true,
                      autoDetectFullscreenDeviceOrientation: true,
                      aspectRatio: 16 / 9,
                      fit: BoxFit.contain),
                ),
              )
            : const CircularProgressIndicator());
  }

  Future<Widget> fileName() async {
    String filename = widget.pathVideo.split('/').last;
    return Text(filename);
  }
}
