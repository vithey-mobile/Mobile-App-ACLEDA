package com.vithey.file.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.vithey.file.entity.StoredFileType;
import java.time.OffsetDateTime;
import java.util.UUID;

public record FileMetadataResponse(
    UUID fileId,
    String fileName,
    @JsonProperty("type") StoredFileType fileType,
    String mimeType,
    long sizeBytes,
    String url,
    UUID ownerUserId,
    OffsetDateTime createdAt
) {
}
