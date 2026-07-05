package com.vithey.file.controller;

import com.vithey.file.dto.response.FileMetadataResponse;
import com.vithey.file.dto.response.FileUploadResponse;
import com.vithey.file.entity.StoredFileType;
import com.vithey.file.security.CurrentUserProvider;
import com.vithey.file.service.FileMetadataService;
import com.vithey.file.service.FileMetadataService.DownloadPayload;
import com.vithey.file.util.ApiResponseWrapper;
import java.util.UUID;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/files")
public class FileController {

  private final FileMetadataService fileMetadataService;
  private final CurrentUserProvider currentUserProvider;

  public FileController(FileMetadataService fileMetadataService, CurrentUserProvider currentUserProvider) {
    this.fileMetadataService = fileMetadataService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  ResponseEntity<ApiResponseWrapper<FileUploadResponse>> upload(
      @RequestParam("file") MultipartFile file,
      @RequestParam("type") StoredFileType type
  ) {
    UUID ownerUserId = currentUserProvider.requireCurrentUser().userId();
    FileUploadResponse response = fileMetadataService.upload(file, type, ownerUserId);
    return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponseWrapper.success(response));
  }

  @GetMapping("/{fileId}")
  ResponseEntity<ApiResponseWrapper<FileMetadataResponse>> getFile(@PathVariable UUID fileId) {
    return ResponseEntity.ok(ApiResponseWrapper.success(fileMetadataService.getMetadata(fileId)));
  }

  @GetMapping("/{fileId}/download")
  ResponseEntity<InputStreamResource> download(@PathVariable UUID fileId) {
    UUID requesterUserId = currentUserProvider.requireCurrentUser().userId();
    DownloadPayload payload = fileMetadataService.download(fileId, requesterUserId);
    return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + payload.fileName() + "\"")
        .contentType(MediaType.parseMediaType(payload.mimeType()))
        .contentLength(payload.sizeBytes())
        .body(new InputStreamResource(payload.inputStream()));
  }

  @DeleteMapping("/{fileId}")
  ResponseEntity<Void> delete(@PathVariable UUID fileId) {
    UUID ownerUserId = currentUserProvider.requireCurrentUser().userId();
    fileMetadataService.delete(fileId, ownerUserId);
    return ResponseEntity.noContent().build();
  }
}
