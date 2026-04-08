package com.demoblaze.test.runners;

import com.intuit.karate.junit5.Karate;

public class LoginRunner {
    
    @Karate.Test
    public Karate testLogin() {
        return Karate.run("classpath:users/auth/login.feature").relativeTo(getClass());
    }
}
