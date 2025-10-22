import 'package:equatable/equatable.dart';

class GenreModel extends Equatable {
  final String id;
  final String name;

  const GenreModel({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
