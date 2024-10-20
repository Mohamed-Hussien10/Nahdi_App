import 'package:flutter/material.dart';

class WishlistIcon extends StatefulWidget {
  const WishlistIcon({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WishlistIconState createState() => _WishlistIconState();
}

class _WishlistIconState extends State<WishlistIcon> {
  bool isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30),
      width: 55,
      height: 55,
      decoration: const BoxDecoration(
          color: Color(0xffE8E8E8),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: IconButton(
        icon: Icon(
          size: 35,
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          color: isWishlisted ? Colors.red : Colors.grey,
        ),
        onPressed: () {
          setState(() {
            isWishlisted = !isWishlisted;
          });
        },
      ),
    );
  }
}
