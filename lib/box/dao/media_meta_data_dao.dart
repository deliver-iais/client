

import 'package:deliver_flutter/box/media_meta_data.dart';

abstract class MediaMetaDataDao{
  Future save(MediaMetaData mediaMetaData);

  Future get (MediaMetaData mediaMetaData);

}
