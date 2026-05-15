import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/auth_responses.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthInitial()) {
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthCreateProfile>(_onCreateProfile);
    on<AuthReset>(_onReset);
  }

  final AuthRepository _repo;

  void _onReset(AuthReset event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }

  Future<void> _onSendOtp(AuthSendOtp event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final phone = _normalizePhone(event.rawPhone);
      final res = await _repo.sendOtp(phone);
      emit(AuthOtpIssued(phone: phone, response: res));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthOtpIssued) return;
    emit(const AuthLoading());
    try {
      if (event.code.trim() != current.response.otp) {
        emit(const AuthFailure('Invalid OTP'));
        emit(current);
        return;
      }
      if (current.response.userExists) {
        final token = current.response.token;
        final nick = current.response.nickname;
        if (token == null || token.isEmpty || nick == null || nick.isEmpty) {
          emit(const AuthFailure('Missing profile from server'));
          emit(current);
          return;
        }
        await _repo.persistSession(
          token: token,
          nickname: nick,
          phone: current.phone,
        );
        emit(const AuthCompleted());
      } else {
        emit(AuthNeedsNickname(phone: current.phone));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(current);
    }
  }

  Future<void> _onCreateProfile(
    AuthCreateProfile event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthNeedsNickname) return;
    emit(const AuthLoading());
    try {
      final nick = event.nickname.trim();
      if (nick.isEmpty) {
        emit(const AuthFailure('Enter a name'));
        emit(current);
        return;
      }
      final res = await _repo.createAccount(
        phoneE164: current.phone,
        nickname: nick,
      );
      if (res.token.isEmpty) {
        emit(const AuthFailure('No token returned'));
        emit(current);
        return;
      }
      await _repo.persistSession(
        token: res.token,
        nickname: nick,
        phone: current.phone,
      );
      emit(const AuthCompleted());
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(current);
    }
  }

  static String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '+91$digits';
    }
    if (raw.startsWith('+')) {
      return '+$digits';
    }
    return '+$digits';
  }
}
