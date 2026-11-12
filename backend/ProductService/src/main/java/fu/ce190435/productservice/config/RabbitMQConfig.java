package fu.ce190435.productservice.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    public static final String EXCHANGE = "stock.exchange";
    public static final String QUEUE = "stock.sync.queue";
    public static final String ROUTING_KEY = "stock.sync.routingKey";

    @Bean
    public TopicExchange stockExchange() {
        return new TopicExchange(EXCHANGE);
    }

    @Bean
    public Queue stockSyncQueue() {
        return QueueBuilder.durable(QUEUE).build();
    }

    @Bean
    public Binding stockBinding(Queue stockSyncQueue, TopicExchange stockExchange) {
        return BindingBuilder.bind(stockSyncQueue).to(stockExchange).with(ROUTING_KEY);
    }

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }
}
