package com.demoblaze.test.runners;

import com.intuit.karate.junit5.Karate;

public class AllTestsRunner {
    
    @Karate.Test
    public Karate testAll() {
        return Karate.run("classpath:users/auth").relativeTo(getClass());
    }
}
