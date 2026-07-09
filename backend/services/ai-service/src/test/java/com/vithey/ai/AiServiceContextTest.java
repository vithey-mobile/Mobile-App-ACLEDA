package com.vithey.ai;

import com.vithey.test.support.AbstractInMemoryContextTestBase;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class AiServiceContextTest extends AbstractInMemoryContextTestBase {

  @Test
  void contextLoads() {}
}
