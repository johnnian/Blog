package com.johnnian.listener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class TestTwoTopicListener {
	
	private Logger logger = LoggerFactory.getLogger(TestTwoTopicListener.class);

	@KafkaListener(topics = "test2")
    public void hander(String data) {
		logger.info(data);
	}
	
}
