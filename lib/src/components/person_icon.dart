import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ninjaapp/src/models/person_bitrix.dart';

class PersonIcon extends StatefulWidget {
  final PersonBitrix person;

  const PersonIcon({super.key, required this.person});

  @override
  State<StatefulWidget> createState() => PersonIconState();
}

class PersonIconState extends State<PersonIcon> {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.person.name!,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.person.icon!,
          height: 25.0,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
