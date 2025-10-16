
import '/feature/middleware/domain/entity/login_entity.dart';

class LoginModel extends LoginEntity {

  final String usernme;
  final String password;
  final String db;


  const LoginModel( {required this.usernme, required this.password, required this.db})  : super(username: usernme, password: password, db: db);

  Map<String, dynamic> toJson() => {
    'UserName': username,
    'Password': password,
    'CompanyDB': db,
  };

  factory LoginModel.mapFromEntity(LoginEntity entity) => LoginModel(
    usernme: entity.username,
    password: entity.password,
    db: entity.db,
  );
}