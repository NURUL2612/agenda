import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'dashboard_screen.dart';

// Data users menggunakan username dan password
const users = {
  'drible': '12345', // Username: drible, Password: 12345
  'hunter': 'hunter', // Username: hunter, Password: hunter
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  // Fungsi login menggunakan username
  Future<String?> _authUser(LoginData data) {
    debugPrint('Username: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (data.name.isEmpty) {
        return 'Username cannot be empty'; // Validasi input kosong
      }
      if (!users.containsKey(data.name)) {
        return 'Username not found'; // Username tidak ditemukan
      }
      if (users[data.name] != data.password) {
        return 'Invalid password'; // Password tidak cocok
      }
      return null; // Login berhasil
    });
  }

  // Fungsi pemulihan password
  Future<String?> _recoverPassword(String name) {
    debugPrint('Recover Username: $name');
    return Future.delayed(loginTime).then((_) {
      if (name.isEmpty) {
        return 'Username cannot be empty'; // Validasi input kosong
      }
      if (!users.containsKey(name)) {
        return 'Username does not exist'; // Username tidak ditemukan
      }
      return null; // Pemulihan berhasil
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'DPAD',
      logo: const AssetImage('assets/images/gambar1.png'),

      // Menggunakan fungsi login yang sudah dibuat
      onLogin: _authUser,

      // Fungsi pemulihan password
      onRecoverPassword: _recoverPassword,

      // Gunakan input username, bukan email
      userType: LoginUserType.name,

      // Validasi input username
      userValidator: (value) {
        if (value == null || value.isEmpty) {
          return 'Username cannot be empty';
        }
        return null;
      },

      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => DashboardScreen(),
        ));
      },

      // Pesan kustomisasi untuk UI
      messages: LoginMessages(
        userHint: 'Username', // Placeholder input username
        passwordHint: 'Password',
        loginButton: 'LOGIN',
        forgotPasswordButton: 'Forgot Password?',
        recoverPasswordButton: 'RECOVER',
        goBackButton: 'BACK',
        recoverPasswordDescription: 'Enter your username to recover your password.',
        recoverPasswordSuccess: 'Password recovery successful!',
      ),
    );
  }
} 
