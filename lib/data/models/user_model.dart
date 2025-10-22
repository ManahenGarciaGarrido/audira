import 'package:equatable/equatable.dart';

enum UserRole { guest, member, artist, admin }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? username;
  final UserRole role;
  final String? profileImage;
  final DateTime? birthDate;
  final List<String> followedArtists;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    required this.role,
    this.profileImage,
    this.birthDate,
    this.followedArtists = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    username,
    role,
    profileImage,
    birthDate,
    followedArtists,
    createdAt,
  ];

  UserModel copyWith({
    String? name,
    String? username,
    String? profileImage,
    List<String>? followedArtists,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role,
      profileImage: profileImage ?? this.profileImage,
      birthDate: birthDate,
      followedArtists: followedArtists ?? this.followedArtists,
      createdAt: createdAt,
    );
  }
}
