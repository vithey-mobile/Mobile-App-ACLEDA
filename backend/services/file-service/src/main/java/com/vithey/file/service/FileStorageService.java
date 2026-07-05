package com.vithey.file.service;

import com.vithey.file.entity.FileMetadata;
import com.vithey.file.entity.StoredFileType;
import com.vithey.file.exception.ApiException;
import com.vithey.file.exception.ErrorCode;
import com.vithey.file.repository.FileMetadataRepository;
import io.minio.GetObjectArgs;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import io.minio.http.Method;
import java.io.InputStream;
import java.time.OffsetDateTime;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class FileStorageService {

  private final MinioClient minioClient;
  private final FileMetadataRepository fileMetadataRepository;
  private final FileValidationService fileValidationService;

  public FileStorageService(
      MinioClient minioClient,
      FileMetadataRepository fileMetadataRepository,
      FileValidationService fileValidationService
  ) {
    this.minioClient = minioClient;
    this.fileMetadataRepository = fileMetadataRepository;
    this.fileValidationService = fileValidationService;
  }

  @Transactional
  public FileMetadata upload(MultipartFile file, StoredFileType fileType, UUID ownerUserId) {
    if (file == null || file.isEmpty()) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "File is required");
    }

    String mimeType = file.getContentType();
    long sizeBytes = file.getSize();
    fileValidationService.validateUpload(fileType, mimeType, sizeBytes);

    UUID fileId = UUID.randomUUID();
    String safeFileName = fileValidationService.sanitizeFileName(file.getOriginalFilename());
    String objectKey = ownerUserId + "/" + fileId + "/" + safeFileName;

    try (InputStream inputStream = file.getInputStream()) {
      minioClient.putObject(
          PutObjectArgs.builder()
              .bucket(fileType.bucket())
              .object(objectKey)
              .stream(inputStream, sizeBytes, -1)
              .contentType(mimeType)
              .build()
      );
    } catch (Exception exception) {
      throw new ApiException(ErrorCode.INTERNAL_ERROR, "Unable to upload file");
    }

    FileMetadata metadata = new FileMetadata();
    metadata.setId(fileId);
    metadata.setOwnerUserId(ownerUserId);
    metadata.setFileName(safeFileName);
    metadata.setFileType(fileType);
    metadata.setMimeType(mimeType);
    metadata.setSizeBytes(sizeBytes);
    metadata.setBucket(fileType.bucket());
    metadata.setObjectKey(objectKey);
    return fileMetadataRepository.save(metadata);
  }

  @Transactional(readOnly = true)
  public FileMetadata requireActiveMetadata(UUID fileId) {
    return fileMetadataRepository.findByIdAndDeletedAtIsNull(fileId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
  }

  public String createPresignedUrl(FileMetadata metadata) {
    try {
      return minioClient.getPresignedObjectUrl(
          GetPresignedObjectUrlArgs.builder()
              .method(Method.GET)
              .bucket(metadata.getBucket())
              .object(metadata.getObjectKey())
              .expiry(1, TimeUnit.HOURS)
              .build()
      );
    } catch (Exception exception) {
      throw new ApiException(ErrorCode.INTERNAL_ERROR, "Unable to create file URL");
    }
  }

  public InputStream openDownloadStream(FileMetadata metadata) {
    try {
      return minioClient.getObject(
          GetObjectArgs.builder()
              .bucket(metadata.getBucket())
              .object(metadata.getObjectKey())
              .build()
      );
    } catch (Exception exception) {
      throw new ApiException(ErrorCode.NOT_FOUND, "File not found in storage");
    }
  }

  @Transactional
  public void deleteOwnedFile(UUID fileId, UUID ownerUserId) {
    FileMetadata metadata = requireActiveMetadata(fileId);
    if (!metadata.getOwnerUserId().equals(ownerUserId)) {
      throw new ApiException(ErrorCode.FORBIDDEN);
    }

    try {
      minioClient.removeObject(
          RemoveObjectArgs.builder()
              .bucket(metadata.getBucket())
              .object(metadata.getObjectKey())
              .build()
      );
    } catch (Exception exception) {
      throw new ApiException(ErrorCode.INTERNAL_ERROR, "Unable to delete file from storage");
    }

    metadata.setDeletedAt(OffsetDateTime.now());
    fileMetadataRepository.save(metadata);
  }
}
