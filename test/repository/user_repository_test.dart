import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rdg7/repository/user_repository.dart';
import 'package:rdg7/model/user_model.dart';
import '../mocks/mock_http_client.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late UserRepository repository;
  late MockClient mockClient;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  setUp(() {
    mockClient = MockClient();
    repository = UserRepository(httpClient: mockClient);
  });

  tearDown(() {
    repository.dispose();
  });

  Map<String, dynamic> userCamelExact({
    int id = 1,
    String identification = '123456',
    String passwordHash = 'hash123',
    String email = 'john@example.com',
    String firstName = 'John',
    String secondName = 'A',
    String lastName = 'Doe',
    String secondLastName = 'Smith',
    String phone = '5551234',
    bool isActive = true,
  }) => {
      'id': id,
      'identification': identification,
      'passwordHash': passwordHash,
      'email': email,
      'firstName': firstName,
      'secondName': secondName,
      'lastName': lastName,
      'secondLastName': secondLastName,
      'phone': phone,
      'isActive': isActive,
    };

  group('UserRepository Tests with Mockito', () {
  
    test('getUsers returns non-empty list on 200', () async {
      final mockResponse = {
        'success': true,
        'message': 'OK',
        'data': [ userCamelExact(id: 1) ],
      };

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final users = await repository.getUsers();
      expect(users, isNotEmpty);
      expect(users.first, isA<UserModel>());
      expect(users.first.email, 'john@example.com');
    });

    test('getUserById completes on 200 (repo may return null or a UserModel)', () async {
      final mockResponseList = {
        'success': true,
        'message': 'OK',
        'data': [ userCamelExact(id: 1) ],
      };

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponseList), 200));

      expect(repository.getUserById('1'), completes);
      final user = await repository.getUserById('1');
      expect(user, anyOf(isNull, isA<UserModel>()));
    });

    test('createUser returns created user on 201/200 (respuesta explícita)', () async {
   
      final mockResponse = {
        'success': true,
        'message': 'Created',
        'data': userCamelExact(id: 10043),
      };

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 201));

      final createdUser = await repository.createUser(UserModel(
        id: 0,
        identification: '123456',
        password: 'hash123',
        isActive: true,
        email: 'john@example.com',
        firstName: 'John',
        secondName: 'A',
        lastName: 'Doe',
        secondLastName: 'Smith',
        phone: '5551234',
      ));
      expect(createdUser.id, 10043);
      expect(createdUser.email, 'john@example.com');
    });

    test('getUsers returns [] on 500 and emits error', () async {
      final errorEmitted = expectLater(repository.errorStream, emits(isA<String>()));

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 500));

      final users = await repository.getUsers();
      await errorEmitted;

      expect(users, isEmpty);
    });

    test('createUser 400 throws (repo lanza excepción en 4xx)', () async {
      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 400));

      expect(
        () => repository.createUser(
          UserModel(
            id: 0,
            identification: '123456',
            password: 'fail',
            isActive: true,
            email: 'fail@example.com',
            firstName: 'Fail',
            secondName: '',
            lastName: '',
            secondLastName: '',
            phone: '',
          ),
        ),
        throwsException,
      );
    });

    test('updateUser throws exception (el repo devuelve 400/NotFound)', () async {
      when(mockClient.put(any, body: anyNamed('body'), headers: anyNamed('headers')))
          .thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'success': false,
            'message': 'Error al intentar actualizar el usuario: User not found with id 1',
            'data': null,
          }),
          400,
        ),
      );

      when(mockClient.patch(any, body: anyNamed('body'), headers: anyNamed('headers')))
          .thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'success': false,
            'message': 'Error al intentar actualizar el usuario: User not found with id 1',
            'data': null,
          }),
          400,
        ),
      );

      expect(
        () async => repository.updateUser(
          UserModel(
            id: 1,
            identification: '654321',
            password: 'newhash',
            isActive: true,
            email: 'jane@example.com',
            firstName: 'Jane',
            secondName: 'B',
            lastName: 'Roe',
            secondLastName: 'Smith',
            phone: '5559876',
          ),
        ),
        throwsException,
      );
    });

    test('deleteUser returns true on 204 (o 200)', () async {
      when(mockClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('', 204));

      final result = await repository.deleteUser('1');
      expect(result, isTrue);
    });

    test('deleteUser returns false on 500 and emits error', () async {
      final errorEmitted = expectLater(repository.errorStream, emits(isA<String>()));

      when(mockClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Delete error', 500));

      final result = await repository.deleteUser('1');
      await errorEmitted;

      expect(result, isFalse);
    });

    test('getUsers 200 with empty data returns []', () async {
      final body = {
        'success': true,
        'message': 'OK',
        'data': <Map<String, dynamic>>[],
      };
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(body), 200));

      final users = await repository.getUsers();
      expect(users, isEmpty);
    });

    test('getUsers 200 without data emits error and returns []', () async {
      final errorEmitted = expectLater(repository.errorStream, emits(isA<String>()));

      final body = {'success': true, 'message': 'OK'}; 
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(body), 200));

      final users = await repository.getUsers();
      await errorEmitted;

      expect(users, isEmpty);
    });

    test('getUsers malformed JSON emits error and returns []', () async {
      final errorEmitted = expectLater(repository.errorStream, emits(isA<String>()));

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('}{', 200)); 

      final users = await repository.getUsers();
      await errorEmitted;

      expect(users, isEmpty);
    });

    test('getUserById 200 with object in data returns user', () async {
      
      final body = {
        'success': true,
        'message': 'OK',
        'data': userCamelExact(
          id: 7,
          email: 'x@y.com',
          firstName: 'X',
          lastName: 'Y',
          secondName: '',
          secondLastName: '',
          phone: '',
        ),
      };

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(body), 200));

      final user = await repository.getUserById('7');
      expect(user, isNotNull);
      expect(user!.id, 7);
      expect(user.email, 'x@y.com');
    });

    test('getUserById 200 without data emits error and returns null', () async {
      final errorEmitted = expectLater(repository.errorStream, emits(isA<String>()));

      final body = {'success': true, 'message': 'OK'};
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(body), 200));

      final user = await repository.getUserById('1');
      await errorEmitted;

      expect(user, isNull);
    });

    test('getUserById 404 emits error and returns null', () async {
      final errorEmitted = expectLater(repository.errorStream, emits(isA<String>()));

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Not found', 404));

      final user = await repository.getUserById('1');
      await errorEmitted;

      expect(user, isNull);
    });

    test('createUser 200 without data throws', () async {
      final body = {'success': true, 'message': 'Created'}; 
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode(body), 200));

      expect(
        () => repository.createUser(UserModel(
          id: 0,
          identification: 'i',
          password: 'p',
          isActive: true,
          email: 'a@b.com',
          firstName: 'A',
          secondName: '',
          lastName: 'B',
          secondLastName: '',
          phone: '',
        )),
        throwsException,
      );
    });

    test('createUser 400 throws', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Bad request', 400));

      expect(
        () => repository.createUser(UserModel(
          id: 0,
          identification: 'i',
          password: 'p',
          isActive: true,
          email: 'a@b.com',
          firstName: 'A',
          secondName: '',
          lastName: 'B',
          secondLastName: '',
          phone: '',
        )),
        throwsException,
      );
    });

    test('updateUser 200 success:true returns true', () async {
      final body = {'success': true, 'message': 'Updated', 'data': null};
      when(mockClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode(body), 200));

      final ok = await repository.updateUser(UserModel(
        id: 2,
        identification: 'i',
        password: 'p',
        isActive: true,
        email: 'a@b.com',
        firstName: 'A',
        secondName: '',
        lastName: 'B',
        secondLastName: '',
        phone: '',
      ));
      expect(ok, isTrue);
    });

    test('updateUser 200 success:false throws', () async {
      final body = {'success': false, 'message': 'Oops', 'data': null};
      when(mockClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode(body), 200));

      expect(
        () => repository.updateUser(UserModel(
          id: 2,
          identification: 'i',
          password: 'p',
          isActive: true,
          email: 'a@b.com',
          firstName: 'A',
          secondName: '',
          lastName: 'B',
          secondLastName: '',
          phone: '',
        )),
        throwsException,
      );
    });

    test('deleteUser 404 returns false and emits error', () async {
      final errorEmitted = expectLater(repository.errorStream, emits(isA<String>()));

      when(mockClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Not found', 404));

      final ok = await repository.deleteUser('1');
      await errorEmitted;

      expect(ok, isFalse);
    });

    test('deleteUser client throws -> returns false and emits error', () async {
      final errorEmitted = expectLater(repository.errorStream, emits(isA<String>()));

      when(mockClient.delete(any, headers: anyNamed('headers')))
          .thenThrow(Exception('network down'));

      final ok = await repository.deleteUser('1');
      await errorEmitted;

      expect(ok, isFalse);
    });
  });
}
