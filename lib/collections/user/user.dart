import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id? id = 1;

  @Index()
  late String databaseId;

  late String fullName;

  @Index(unique: true)
  late String email;

  late String token;
}
