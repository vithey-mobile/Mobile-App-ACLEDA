package com.vithey.ai.config;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ChatStreamConfig {

  /**
   * Runs SSE chat streaming off the request thread. One virtual thread per
   * streamed generation keeps blocking upstream calls cheap.
   */
  @Bean(name = "aiStreamExecutor")
  Executor aiStreamExecutor() {
    return Executors.newVirtualThreadPerTaskExecutor();
  }
}
