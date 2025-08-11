import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/visitor_screen/custmur.dart';
import '../../../shard/compnets/compnents.dart';
import 'cubit_login/login_cubit.dart';
import 'cubit_login/state_login_cubit.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginError || state is SignError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is LoginError ? state.error : (state as SignError).error,
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = LoginCubit.get(context);

          return Scaffold(
            backgroundColor: const Color(0xFFF5F9FC),
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Center(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                            "بريد الطرود",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "شريكك الموثوق في شحن الطرود",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/logistics.png',
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      margin: const EdgeInsets.all(20),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // علامات التبويب
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTab(context, "إنشاء حساب", 1),
                                _buildTab(context, "تسجيل الدخول", 0),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(color: Colors.orange, thickness: 2),
                            const SizedBox(height: 10),

                            // المحتوى بناءً على المؤشر المحدد
                            if (cubit.selectedIndex == 0)
                              _buildLoginForm(cubit, state),
                            if (cubit.selectedIndex == 1)
                              _buildSignupForm(cubit, state),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, int index) {
    final cubit = LoginCubit.get(context);
    bool isSelected = cubit.selectedIndex == index;

    return GestureDetector(
      onTap: () => cubit.changeTabIndex(index),
      child: Container(
        width: 150,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: isSelected ? Colors.orange : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(LoginCubit cubit, LoginState state) {
    return Form(
      key: cubit.loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "البريد الإلكتروني",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          defaultFromField(
            TextDire: TextDirection.ltr,
            controller: cubit.emailController,
            validator: cubit.validateEmail,
            textInputAction: TextInputAction.next,
            label: 'أدخل بريدك الإلكتروني',
            prefix: Icons.email_outlined,
            onSubmit: (value) {
              if (cubit.loginFormKey.currentState!.validate()) {
                FocusScope.of(context).requestFocus(cubit.passwordFocusNode);
              }
            },
            type: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          const Text(
            "كلمة المرور",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          defaultFromField(
            TextDire: TextDirection.ltr,
            controller: cubit.passwordController,
            label: 'أدخل كلمة المرور',
            prefix: Icons.lock_outline,
            validator: cubit.validatePassword,
            suffixOnPress: cubit.togglePasswordVisibility,
            onSubmit: (value) {
              if (cubit.loginFormKey.currentState!.validate()) {
                cubit.loginUser(context);
              }
            },
            textInputAction: TextInputAction.done,
            type: TextInputType.visiblePassword,
            visitPass: !cubit.isPassword,
            suffix: cubit.isPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            focus: cubit.passwordFocusNode,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => cubit.resetPassword(cubit.emailController.text, context),
                child: const Text(
                  "نسيت كلمة المرور؟",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdvancedHomeScreen()),
                  );
                },
                child: const Text(
                  "الدخول كزائر",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          state is LoginLoading
              ? const Center(child: CircularProgressIndicator())
              : defaultButton(

            width: double.infinity,

            background: Colors.orange,
            textButt: 'تسجيل الدخول',
            onPress: () => cubit.loginUser(context),
            border: 12,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(LoginCubit cubit, LoginState state) {
    return Form(
      key: cubit.signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "إنشاء حساب جديد",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // الاسم الكامل
          const Text(
            "الاسم الكامل",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          defaultFromField(
            controller: cubit.fullNameController,
            label: 'أدخل الاسم الكامل',
            textInputAction: TextInputAction.next,
            prefix: Icons.person,
            validator: (p0) => cubit.validateName(p0),
            onSubmit: (value) {
              if (cubit.signupFormKey.currentState!.validate()) {
                FocusScope.of(context).requestFocus(cubit.phoneFocusNode);
              }
            },
            type: TextInputType.name,
          ),
          const SizedBox(height: 16),
          // رقم الهاتف
          const Text(
            "رقم الهاتف",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          defaultFromField(
            controller: cubit.phoneController,
            textInputAction: TextInputAction.next,
            focus: cubit.phoneFocusNode,
            label: 'أدخل رقم الهاتف',
            prefix: Icons.phone,
            validator: cubit.validatePhone,
            onSubmit: (value) {
              if (cubit.signupFormKey.currentState!.validate()) {
                FocusScope.of(context).requestFocus(cubit.emailSignupFocusNode);
              }
            },
            type: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          // البريد الإلكتروني
          const Text(
            "البريد الإلكتروني",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          defaultFromField(
            TextDire: TextDirection.ltr,
            controller: cubit.emailSignController,
            focus: cubit.emailSignupFocusNode,
            textInputAction: TextInputAction.next,
            label: 'أدخل بريدك الإلكتروني',
            prefix: Icons.email,
            validator: cubit.validateEmail,
            onSubmit: (value) {
              if (cubit.signupFormKey.currentState!.validate()) {
                FocusScope.of(context).requestFocus(cubit.passwordSignupFocusNode);
              }
            },
            type: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          // كلمة المرور
          const Text(
            "كلمة المرور",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          defaultFromField(
            controller: cubit.passwordSignController,
            textInputAction: TextInputAction.done,
            focus: cubit.passwordSignupFocusNode,
            label: 'أدخل كلمة المرور',
            prefix: Icons.lock_outline,
            validator: cubit.validatePassword,
            suffixOnPress: cubit.togglePasswordVisibility,
            onSubmit: (value) {
              if (cubit.signupFormKey.currentState!.validate()) {
                cubit.signUpUser(context);
              }
            },
            TextDire: TextDirection.ltr,
            type: TextInputType.visiblePassword,
            visitPass: !cubit.isPassword,
            suffix: cubit.isPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,

          ),
          const SizedBox(height: 20),
          state is SignLoading
              ? const Center(child: CircularProgressIndicator())
              : defaultButton(
            width: double.infinity,
            background: Colors.orange,
            textButt: 'إنشاء حساب',
            onPress: () => cubit.signUpUser(context),
            border: 12,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}