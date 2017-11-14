package com.johnnian.config;

import java.util.concurrent.TimeUnit;

import org.apache.log4j.Logger;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class RedisLock {

    private final Logger logger = Logger.getLogger(getClass());

	//分布式锁：qrRemoveLock
	public static final String QR_REMOVE_LOCK = "GetWuHanTianDiQrCodeTask.qrRemoveLock";
	/**
	 * 默认超时时间：操作这个时间，自动释放锁
	 */
	@SuppressWarnings("unused")
	public static final long defalutTimeoutSeconds = 1800;
	
	@Autowired
	private RedissonClient redissonClient;
	
	/**
	 * 获取锁
	 * @param name 锁的名字
	 * @return
	 */
	public RLock getLock(String name) {
		logger.info("尝试获取/创建分布式锁：" + name);
		return redissonClient.getLock(name);
	}

	/**
	 * 锁住：如果执行完之后，没有触发unlock，自动解锁
	 * @param lock
	 */
	public void lock(RLock lock) {
		// TODO Auto-generated method stub
		logger.info("分布式锁：locking..." + lock.getName() + " 默认超时(秒)：" + defalutTimeoutSeconds);
		lock.lock(defalutTimeoutSeconds, TimeUnit.SECONDS);
	}
	
	public void lock(RLock lock, long exprie){
		logger.info("分布式锁：locked，默认超时(秒)：" + defalutTimeoutSeconds);
		if (exprie <= 0){
			lock.lock(defalutTimeoutSeconds, TimeUnit.SECONDS);
		}else{
			lock.lock(exprie, TimeUnit.SECONDS);
		}
	}

	/**
	 * 解锁
	 * @param lock
	 */
	public void unlock(RLock lock) {
		// TODO Auto-generated method stub
		logger.info("分布式锁：unlock---" + lock.getName());
		lock.unlock();
	}
	
}
