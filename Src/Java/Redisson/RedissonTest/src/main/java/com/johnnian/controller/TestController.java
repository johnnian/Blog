package com.johnnian.controller;

import java.util.UUID;

import org.apache.log4j.Logger;
import org.redisson.api.RLock;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.johnnian.config.RedisCluster;
import com.johnnian.config.RedisLock;

@RestController
public class TestController {

    private final Logger logger = Logger.getLogger(getClass());

	@Autowired
	private RedisLock redisLock;
	
	@Autowired
	private RedisCluster redisCluster;
	
	@RequestMapping("/redissonlock")
	public String redissonLock() {
		
		try {
			String uuid = UUID.randomUUID().toString();
			RLock lock = redisLock.getLock(uuid);
			redisLock.lock(lock);
			Thread.currentThread().sleep(1000);
			redisLock.unlock(lock);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			logger.error("Sleep 异常："+e);
		} catch (Exception e) {
			// TODO: handle exception
			logger.error(e);
		}
		
		return "success";
	}
	
	@RequestMapping("/redisrw")
	public String redisrw() {
		
		try {
			String uuid = UUID.randomUUID().toString();
			redisCluster.set(uuid, "hello, world!");
			String value = redisCluster.get(uuid);
		} catch (Exception e) {
			// TODO: handle exception
			logger.error(e);
		}
		
		return "success";
	}

}
