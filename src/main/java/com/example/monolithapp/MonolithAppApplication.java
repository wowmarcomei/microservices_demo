package com.example.monolithapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class MonolithAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(MonolithAppApplication.class, args);
    }

}