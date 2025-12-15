import '../models/account.dart';
import '../models/video_item.dart';

const accounts = <Account>[
  Account(
    id: 'a1',
    username: '@arhienz',
    displayName: 'Arhienz Studio',
    bio: 'Motion Graphic',
    avatarAsset: 'assets/avatars/2.png',
    followers: 120,
    following: 80,
  ),
  Account(
    id: 'a2',
    username: '@fadli001',
    displayName: 'MFadli',
    bio: 'Gaming dan Gacha!!',
    avatarAsset: 'assets/avatars/3.png',
    followers: 305,
    following: 210,
  ),
  Account(
    id: 'a3',
    username: '@adrian7772',
    displayName: 'Adrian Yoga Pratama',
    bio: 'Video Editing',
    avatarAsset: 'assets/avatars/1.png',
    followers: 999,
    following: 123,
  ),
];

const videos = <VideoItem>[
  VideoItem(
    id: 'v1',
    accountId: 'a3',
    title: 'Video Promosi Teknologi Informasi Politap',
    assetPath: 'assets/videos/video1.mp4',
     description: 'Haii semuanya, ini adalah portofolio pertamaku di Teknologi Informasi Politap. Video ini adalah video promosi tentang jurusan TI Politap ✨',
     thumbnailAsset: 'assets/thumbs/v2.png',
  ),
  VideoItem(
    id: 'v2',
    accountId: 'a1',
    title: 'Animated Graphic Design',
    assetPath: 'assets/videos/video2.mp4',
     description: 'Portofolio Menggerakkan design grafis agar menjadi sebuah video dengan animasi yang smooth',
     thumbnailAsset: 'assets/thumbs/v3.jpg',
    
  ),
  VideoItem(
    id: 'v3',
    accountId: 'a1',
    title: 'Intro Podcast Teknologi Informasi Politap',
    assetPath: 'assets/videos/video3.mp4',
     description: 'Portofolio menganimasikan sebuah logo png agar menjadi sebuat video animasi.',
     thumbnailAsset: 'assets/thumbs/v1.png',
  ),
];


