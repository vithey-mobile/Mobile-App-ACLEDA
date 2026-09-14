package com.vithey.ai.exception;

import org.springframework.http.HttpStatus;

public enum ErrorCode {
  UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "Missing or invalid token"),
  FORBIDDEN(HttpStatus.FORBIDDEN, "Access denied"),
  VALIDATION_ERROR(HttpStatus.BAD_REQUEST, "Invalid request"),
  NOT_FOUND(HttpStatus.NOT_FOUND, "Resource not found"),
  RATE_LIMITED(HttpStatus.TOO_MANY_REQUESTS, "Rate limit exceeded"),
  UPSTREAM_ERROR(HttpStatus.BAD_GATEWAY, "Upstream AI service error");

  private final HttpStatus status;
  private final String defaultMessage;

  ErrorCode(HttpStatus status, String defaultMessage) {
    this.status = status;
    this.defaultMessage = defaultMessage;
  }

  public HttpStatus status() {
    return status;
  }

  public String defaultMessage() {
    return defaultMessage;
  }
}
