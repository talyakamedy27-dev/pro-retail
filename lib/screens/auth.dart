import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store.dart';
import 'shell.dart';

/// 1. Splash / Welcome
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Icon(Icons.shopping_cart, size: 90, color: c),
            const SizedBox(height: 16),
            const Text('POS Retail Pro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Manage your business\nanytime, anywhere', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            const Spacer(),
            FilledButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Get Started')),
            const SizedBox(height: 16),
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}

/// 2. Login / Sign up (credentials are salted + SHA-256 hashed, never stored in plain text)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(), pass = TextEditingController();
  bool hide = true, remember = true, signup = false;
  String? error;

  void submit() {
    final s = context.read<AppState>();
    if (signup) {
      final err = s.signUp(email.text, pass.text);
      if (err != null) return setState(() => error = err);
      setState(() { signup = false; error = null; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created. Please log in.')));
    } else if (s.login(email.text, pass.text)) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeShell()));
    } else {
      setState(() => error = 'Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          const SizedBox(height: 24),
          Text(signup ? 'Sign Up' : 'Login', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(signup ? 'Create your account' : 'Sign in to your account', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline), hintText: 'Email')),
          const SizedBox(height: 14),
          TextField(controller: pass, obscureText: hide, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), hintText: 'Password', suffixIcon: IconButton(icon: Icon(hide ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => hide = !hide)))),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: Colors.red))),
          if (!signup) Row(children: [
            Checkbox(value: remember, onChanged: (v) => setState(() => remember = v ?? true)),
            const Text('Remember me'), const Spacer(),
            TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact your administrator to reset your password'))), child: const Text('Forgot password?')),
          ]) else const SizedBox(height: 12),
          FilledButton(onPressed: submit, child: Text(signup ? 'Create Account' : 'Login')),
          const SizedBox(height: 16),
          Center(child: TextButton(onPressed: () => setState(() { signup = !signup; error = null; }), child: Text(signup ? 'Already have an account? Login' : "Don't have an account? Sign Up"))),
          if (!signup) Center(child: Text('Demo: owner@business.com / admin123', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
        ]),
      ),
    );
  }
}
