import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:calmwaves_app/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  FirebaseStorage,
  User,
  UserCredential,
  DocumentReference,
  DocumentSnapshot,
  CollectionReference
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockUser mockUser;
  late MockUserCredential mockCredential;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockUser = MockUser();
    mockCredential = MockUserCredential();

    authService = AuthService(
      auth: mockAuth,
      firestore: mockFirestore,
      storage: mockStorage,
    );
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: child,
    );
  }

  testWidgets('login fails when fields are empty', (tester) async {
    await tester.pumpWidget(buildTestWidget(Container()));
    final context = tester.element(find.byType(Container));
    final result =
        await authService.login(context: context, email: '', password: '');
    expect(result['success'], false);
  });

  testWidgets('register fails when passwords do not match', (tester) async {
    await tester.pumpWidget(buildTestWidget(Container()));
    final context = tester.element(find.byType(Container));
    final result = await authService.register(
      context: context,
      username: 'user',
      email: 'email@test.com',
      password: 'pass123!',
      confirmPassword: 'pass123',
    );
    expect(result['success'], false);
  });

  test('validatePassword returns false for weak password', () {
    final isValid = authService.validatePassword("abc");
    expect(isValid, false);
  });

  test('validatePassword returns true for strong password', () {
    final isValid = authService.validatePassword("Abcdef!");
    expect(isValid, true);
  });

  test('sendPasswordResetEmail calls FirebaseAuth method', () async {
    when(mockAuth.sendPasswordResetEmail(email: "test@example.com"))
        .thenAnswer((_) async => {});
    await authService.sendPasswordResetEmail("test@example.com");
    verify(mockAuth.sendPasswordResetEmail(email: "test@example.com"))
        .called(1);
  });

  testWidgets('register fails with guest username', (tester) async {
    await tester.pumpWidget(buildTestWidget(Container()));
    final context = tester.element(find.byType(Container));
    final result = await authService.register(
      context: context,
      username: 'Guest#001',
      email: 'guest@example.com',
      password: 'Password!1',
      confirmPassword: 'Password!1',
    );
    expect(result['success'], false);
    expect(result['error'], isNotNull);
  });

  testWidgets('register fails with empty fields', (tester) async {
    await tester.pumpWidget(buildTestWidget(Container()));
    final context = tester.element(find.byType(Container));
    final result = await authService.register(
      context: context,
      username: '',
      email: '',
      password: '',
      confirmPassword: '',
    );
    expect(result['success'], false);
    expect(result['error'], isNotNull);
  });

  testWidgets('login fails when email is not verified', (tester) async {
    when(mockAuth.signInWithEmailAndPassword(
      email: 'test@unverified.com',
      password: 'Password!1',
    )).thenAnswer((_) async => mockCredential);
    when(mockCredential.user).thenReturn(mockUser);
    when(mockUser.emailVerified).thenReturn(false);

    await tester.pumpWidget(buildTestWidget(Container()));
    final context = tester.element(find.byType(Container));
    final result = await authService.login(
      context: context,
      email: 'test@unverified.com',
      password: 'Password!1',
    );

    expect(result['success'], false);
    expect(result['error'], isNotNull);
  });
}
