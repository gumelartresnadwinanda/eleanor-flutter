// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../../features/media_library/models/media_item.dart';

// class MediaGridItem extends StatelessWidget {
//   final MediaItem mediaItem;
//   final VoidCallback onTap;

//   const MediaGridItem({
//     super.key,
//     required this.mediaItem,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           CachedNetworkImage(
//             imageUrl: mediaItem.gridThumbnail,
//             fit: BoxFit.cover,
//             placeholder:
//                 (context, url) => Container(
//                   color: Colors.grey[300],
//                   child: const Center(child: CircularProgressIndicator()),
//                 ),
//             errorWidget:
//                 (context, url, error) => Container(
//                   color: Colors.grey[300],
//                   child: const Icon(Icons.error),
//                 ),
//           ),
//           if (mediaItem.fileType == MediaType.video)
//             const Positioned(
//               top: 8,
//               right: 8,
//               child: Icon(
//                 Icons.play_circle_outline,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
