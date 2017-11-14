package com.johnnian.config;

import org.redisson.api.RBucket;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import redis.clients.jedis.JedisCluster;

@Component
public class RedisCluster{
		
	
	@Autowired
	private RedissonClient redissonClient;
	

	public String set(String key, String value){
		
		RBucket<String>bucket = redissonClient.getBucket(key);
		
		if (bucket != null) {
			bucket.set(value);
		}
		
		return value;
    }
	
	public String get(String key) {
		String value = null;
		RBucket<String>bucket = redissonClient.getBucket(key);
		if (bucket != null) {
			value = bucket.get();
		}
		return value;
	}
	
	
	
		
}
