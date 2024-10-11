package com.ssafy.newstock.auth.service;

import com.ssafy.newstock.auth.supports.CustomUserDetails;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.repository.MemberRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {
    private final MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String id) throws UsernameNotFoundException {
        Member member = memberRepository.findById(Long.valueOf(id))
                .orElseThrow(EntityNotFoundException::new);
        return new CustomUserDetails(member);
    }
}
