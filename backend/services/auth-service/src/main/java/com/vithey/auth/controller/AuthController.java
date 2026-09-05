package com.vithey.auth.controller;

import com.vithey.auth.dto.request.ForgotPasswordRequest;
import com.vithey.auth.dto.request.LoginRequest;
import com.vithey.auth.dto.request.LogoutRequest;
import com.vithey.auth.dto.request.RefreshTokenRequest;
import com.vithey.auth.dto.request.RegisterRequest;
import com.vithey.auth.dto.request.ResetPasswordRequest;
import com.vithey.auth.dto.request.VerifyEmailRequest;
import com.vithey.auth.dto.response.AuthResponse;
import com.vithey.auth.dto.response.MessageResponse;
import com.vithey.auth.dto.response.TokenResponse;
import com.vithey.auth.dto.response.UserAuthResponse;
import com.vithey.auth.security.CurrentUserProvider;
import com.vithey.auth.service.AuthService;
import com.vithey.auth.service.PasswordResetService;
import com.vithey.auth.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Auth", description = "Registration, login, token rotation, and account verification")
public class AuthController {

  private final AuthService authService;
  private final PasswordResetService passwordResetService;
  private final CurrentUserProvider currentUserProvider;

  public AuthController(
      AuthService authService,
      PasswordResetService passwordResetService,
      CurrentUserProvider currentUserProvider
  ) {
    this.authService = authService;
    this.passwordResetService = passwordResetService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping("/register")
  @Operation(summary = "Create account", description = "Registers a USER or COMPANY account and returns JWT tokens.")
  public ResponseEntity<ApiResponseWrapper<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponseWrapper.success(authService.register(request)));
  }

  @PostMapping("/login")
  @Operation(summary = "Login", description = "Logs in by email or phone and returns JWT tokens.")
  public ResponseEntity<ApiResponseWrapper<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
    return ResponseEntity.ok(ApiResponseWrapper.success(authService.login(request)));
  }

  @PostMapping("/refresh")
  @Operation(summary = "Rotate refresh token", description = "Validates and revokes the old refresh token, then issues new tokens.")
  public ResponseEntity<ApiResponseWrapper<TokenResponse>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
    return ResponseEntity.ok(ApiResponseWrapper.success(authService.refresh(request.refreshToken())));
  }

  @PostMapping("/forgot-password")
  @Operation(summary = "Start password reset", description = "Creates a reset token when the email exists; response is always generic.")
  public ResponseEntity<ApiResponseWrapper<MessageResponse>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
    passwordResetService.startReset(request.email());
    return ResponseEntity.ok(ApiResponseWrapper.success(new MessageResponse("If the email exists, a password reset was started.")));
  }

  @PostMapping("/reset-password")
  @Operation(summary = "Reset password", description = "Completes password reset using a valid one-time token.")
  public ResponseEntity<ApiResponseWrapper<MessageResponse>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
    passwordResetService.resetPassword(request.token(), request.newPassword());
    return ResponseEntity.ok(ApiResponseWrapper.success(new MessageResponse("Password reset successfully.")));
  }

  @PostMapping("/verify-email")
  @Operation(summary = "Verify email", description = "Marks the email as verified using a valid one-time token.")
  public ResponseEntity<ApiResponseWrapper<MessageResponse>> verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
    authService.verifyEmail(request.token());
    return ResponseEntity.ok(ApiResponseWrapper.success(new MessageResponse("Email verified successfully.")));
  }

  @PostMapping("/logout")
  @Operation(summary = "Logout", description = "Revokes the submitted refresh token.")
  public ResponseEntity<Void> logout(@Valid @RequestBody LogoutRequest request) {
    authService.logout(request.refreshToken());
    return ResponseEntity.noContent().build();
  }

  @GetMapping("/me")
  @Operation(summary = "Current user", description = "Returns the authenticated identity and roles.")
  public ResponseEntity<ApiResponseWrapper<UserAuthResponse>> me() {
    return ResponseEntity.ok(ApiResponseWrapper.success(
        authService.getMe(currentUserProvider.requireCurrentUser().userId())
    ));
  }
}
