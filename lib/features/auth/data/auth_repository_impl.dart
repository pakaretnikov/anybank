import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<bool> signIn(String email, String password) async {
    return false;
  }
}

