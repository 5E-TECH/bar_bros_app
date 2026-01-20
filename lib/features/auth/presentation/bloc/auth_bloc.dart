import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:bar_bros_user/features/auth/domain/usecases/get_my_account_usecase.dart';
import 'package:bar_bros_user/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bar_bros_user/features/auth/domain/usecases/register_usecase.dart';
import 'package:bar_bros_user/features/auth/domain/usecases/set_fullName_usecase.dart';
import 'package:bar_bros_user/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';

part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase _registerUseCase;
  final VerifyCodeUseCase _verifyCodeUseCase;
  final SetFullNameUseCase _setFullNameUseCase;
  final CheckAuthUseCase _checkAuthUseCase;
  final LogOutUseCase _logOutUseCase;
  final GetMyAccountUseCase _getMyAccountUseCase;
  final LocalStorage _localStorage;

  AuthBloc(
    this._registerUseCase,
    this._verifyCodeUseCase,
    this._setFullNameUseCase,
    this._checkAuthUseCase,
    this._logOutUseCase,
    this._getMyAccountUseCase,
    this._localStorage,
  ) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<VerifyCodeEvent>(_onVerifyCode);
    on<SetFullNameEvent>(_onSetFullName);
    on<ResetAuthEvent>(_onResetAuth);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await _checkAuthUseCase(NoParams());
    final localName = await _localStorage.getUserFullName();

    if (result.isLeft()) {
      emit(const AuthUnauthenticated());
      return;
    }

    final isAuthenticated = result.getOrElse(() => false);
    if (!isAuthenticated) {
      emit(const AuthUnauthenticated());
      return;
    }

    // User has valid token - try to get account info
    final account = await _getMyAccountUseCase(NoParams());
    account.fold(
      (failure) {
        // If getMyAccount fails but user has token and saved name, consider authenticated
        // This handles the server 403 issue on my_accaunt endpoint
        if (localName != null && localName.isNotEmpty) {
          emit(AuthAuthenticated(fullName: localName, phoneNumber: ''));
        } else {
          // No saved name means user needs to complete profile
          emit(const AuthUnauthenticated());
        }
      },
      (data) => emit(
        AuthAuthenticated(
          fullName: data.fullName ?? localName,
          phoneNumber: data.phoneNumber,
        ),
      ),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await _logOutUseCase(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    await _localStorage.clearTokens();
    final result = await _registerUseCase(RegisterParams(event.phoneNumber));

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) => emit(
        RegisterSuccess(
          isNew: response.isNew,
          message: response.message,
          userId: response.userId,
        ),
      ),
    );
  }

  Future<void> _onVerifyCode(
    VerifyCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _verifyCodeUseCase(
      VerifyCodeParams(phoneNumber: event.phoneNumber, code: event.code),
    );

    if (result.isLeft()) {
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) {},
      );
      return;
    }

    final response = result.getOrElse(() => throw Exception('Unexpected error'));

    if (event.isNewUser) {
      emit(
        VerifySuccess(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      );
    } else {
      final account = await _getMyAccountUseCase(NoParams());
      account.fold(
        (failure) {
          // If getMyAccount fails (403 Forbidden), user needs to complete profile
          // Treat as new user and navigate to set fullname
          emit(
            VerifySuccess(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
            ),
          );
        },
        (data) => emit(
          AuthAuthenticated(
            fullName: data.fullName,
            phoneNumber: data.phoneNumber,
          ),
        ),
      );
    }
  }

  Future<void> _onSetFullName(
      SetFullNameEvent event,
      Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _setFullNameUseCase(SetFullNameParams(event.fullName));

    if (result.isLeft()) {
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) {},
      );
      return;
    }

    String savedName = event.fullName.trim();
    await _localStorage.saveUserFullName(savedName);

    // Skip getMyAccount call since it returns 403 (server issue)
    // Navigate directly to home with the saved name
    emit(
      AuthAuthenticated(
        fullName: savedName,
        phoneNumber: '',
      ),
    );
  }

  void _onResetAuth(ResetAuthEvent event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}
