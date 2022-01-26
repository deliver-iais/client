import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/changelog.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NewFeatureDialog extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();

  NewFeatureDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: maxWidthOfMessage(context),
        child: ClipRRect(
          borderRadius: mainBorder,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Image(
                    image: AssetImage('assets/images/wave.png'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_i18n.get("about_update"),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        const Text(
                          "V" + VERSION,
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: ENGLISH_FEATURE_LIST.length,
                          itemBuilder: (context, index) {
                            return Text(
                              _i18n.isPersian
                                  ? FARSI_FEATURE_LIST[index]
                                  : ENGLISH_FEATURE_LIST[index],
                              style: const TextStyle(color: Colors.black54),
                              textDirection: _i18n.isPersian
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                            );
                          },
                        ),
                      )),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      child: TextButton(
                        child: Text(_i18n.get("got_it")),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
