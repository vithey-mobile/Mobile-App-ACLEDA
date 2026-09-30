# 03 — File Service Integration Contract

> **Target Service:** `file-service`  
> **Direct Port:** `8083` | **Gateway Base URL:** `http://localhost:8080/api/v1/files`  
> **Storage Provider:** MinIO S3 Object Storage  
> **Naming Convention:** `snake_case` (Jackson globally configured)

---

## 1. Upload File (Multipart)

- **Method / Path:** `POST /api/v1/files/upload?type={type}`
- **Auth:** Bearer JWT required
- **Content-Type:** `multipart/form-data`

### Query Parameters
| Parameter | Type | Required | Values | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `type` | `string` | Yes | `"AVATAR"`, `"CV"`, `"POSTER"`, `"VIDEO"` | Determines storage bucket, validation rules, and file permissions |

### Form Data Parts
| Part Name | Type | Required | Notes |
| :--- | :--- | :--- | :--- |
| `file` | `binary` | Yes | The file payload (JPEG/PNG for images, PDF for CV, MP4 for video) |

### Flutter Dio Example
```dart
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    filePath,
    filename: fileName,
  ),
});

final response = await dio.post(
  '/files/upload',
  queryParameters: {'type': 'AVATAR'},
  data: formData,
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
```

### Response Schema (`201 Created`)
```json
{
  "data": {
    "file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
    "file_name": "avatar.png",
    "file_type": "AVATAR",
    "mime_type": "image/png",
    "size_bytes": 24576,
    "url": "http://localhost:19000/vithey/avatars/user-id/1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54/avatar.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Expires=3600...",
    "created_at": "2026-09-14T08:00:00Z"
  }
}
```

> **Note on Presigned URLs:**  
> The returned `url` is a presigned S3 URL valid for **1 hour**. For permanent references across other services (e.g. updating profile avatar or attaching media to a post), pass the **`file_id`** UUID.

---

## 2. Get File Metadata & Fresh Presigned URL

Use this endpoint when an old presigned URL has expired and you need a fresh URL.

- **Method / Path:** `GET /api/v1/files/{fileId}`
- **Auth:** Bearer JWT required
- **Headers:** `Authorization: Bearer <access_token>`

### Response Schema (`200 OK`)
```json
{
  "data": {
    "file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
    "file_name": "resume_bora.pdf",
    "file_type": "CV",
    "mime_type": "application/pdf",
    "size_bytes": 1048576,
    "url": "http://localhost:19000/vithey/cvs/user-id/resume_bora.pdf?X-Amz-Expires=3600...",
    "owner_user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "created_at": "2026-09-14T08:00:00Z"
  }
}
```

---

## 3. Direct Download File Bytes

Streams the binary file directly.

- **Method / Path:** `GET /api/v1/files/{fileId}/download`
- **Auth:** Bearer JWT required
- **Headers:** `Authorization: Bearer <access_token>`

### Access Rules
- `AVATAR`, `POSTER`, `VIDEO`: Downloadable by any authenticated user.
- `CV`: Downloadable **only by the file owner** (or application reviewer via `career-service`). Returns `403 Forbidden` if accessed by unauthorized users.

### Response
- **Status:** `200 OK`
- **Headers:**
  - `Content-Disposition: attachment; filename="resume_bora.pdf"`
  - `Content-Type: application/pdf` (or corresponding MIME type)
  - `Content-Length: <bytes>`
- **Body:** Binary stream

---

## 4. Delete File

Soft-deletes the file record and removes object from MinIO storage.

- **Method / Path:** `DELETE /api/v1/files/{fileId}`
- **Auth:** Bearer JWT required (Owner-only)

### Response
- **Status:** `204 No Content`
