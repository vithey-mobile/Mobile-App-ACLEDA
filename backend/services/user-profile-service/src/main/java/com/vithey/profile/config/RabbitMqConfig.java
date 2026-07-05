package com.vithey.profile.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMqConfig {

  public static final String USER_REGISTERED_QUEUE = "user-profile.user.registered";
  public static final String USER_REGISTERED_ROUTING_KEY = "user.registered";

  @Bean
  TopicExchange vitheyEventsExchange(@Value("${vithey.events.exchange}") String exchangeName) {
    return new TopicExchange(exchangeName, true, false);
  }

  @Bean
  Queue userRegisteredQueue() {
    return new Queue(USER_REGISTERED_QUEUE, true);
  }

  @Bean
  Binding userRegisteredBinding(Queue userRegisteredQueue, TopicExchange vitheyEventsExchange) {
    return BindingBuilder.bind(userRegisteredQueue)
        .to(vitheyEventsExchange)
        .with(USER_REGISTERED_ROUTING_KEY);
  }
}
