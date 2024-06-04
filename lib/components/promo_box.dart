import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PromoBox extends StatefulWidget {
  final EdgeInsets padding;
  final String promoPhoto;
  final String promo;
  final String promoDescription;
  const PromoBox(
      {super.key,
      required this.padding,
      required this.promoPhoto,
      required this.promo,
      required this.promoDescription});

  @override
  State<PromoBox> createState() => _PromoBoxState();
}

class _PromoBoxState extends State<PromoBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color.fromARGB(255, 72, 71, 76),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Shadow color with opacity
              spreadRadius: 0, // How far the shadow spreads
              blurRadius: 3, // How blurry the shadow is
              offset: Offset(0, 3), // Position of the shadow (x, y)
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                '${widget.promoPhoto}',
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.asset('assets/images/ComeNFixLogo.jpg');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.promo,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.promoDescription,
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
            )
          ],
        ),
      ),
    );
  }
}
