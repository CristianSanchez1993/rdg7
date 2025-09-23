import 'dart:async';
import '../repository/user_repository.dart';
import '../model/user_model.dart';

class UserBloc {
  final UserRepository _repository = UserRepository();

  final _userListController = StreamController<List<UserModel>>.broadcast();
  final _userController = StreamController<UserModel>();
  final _messageController = StreamController<String>();

  List<UserModel> _userList = [];

  Stream<List<UserModel>> get userListStream => _userListController.stream;
  Stream<UserModel> get userStream => _userController.stream;
  Stream<String> get messageStream => _messageController.stream;

  UserBloc() {
    _repository.errorStream.listen((error) {
      _messageController.sink.add(error);
    });
  }

  Future<void> loadUsers() async {
    _userList = await _repository.getUsers();
    _userListController.sink.add(_userList);
  }

  Future<void> loadUserById(String id) async {
    final user = await _repository.getUserById(id);
    if (user != null) {
      _userController.sink.add(user);
    }
  }

  Future<void> createUser(UserModel user) async {
    final createdUser = await _repository.createUser(user);
    if (createdUser != null) {
      _userList.add(createdUser);
      _userListController.sink.add(_userList.toList());
      _messageController.sink.add("Usuario creado exitosamente");
    }
  }

  Future<void> updateUser(UserModel user) async {
    final updatedUser = await _repository.updateUser(user);
    if (updatedUser != null) {
      final index = _userList.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _userList[index] = updatedUser;
        _userListController.sink.add(_userList.toList());
        _messageController.sink.add("Usuario actualizado exitosamente");
      }
    }
  }

  Future<void> deleteUser(String id) async {
    final success = await _repository.deleteUser(id);
    if (success) {
      _userList.removeWhere((u) => u.id == id);
      _userListController.sink.add(_userList.toList());
      _messageController.sink.add("Usuario eliminado exitosamente");
    }
  }

  void dispose() {
    _userListController.close();
    _userController.close();
    _messageController.close();
    _repository.dispose();
  }
}
