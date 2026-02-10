import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ethio_shop/providers/auth_provider.dart';
import 'package:ethio_shop/utils/ethiopian_utils.dart';
import 'package:ethio_shop/utils/validators.dart';
import 'package:ethio_shop/widgets/ethiopian_phone_field.dart';
import 'package:ethio_shop/widgets/custom_button.dart';
import 'package:ethio_shop/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _usePhoneLogin = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (_usePhoneLogin) {
        final phone = EthiopianUtils.formatPhone(_phoneController.text);
        await authProvider.loginWithPhone(phone!, _passwordController.text);
      } else {
        await authProvider.loginWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      
      // Success - navigation handled by auth provider
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              
              const SizedBox(height: 20),
              
              // Header
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Sign in to your account',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Login method toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _usePhoneLogin = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: !_usePhoneLogin ? Colors.green : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                color: !_usePhoneLogin ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _usePhoneLogin = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _usePhoneLogin ? Colors.green : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Phone',
                              style: TextStyle(
                                color: _usePhoneLogin ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Email/Phone Field
                    if (!_usePhoneLogin)
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        hintText: 'example@email.com',
                        prefixIcon: Icons.email,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                      )
                    else
                      EthiopianPhoneField(
                        controller: _phoneController,
                        labelText: 'Phone Number',
                        hintText: '0912345678',
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock,
                      obscureText: _obscurePassword,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Login Button
                    CustomButton(
                      text: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _login,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Social Login Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/images/google.png',
                            width: 24,
                            height: 24,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            padding: const EdgeInsets.all(15),
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        // Facebook
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/images/facebook.png',
                            width: 24,
                            height: 24,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            padding: const EdgeInsets.all(15),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}