import 'package:equatable/equatable.dart';

class Region extends Equatable {
  final int id;
  final String code;
  final String name;

  const Region({required this.id, required this.code, required this.name});

  @override
  List<Object?> get props => [id, code, name];
}
