import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../shell/main_shell.dart';
import 'name_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _len = 6;
  final _nodes = List.generate(_len, (_) => FocusNode());
  final _controllers = List.generate(_len, (_) => TextEditingController());
  int _resend = 32;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final issued = context.read<AuthBloc>().state;
      if (issued is AuthOtpIssued) {
        final otp = issued.response.otp.padRight(_len, ' ');
        for (var i = 0; i < _len && i < otp.length; i++) {
          _controllers[i].text = otp[i].trim().isEmpty ? '' : otp[i];
        }
      }
      _nodes.first.requestFocus();
    });
    Future<void>.delayed(const Duration(seconds: 1), _tickResend);
  }

  void _tickResend() async {
    if (!mounted) return;
    if (_resend <= 0) return;
    setState(() => _resend--);
    await Future<void>.delayed(const Duration(seconds: 1));
    _tickResend();
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = TextSelection.collapsed(
        offset: _controllers[index].text.length,
      );
    }
    if (value.isNotEmpty && index < _len - 1) {
      _nodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthNeedsNickname) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const NameScreen()),
          );
        } else if (state is AuthCompleted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const MainShell()),
            (r) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.inputFill,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.chevron_left, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  'Verify OTP',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is! AuthOtpIssued) {
                      return const SizedBox.shrink();
                    }
                    final masked = maskPhone(state.phone);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter the 6-Digit code sent to $masked',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: AppColors.primaryBlue,
                          ),
                          child: const Text('Change Number'),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Test OTP: ${state.response.otp}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                Row(
                  children: List.generate(_len, (i) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _nodes[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (v) => _onChanged(i, v),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                      ),
                      onPressed: loading || _code.length != _len
                          ? null
                          : () {
                              context.read<AuthBloc>().add(AuthVerifyOtp(_code));
                            },
                      child: loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verify'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  _resend > 0
                      ? 'Resend OTP in ${_resend}s'
                      : 'You can request resend from the previous screen.',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
