import 'package:dashboard/dashborder/server/device_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controller/auth_controller.dart';
import '../home_screen.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late FocusNode _focusNodePass;
  final DeviceService _deviceService = DeviceService();
  Map<String, dynamic> deviceInfo = {};
  String? _ipAddress;
  String? _deviceName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
    _focusNodePass = FocusNode();
    _getIpAddress();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await _deviceService.getDeviceInf();
    setState(() {
      deviceInfo = info;
      _deviceName = info['model'] ?? info['name'] ?? 'Unknown Device';
      isLoading = false;
    });
  }

  // دالة للحصول على IP حقيقي
  Future<void> _getIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _ipAddress = data['ip'];
        });
      } else {
        _ipAddress = 'Unable to get IP';
      }
    } catch (e) {
      _ipAddress = 'Error: ${e.toString()}';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _focusNodePass.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    isLoading=true;

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final usersBox = await Hive.openBox<UserHive>('usersBox');

      final user = usersBox.values.firstWhere(
            (user) =>
        user.email.toLowerCase().trim() == _emailController.text.toLowerCase().trim() &&
            user.password.trim() == _passwordController.text.trim(),
      );

      if (user.id.isNotEmpty) {
        // تسجيل الدخول مع معلومات الجهاز
        await authController.login(
          userId: user.id,
          ipAddress: _ipAddress ?? 'Unknown IP',
          Name:  user.name,

        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePagesDashBoard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ البريد الإلكتروني أو كلمة المرور غير صحيحة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ حدث خطأ أثناء تسجيل الدخول: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
    }
  }

  bool isPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomePagesDashBoard()));
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 32),

                // عرض معلومات الجهاز (اختياري)
                if (!isLoading && _ipAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'الجهاز: $_deviceName\nIP: $_ipAddress',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      defaultFromField(
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        label: 'Enter your email',
                        prefix: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        onSubmit: (value) {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).requestFocus(_focusNodePass);
                          }
                        },
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      defaultFromField(
                          controller: _passwordController,
                          label: 'enter password',
                          prefix: Icons.lock_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          suffixOnPress: () {
                            setState(() {
                              isPassword = !isPassword;
                            });
                          },
                          onSubmit: (value) {
                            if (_formKey.currentState!.validate()) {
                              _login(context);
                            }
                          },
                          textInputAction: TextInputAction.done,
                          type: TextInputType.visiblePassword,
                          visitPass: isPassword,
                          suffix: isPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                  onPressed: () {
                    _login(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('تسجيل الدخول',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget defaultFromField(
      {FocusNode? focus,
        TextInputAction? textInputAction,
        required TextEditingController controller,
        TextInputType type = TextInputType.text,
        required String label,
        required IconData prefix,
        IconData? suffix,
        bool visitPass = false,
        required String? Function(String?) validator,
        void Function(String)? onSubmit,
        void Function(String)? onChange,
        void Function()? suffixOnPress}) {
    return TextFormField(
      controller: controller,
      focusNode: focus,
      textInputAction: textInputAction,
      keyboardType: type,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validator,
      obscureText: visitPass,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          prefix,
          color: Colors.white.withOpacity(0.7),
        ),
        suffixIcon: suffix != null
            ? IconButton(
          onPressed: suffixOnPress,
          icon: Icon(
            suffix,
            color: Colors.white.withOpacity(0.7),
          ),
        )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
        ),
        errorStyle: TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }
}