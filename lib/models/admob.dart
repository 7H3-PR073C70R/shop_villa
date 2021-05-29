import 'dart:io';
class AdmobService {
  String getAdmobId() {
    if(Platform.isIOS) {
      return 'No app id';
    } else if(Platform.isAndroid ){
      return 'ca-app-pub-8536808003761128~9164325721';
    } 
    return null;
  }

  String getBannerAddId() {
    if(Platform.isIOS) {
      return 'No banner id';
    } else if(Platform.isAndroid ){
      return 'ca-app-pub-8536808003761128/3911999046';
    } 
    return null;
  }
}