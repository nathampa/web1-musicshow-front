import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool isLoading = false;
  bool isLogin = true;

  void _toggleAuthMode() {
    setState(() => isLogin = !isLogin);
  }

  void _authenticate() async {
    if (!isLogin) {
      if (nomeController.text.isEmpty || loginController.text.isEmpty || senhaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Preencha todos os campos para se cadastrar.")),
        );
        return;
      }
    } else {
      if (loginController.text.isEmpty || senhaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Preencha todos os campos para fazer login.")),
        );
        return;
      }
    }

    setState(() => isLoading = true);
    bool success;

    if (isLogin) {
      success = await apiService.login(loginController.text, senhaController.text);
    } else {
      success = await apiService.register(nomeController.text, loginController.text, senhaController.text);
    }

    setState(() => isLoading = false);

    if (success) {
      if (isLogin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cadastro realizado com sucesso!")),
        );
        _toggleAuthMode(); // Voltar para login após cadastrar
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLogin ? "Login falhou. Verifique suas credenciais." : "Erro ao cadastrar. Tente novamente.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 400), // Define um limite de largura
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isLogin ? Icons.lock : Icons.person_add, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                isLogin ? "Bem-vindo ao Music Show" : "Criar Conta",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 20),
              if (!isLogin)
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: "Nome",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.person, color: Colors.teal),
                  ),
                ),
              if (!isLogin) const SizedBox(height: 12),
              TextField(
                controller: loginController,
                decoration: InputDecoration(
                  labelText: "Usuário",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                ),
                onSubmitted: (_) => _authenticate(), // Pressionar Enter chama _authenticate()
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isLogin ? "Entrar" : "Cadastrar", style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _toggleAuthMode,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.teal, // Cor moderna e consistente
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text(isLogin ? "Criar uma conta" : "Já tem uma conta? Faça login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
