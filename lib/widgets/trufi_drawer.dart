import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trufi_app/blocs/preferences_bloc.dart';
import 'package:trufi_app/pages/about.dart';
import 'package:trufi_app/configuration.dart';
import 'package:trufi_app/pages/feedback.dart';
import 'package:trufi_app/pages/home.dart';
import 'package:trufi_app/pages/team.dart';
import 'package:trufi_app/trufi_localizations.dart';

class TrufiDrawer extends StatefulWidget {
  TrufiDrawer(this.currentRoute);

  final String currentRoute;

  @override
  TrufiDrawerState createState() => TrufiDrawerState();
}

class TrufiDrawerState extends State<TrufiDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        localizations.title,
                        style: theme.textTheme.title,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Text(
                          localizations.tagLine,
                          style: theme.textTheme.subhead,
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(color: theme.primaryColor),
                ),
                _buildListItem(
                  Icons.linear_scale,
                  localizations.menuConnections,
                  HomePage.route,
                ),
                _buildListItem(
                  Icons.info,
                  localizations.menuAbout,
                  AboutPage.route,
                ),
                _buildListItem(
                  Icons.create,
                  localizations.menuFeedback,
                  FeedbackPage.route,
                ),
                _buildListItem(
                  Icons.people,
                  localizations.menuTeam,
                  TeamPage.route,
                ),
                Divider(),
                // FIXME: For now we do not provide this option
                //_buildOfflineToggle(context),
                _buildLanguageDropdownButton(context),
              ],
            ),
          ),
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData iconData, String title, String route) {
    bool isSelected = widget.currentRoute == route;
    return Container(
      color: isSelected ? Colors.grey[300] : null,
      child: ListTile(
        leading: Icon(iconData, color: isSelected ? Colors.black : Colors.grey),
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).textTheme.body2.color),
        ),
        selected: isSelected,
        onTap: () {
          Navigator.popUntil(context, ModalRoute.withName(HomePage.route));
          if (route != HomePage.route) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildLanguageDropdownButton(BuildContext context) {
    final preferencesBloc = PreferencesBloc.of(context);
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    final languageCode = localizations.locale.languageCode;
    final values = <LanguageDropdownValue>[
      LanguageDropdownValue("de", "Deutsch"),
      LanguageDropdownValue("en", "English"),
      LanguageDropdownValue("es", "Español"),
      LanguageDropdownValue("fr", "French"),
      LanguageDropdownValue("it", "Italiano"),
      LanguageDropdownValue("qu", "Quechua simi"),
    ];
    return ListTile(
      leading: Icon(Icons.language),
      title: DropdownButton<LanguageDropdownValue>(
        style: theme.textTheme.body2,
        value: values.firstWhere((value) => value.languageCode == languageCode),
        onChanged: (LanguageDropdownValue value) {
          preferencesBloc.inChangeLanguageCode.add(value.languageCode);
        },
        items: values.map((LanguageDropdownValue value) {
          return DropdownMenuItem<LanguageDropdownValue>(
            value: value,
            child: Text(
              value.languageString,
              style: theme.textTheme.body2,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOfflineToggle(BuildContext context) {
    final preferencesBloc = PreferencesBloc.of(context);
    final theme = Theme.of(context);
    final localizations = TrufiLocalizations.of(context);
    return StreamBuilder(
      stream: preferencesBloc.outChangeOnline,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        bool isOnline = snapshot.data == true;
        return SwitchListTile(
          title: Text(localizations.menuOnline),
          value: isOnline,
          onChanged: preferencesBloc.inChangeOnline.add,
          activeColor: theme.primaryColor,
          secondary: Icon(isOnline ? Icons.cloud : Icons.cloud_off),
        );
      },
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: () => launch(urlTrufi),
              child: SvgPicture.asset(
                "assets/images/icon_trufi.svg",
                height: 48.0,
              ),
            ),
            MaterialButton(
              onPressed: () => launch(urlInstagram),
              child: SvgPicture.asset(
                "assets/images/icon_instagram.svg",
                height: 48.0,
              ),
            ),
            MaterialButton(
              onPressed: () => launch(urlFacebook),
              child: SvgPicture.asset(
                "assets/images/icon_facebook.svg",
                height: 48.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrufiDrawerRoute<T> extends MaterialPageRoute<T> {
  TrufiDrawerRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class LanguageDropdownValue {
  LanguageDropdownValue(this.languageCode, this.languageString);

  final String languageCode;
  final String languageString;
}
