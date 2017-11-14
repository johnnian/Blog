package com.mallcoo.test;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.johnnian.App;
import com.johnnian.config.RedisCluster;

/**
 * 测试Mq sender
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = App.class)
public class AppTest
{

	@Autowired
	private RedisCluster redisCluster;
	
	@Test
	public void hello() throws Exception{
		redisCluster.set("345", "lovejohn");
		
		String string = redisCluster.get("345");
		System.out.println(string);
		
		
	}
}
