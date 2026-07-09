package com.vithey.file;

import com.vithey.test.support.AbstractInMemoryContextTestBase;
import io.minio.MinioClient;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class FileServiceContextTest extends AbstractInMemoryContextTestBase {

  @MockBean
  private MinioClient minioClient;

  @Test
  void contextLoads() {}
}
