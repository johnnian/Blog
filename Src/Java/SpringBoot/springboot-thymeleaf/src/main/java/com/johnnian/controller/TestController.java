package com.johnnian.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class TestController {

	@RequestMapping("/")
	public String thymeleafTest() {
		return "thymeleaf";
	}

}
