package com.vithey.file.service;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.vithey.file.entity.StoredFileType;
import com.vithey.file.exception.ApiException;
import com.vithey.file.exception.ErrorCode;
import org.junit.jupiter.api.Test;

class FileValidationServiceTest {

  private final FileValidationService fileValidationService = new FileValidationService();

  @Test
  void acceptsValidAvatarUpload() {
    assertThatCode(() -> fileValidationService.validateUpload(
        StoredFileType.AVATAR,
        "image/png",
        1024
    )).doesNotThrowAnyException();
  }

  @Test
  void rejectsInvalidMimeType() {
    assertThatThrownBy(() -> fileValidationService.validateUpload(
        StoredFileType.CV,
        "image/png",
        1024
    ))
        .isInstanceOf(ApiException.class)
        .extracting(exception -> ((ApiException) exception).getErrorCode())
        .isEqualTo(ErrorCode.INVALID_FILE_TYPE);
  }

  @Test
  void rejectsOversizedVideo() {
    assertThatThrownBy(() -> fileValidationService.validateUpload(
        StoredFileType.VIDEO,
        "video/mp4",
        60L * 1024 * 1024
    ))
        .isInstanceOf(ApiException.class)
        .extracting(exception -> ((ApiException) exception).getErrorCode())
        .isEqualTo(ErrorCode.FILE_TOO_LARGE);
  }
}
