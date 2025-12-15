class Account {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String avatarAsset; 
  final int followers;
  final int following;

  const Account({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatarAsset,
    required this.followers,
    required this.following,
  });
}
