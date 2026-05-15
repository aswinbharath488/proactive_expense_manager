part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpIssued extends AuthState {
  const AuthOtpIssued({required this.phone, required this.response});

  final String phone;
  final SendOtpResponse response;

  @override
  List<Object?> get props => [phone, response];
}

class AuthNeedsNickname extends AuthState {
  const AuthNeedsNickname({required this.phone});
  final String phone;

  @override
  List<Object?> get props => [phone];
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthCompleted extends AuthState {
  const AuthCompleted();
}
