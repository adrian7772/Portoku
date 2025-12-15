class VideoItem {
  final String id;
  final String accountId;
  final String title;
  final String assetPath;


  final String description;

  final String thumbnailAsset;

  const VideoItem({
    required this.id,
    required this.accountId,
    required this.title,
    required this.assetPath,
    required this.description,
    required this.thumbnailAsset, 
  });
}
