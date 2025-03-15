import 'package:flutter/material.dart';
import '../services/api_service.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isLogin = true;
  bool obscurePassword = true;

  // Definindo as cores consistentes com HomeScreen
  static const Color mochaMousse = Color(0xFFA47864);
  static const Color backgroundColor = Color(0xFFF8F5F3);

  void _toggleAuthMode() {
    setState((){
      isLogin = !isLogin;
      nomeController.clear();
      loginController.clear();
      senhaController.clear();
    });
  }

  void _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cadastro realizado com sucesso!", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        _toggleAuthMode();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLogin ? "Login falhou. Verifique suas credenciais." : "Erro ao cadastrar. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo e Título
                        Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [mochaMousse, mochaMousse.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mochaMousse.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "MusicShow",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: mochaMousse,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Gerencie suas bandas e músicas em um só lugar",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Card Principal
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 450),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Cabeçalho do Formulário
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: mochaMousse.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isLogin ? Icons.login : Icons.person_add,
                                          color: mochaMousse,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        isLogin ? "Acesse sua conta" : "Crie sua conta",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Campos do Formulário
                                  if (!isLogin) ...[
                                    _buildInputField(
                                      controller: nomeController,
                                      label: "Nome",
                                      icon: Icons.person,
                                      validator: (value) => value!.isEmpty ? "Preencha seu nome" : null,
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  _buildInputField(
                                    controller: loginController,
                                    label: "Usuário",
                                    icon: Icons.person_outline,
                                    validator: (value) => value!.isEmpty ? "Preencha seu usuário" : null,
                                  ),

                                  const SizedBox(height: 16),

                                  _buildInputField(
                                    controller: senhaController,
                                    label: "Senha",
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    validator: (value) => value!.length < 6 ? "A senha deve ter pelo menos 6 caracteres" : null,
                                    onFieldSubmitted: (_) => _authenticate(),
                                  ),

                                  const SizedBox(height: 24),

                                  // Botão de Ação
                                  Container(
                                    width: double.infinity,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [mochaMousse, mochaMousse.withOpacity(0.8)],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: mochaMousse.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _authenticate,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : Text(
                                        isLogin ? "Entrar" : "Cadastrar",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Alternar entre Login e Cadastro
                                  Center(
                                    child: TextButton(
                                      onPressed: _toggleAuthMode,
                                      style: TextButton.styleFrom(
                                        foregroundColor: mochaMousse,
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            isLogin ? "Não tem conta? " : "Já tem uma conta? ",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black.withOpacity(0.6),
                                            ),
                                          ),
                                          Text(
                                            isLogin ? "Cadastre-se" : "Faça login",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: mochaMousse,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Informações Extras
                        Container(
                          margin: const EdgeInsets.only(top: 32),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: mochaMousse.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.info_outline, color: mochaMousse),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Sobre o MusicShow",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "O MusicShow é uma plataforma para músicos gerenciarem suas bandas, repertórios e partituras de forma simples e eficiente.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscurePassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.6),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: mochaMousse,
            width: 1.5,
          ),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: mochaMousse),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: mochaMousse,
          ),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        )
            : null,
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}