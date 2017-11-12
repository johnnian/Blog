package com.johnnian.test;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.junit4.SpringRunner;

import com.johnnian.App;

/**
 * 测试类
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@Import(App.class)
public class AppTest
{
	@Test
	public void hello() throws Exception{
		System.out.println("hello, test!");
	}
}
