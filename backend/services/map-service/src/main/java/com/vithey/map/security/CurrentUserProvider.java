package com.vithey.map.security;

import com.vithey.map.exception.ApiException;
import com.vithey.map.exception.ErrorCode;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class CurrentUserProvider {

  public CurrentUser get() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    if (authentication != null && authentication.getPrincipal() instanceof CurrentUser currentUser) {
      return currentUser;
    }
    throw new ApiException(ErrorCode.UNAUTHORIZED);
  }
}
