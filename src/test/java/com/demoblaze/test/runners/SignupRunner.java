package com.demoblaze.test.runners;

import com.intuit.karate.junit5.Karate;

public class SignupRunner {
    
    @Karate.Test
    public Karate testSignup() {
        return Karate.run("classpath:users/auth/signup.feature").relativeTo(getClass());
    }
}
