library firebase_ui;

import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_ui/config.dart';
import 'package:flutter/material.dart';

import 'login_view.dart';
import 'utils.dart';

export 'config.dart';
export 'utils.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen(
      {Key key,
      this.title,
      this.header,
      this.footer,
      this.signUpPasswordCheck,
      this.providers,
      this.color = Colors.white,
      this.allowBackAction = true,
      this.config,
      @required this.showBar,
      @required this.avoidBottomInset,
      @required this.bottomPadding,
      @required this.horizontalPadding})
      : super(key: key);

  final String title;
  final Widget header;
  final Widget footer;
  final List<ProvidersTypes> providers;
  final Color color;
  final bool signUpPasswordCheck;
  final bool showBar;
  final bool avoidBottomInset;
  final double horizontalPadding;
  final double bottomPadding;
  final bool allowBackAction;

  /// A [Map] containing configuration items for various sign-in clients
  final Map<String, Config> config;

  @override
  _SignInScreenState createState() => new _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Widget get _header => widget.header ?? new Container();
  Widget get _footer => widget.footer ?? new Container();

  bool get _passwordCheck => widget.signUpPasswordCheck ?? false;

  Future<List<ProvidersTypes>> _providers() async {
    List<ProvidersTypes> validProviders = List.from(widget?.providers ?? [ProvidersTypes.email]);

    // Apple sign in is only available with iOS 13+, so we check
    if (Platform.isIOS && validProviders.contains(ProvidersTypes.apple)) {
      // Check iOS version
      IosDeviceInfo info = await deviceInfoPlugin.iosInfo;
      int v = int.tryParse(info.systemVersion) ?? 12;
      if (v < 13) {
        print("Cannot use Apple Sign In with an iOS version of less than 13. This version is $v");
        validProviders.remove(ProvidersTypes.apple);
      }
    }

    return validProviders;
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: widget.showBar
          ? new AppBar(
              title: new Text(widget.title),
              elevation: 4.0,
              automaticallyImplyLeading: widget.allowBackAction,
            )
          : null,
      resizeToAvoidBottomInset: widget.avoidBottomInset,
      body: new Builder(
        builder: (BuildContext context) {
          return new Container(
              decoration: new BoxDecoration(color: widget.color),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _header,
                  new Expanded(
                    child: new Padding(
                        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                        child: FutureBuilder<List<ProvidersTypes>>(
                          future: _providers(),
                          initialData: [],
                          builder: (context, AsyncSnapshot<List<ProvidersTypes>> snapshot) => LoginView(
                            providers: snapshot.data,
                            passwordCheck: _passwordCheck,
                            bottomPadding: widget.bottomPadding,
                            config: widget.config,
                          ),
                        )),
                  ),
                  _footer
                ],
              ));
        },
      ));
}
