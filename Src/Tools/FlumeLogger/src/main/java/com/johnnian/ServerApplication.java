package com.johnnian;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.kafka.annotation.EnableKafka;

/**
 * main 启动类
 * 
 * 运行方法： java -jar FlumeLogger.X.X.X.jar --spring.config.location=/XXXX/application.properties
 *
 */
@SpringBootApplication
@EnableKafka
public class ServerApplication 
{
    public static void main( String[] args )
    {
		new SpringApplicationBuilder(ServerApplication.class).web(true).run(args);
    }
}
