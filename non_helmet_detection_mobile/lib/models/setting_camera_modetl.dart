class SettingCam {
  String resolution;
  String autoUpload;
  String recordVideo;
  String boundingBox;
  String tracking;

  SettingCam(this.resolution, this.autoUpload, this.recordVideo,
      this.boundingBox, this.tracking);

  Map<String, dynamic> toJson() {
    return {
      'resolution': resolution,
      'autoUpload': autoUpload,
      'recordVideo': recordVideo,
      'boundingBox': boundingBox,
      'tracking': tracking
    };
  }
}
