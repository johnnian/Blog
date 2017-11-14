package com.johnnian.config;

import java.util.ArrayList;
import java.util.List;

import org.redisson.Redisson;
import org.redisson.api.RedissonClient;
import org.redisson.client.codec.Codec;
import org.redisson.client.codec.StringCodec;
import org.redisson.client.protocol.Decoder;
import org.redisson.client.protocol.Encoder;
import org.redisson.config.ClusterServersConfig;
import org.redisson.config.Config;
import org.redisson.config.ReadMode;
import org.redisson.config.SubscriptionMode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Redisson分布式客户端配置
 * @author Johnnian
 *
 */
@Configuration
public class RedissonConfig {
	
	@Autowired
	private RedisClusterProperties redisClusterProperties;
	
	@Bean
    public RedissonClient redissonClient() {
		
		//Redis Cluster 配置
//		Config config = new Config();
//		config.setCodec(new StringCodec());	//无字符集编码，默认是JSON编码
//		ClusterServersConfig clusterConfig = config.useClusterServers();
		List<String>configNodes = redisClusterProperties.getNodes();
		List<String>clusterSSLNodes = new ArrayList<>();
		for (int i = 0; i < configNodes.size(); i++) {
			clusterSSLNodes.add("redis://" + configNodes.get(i));
		}
//		String[] nodes = new String[clusterSSLNodes.size()];
//		clusterSSLNodes.toArray(nodes);
//		clusterConfig.addNodeAddress(nodes);
//		clusterConfig.setSubscriptionConnectionMinimumIdleSize(redisClusterProperties.getMinIdle());
//		clusterConfig.setSubscriptionConnectionPoolSize(redisClusterProperties.getMaxTotal());
//		clusterConfig.setMasterConnectionMinimumIdleSize(redisClusterProperties.getMinIdle());
//		clusterConfig.setMasterConnectionPoolSize(redisClusterProperties.getMaxTotal());
//		clusterConfig.setSlaveConnectionMinimumIdleSize(redisClusterProperties.getMinIdle());
//		clusterConfig.setSlaveConnectionPoolSize(redisClusterProperties.getMaxTotal());
//		return Redisson.create(config);
		
		//Redis 单节点配置
		Config config = new Config();
		config.useSingleServer()
				.setIdleConnectionTimeout(10000)
				.setPingTimeout(1000)
				.setConnectTimeout(10000)
				.setTimeout(10000)
				.setRetryAttempts(3)
				.setRetryInterval(1500)
				.setReconnectionTimeout(10000)
				.setFailedAttempts(3)
				.setSubscriptionsPerConnection(5)
				.setAddress(clusterSSLNodes.get(0))
				.setSubscriptionConnectionMinimumIdleSize(1)
				.setSubscriptionConnectionPoolSize(64)
				.setConnectionMinimumIdleSize(10)
				.setConnectionPoolSize(64)
				.setDatabase(0)
				.setDnsMonitoring(false)
				.setDnsMonitoringInterval(5000);
		return  Redisson.create(config);
		
    }

}
