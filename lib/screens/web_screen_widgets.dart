import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:oishi/configuration.dart';
import 'web_screen.dart';

class ReusableIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ReusableIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}

class WebScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? pageTitle;
  final bool hasPageTitle;
  final List<ButtonConfig> buttons;
  final String? logo;
  final ActionConfig? action;

  const WebScreenAppBar({
    Key? key,
    this.logo,
    required this.pageTitle,
    required this.hasPageTitle,
    required this.buttons,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: pageTitle != null && !hasPageTitle && logo != null
          ? Image.asset(
              logo!,
              width: 100,
              height: 100,
            )
          : const SizedBox(),
      actions: [
        if (Navigator.canPop(context) && action != null)
          ReusableIconButton(
            icon: action!.icon,
            onPressed: action!.onPressed,
          ),
        ...buttons.map((config) {
          return config.condition(pageTitle)
              ? ReusableIconButton(
                  icon: config.icon,
                  onPressed: config.onPressed ??
                      () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            fullscreenDialog: false,
                            builder: (BuildContext context) => WebScreen(
                              url: config.endpoint,
                              pageTitle: config.pageTitle,
                              buttons: buttons,
                              action: action,
                            ),
                          ),
                        );
                      },
                )
              : const SizedBox();
        }),
      ],
      leading: !Navigator.canPop(context) && action != null
          ? ReusableIconButton(
              icon: action!.icon,
              onPressed: action!.onPressed,
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
