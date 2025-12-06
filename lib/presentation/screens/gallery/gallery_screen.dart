// lib/presentation/screens/gallery/gallery_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/custom_drawer.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        elevation: 0,
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.photo_library,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Photo Gallery',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Capturing Memorable Moments',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Gallery Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _albums.length,
                itemBuilder: (context, index) {
                  final album = _albums[index];
                  return _buildAlbumCard(context, album);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCard(BuildContext context, Map<String, dynamic> album) {
    return InkWell(
      onTap: () {
        // Navigate to album detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${album['title']}...'),
            duration: const Duration(seconds: 1),
          ),
        );
        // TODO: Implement navigation to album detail
        // Navigator.pushNamed(context, '/album', arguments: album);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Cover
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      album['color'] as Color,
                      (album['color'] as Color).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    album['icon'] as IconData,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Album Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album['title'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.photo,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${album['count']} photos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final List<Map<String, dynamic>> _albums = [
    {
      'title': 'Annual Day 2024',
      'count': 45,
      'icon': Icons.celebration,
      'color': Colors.purple,
    },
    {
      'title': 'Sports Day',
      'count': 38,
      'icon': Icons.sports,
      'color': Colors.orange,
    },
    {
      'title': 'Science Exhibition',
      'count': 52,
      'icon': Icons.science,
      'color': Colors.blue,
    },
    {
      'title': 'Cultural Programs',
      'count': 67,
      'icon': Icons.music_note,
      'color': Colors.pink,
    },
    {
      'title': 'Classroom Activities',
      'count': 84,
      'icon': Icons.school,
      'color': Colors.teal,
    },
    {
      'title': 'Field Trips',
      'count': 29,
      'icon': Icons.directions_bus,
      'color': Colors.green,
    },
    {
      'title': 'Independence Day',
      'count': 36,
      'icon': Icons.flag,
      'color': Colors.indigo,
    },
    {
      'title': 'Campus Life',
      'count': 95,
      'icon': Icons.landscape,
      'color': Colors.brown,
    },
  ];
}
