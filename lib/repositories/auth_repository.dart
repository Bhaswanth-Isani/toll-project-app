import 'package:ferry/ferry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../collections/user/user.dart';
import '../graphql/login/__generated__/login.req.gql.dart';
import '../graphql/register/__generated__/register.req.gql.dart';
import '../providers/graphql_provider.dart';
import 'isar_repository.dart';

class UserOutput {
  final User? user;
  final String? error;

  UserOutput({required this.user, required this.error});
}

abstract class BaseAuthRepository {
  Future<void> loginUser({
    required String email,
    required String password,
  });

  Future<void> registerUser({
    required String fullName,
    required String email,
    required String password,
  });

  User? getUser();

  void signOut();
}

final authRepositoryProvider =
    StateNotifierProvider<AuthRepository, UserOutput>(
        (ref) => AuthRepository(ref));

class AuthRepository extends StateNotifier<UserOutput>
    implements BaseAuthRepository {
  final Ref _ref;

  AuthRepository(this._ref) : super(UserOutput(user: null, error: null)) {
    state = UserOutput(user: getUser(), error: null);
  }

  @override
  Future<void> loginUser(
      {required String email, required String password}) async {

    final loginUserReq = GLoginUserReq(
      (login) => login.vars
        ..email = email
        ..password = password,
    );

    final login = await _ref
        .read(clientProvider)
        .request(loginUserReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final user = login.data?.loginUser;

    if (user != null) {
      final finalUser = User()
        ..databaseId = user.id
        ..email = user.email
        ..fullName = user.fullName
        ..token = user.token;

      _ref.read(isarRepositoryProvider).storeUser(user: finalUser);

      state = UserOutput(
        user: finalUser,
        error: null,
      );
    } else if (login.graphqlErrors != null) {
      state = UserOutput(user: null, error: login.graphqlErrors?[0].message);
    }
  }

  @override
  Future<void> registerUser(
      {required String fullName,
      required String email,
      required String password}) async {

    final registerUserReq = GRegisterUserReq(
      (register) => register.vars
        ..fullName = fullName
        ..email = email
        ..password = password,
    );

    final register = await _ref
        .read(clientProvider)
        .request(registerUserReq)
        .firstWhere((element) => element.dataSource != DataSource.Optimistic);

    final user = register.data?.registerUser;

    if (user != null) {
      final finalUser = User()
        ..databaseId = user.id
        ..email = user.email
        ..fullName = user.fullName
        ..token = user.token;

      _ref.read(isarRepositoryProvider).storeUser(user: finalUser);

      state = UserOutput(
        user: finalUser,
        error: null,
      );
    } else if (register.graphqlErrors != null) {
      state = UserOutput(user: null, error: register.graphqlErrors?[0].message);
    }
  }

  @override
  User? getUser() {
    final Isar isar = _ref.read(isarRepositoryProvider).isar;

    final user = isar.users.getSync(1);

    return user;
  }

  @override
  void signOut() {
    final Isar isar = _ref.read(isarRepositoryProvider).isar;

    isar.writeTxnSync(() => isar.users.deleteSync(1));

    state = UserOutput(user: null, error: null);
  }
}
