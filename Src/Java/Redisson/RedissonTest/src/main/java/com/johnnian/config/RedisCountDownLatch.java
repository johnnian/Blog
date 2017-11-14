package com.johnnian.config;

import java.util.concurrent.TimeUnit;

import org.apache.log4j.Logger;
import org.redisson.api.RCountDownLatch;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


@Component
public class RedisCountDownLatch {
	private static final Logger logger = Logger.getLogger(RedisCountDownLatch.class);
	private static final int DEFAULT_TIMEOUT_SECONDS = 1800;	//默认超时时间
	
	@Autowired
	private RedissonClient redissonClient;
	
	public RCountDownLatch getCountDownLatch(String name, long count){
		RCountDownLatch latch = getCountDownLatch(name);
		latch.trySetCount(count);
		return latch;
	}
	
	public RCountDownLatch getCountDownLatch(String name){
		return redissonClient.getCountDownLatch(name);
	}
	
	/**
	 * 锁等待：设置有默认超时
	 * @param latch
	 * @throws InterruptedException 
	 */
	public void await(RCountDownLatch latch) throws InterruptedException {
		if (latch != null) {
			latch.await(DEFAULT_TIMEOUT_SECONDS, TimeUnit.SECONDS);
		}
	}
	
	
}
