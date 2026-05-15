part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSendOtp extends AuthEvent {
  const AuthSendOtp(this.rawPhone);
  final String rawPhone;

  @override
  List<Object?> get props => [rawPhone];
}

class AuthVerifyOtp extends AuthEvent {
  const AuthVerifyOtp(this.code);
  final String code;

  @override
  List<Object?> get props => [code];
}

class AuthCreateProfile extends AuthEvent {
  const AuthCreateProfile(this.nickname);
  final String nickname;

  @override
  List<Object?> get props => [nickname];
}

class AuthReset extends AuthEvent {
  const AuthReset();
}
