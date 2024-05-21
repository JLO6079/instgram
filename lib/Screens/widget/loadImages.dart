import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget netWorkImage(String url) {
  return Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(width: 3),
    ),
    child: CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          //  shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Container(
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Image.network(
        'https://www.chartattack.com/wp-content/uploads/2019/07/insta.jpg',
        width: 53.0,
        height: 53.0,
      ),
    ),
  );
}

Widget circulCatchImageNetwork(String url, double size) {
  return CachedNetworkImage(
    imageUrl: url,
    imageBuilder: (context, imageProvider) => Container(
      width: MediaQuery.of(context).size.width / size,
      height: MediaQuery.of(context).size.width / size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
    ),
    placeholder: (context, url) => Container(
      width: MediaQuery.of(context).size.width / size,
      height: MediaQuery.of(context).size.width / size,
      child: const Center(child: CircularProgressIndicator()),
    ),
    errorWidget: (context, url, error) => Container(
        width: MediaQuery.of(context).size.width / size,
        height: MediaQuery.of(context).size.width / size,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                image: NetworkImage(
                    'https://www.chartattack.com/wp-content/uploads/2019/07/insta.jpg')))),
  );
}
