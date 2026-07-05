package com.vithey.file.dto.response;

import com.vithey.file.entity.StoredFileType;
import java.time.OffsetDateTime;
import java.util.UUID;

public record FileUploadResponse(
    UUID fileId,
    String fileName,
    StoredFileType fileType,
    String mimeType,
    long sizeBytes,
    String url,
    OffsetDateTime createdAt
) {
}
