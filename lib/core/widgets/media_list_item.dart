// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../../features/media_library/models/media_item.dart';

// class MediaListItem extends StatelessWidget {
//   final MediaItem mediaItem;
//   final VoidCallback onTap;

//   const MediaListItem({
//     super.key,
//     required this.mediaItem,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: SizedBox(
//               width: 80,
//               height: 80,
//               child: CachedNetworkImage(
//                 imageUrl: mediaItem.listThumbnail,
//                 fit: BoxFit.cover,
//                 placeholder:
//                     (context, url) => Container(
//                       color: Colors.grey[300],
//                       child: const Center(child: CircularProgressIndicator()),
//                     ),
//                 errorWidget:
//                     (context, url, error) => Container(
//                       color: Colors.grey[300],
//                       child: const Icon(Icons.error),
//                     ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   mediaItem.title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   mediaItem.date.toString(),
//                   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//           if (mediaItem.fileType == MediaType.video)
//             const Padding(
//               padding: EdgeInsets.only(left: 8),
//               child: Icon(Icons.play_circle_outline, color: Colors.grey),
//             ),
//         ],
//       ),
//     );
//   }
// }
