package com.ssafy.newstock.auth.supports;

import com.ssafy.newstock.member.domain.Member;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

public class CustomUserDetails implements UserDetails {
    private String id;
    private String password;
    private Collection<GrantedAuthority> authorities;

    public CustomUserDetails(Member member) {
        this.id = member.getId().toString();
        this.password = member.getPassword();
        this.authorities = Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + member.getRole().name()));
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return id;
    }
}
