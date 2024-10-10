package com.ssafy.newstock.kis.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

import static lombok.AccessLevel.PROTECTED;

@Entity
@Getter
@Table(name = "prod_token2")
@NoArgsConstructor(access = PROTECTED)
public class ProdToken2 {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "value", nullable = false, unique = true)
    private String value;

    @Column(name = "created_at", nullable = false)
    private LocalDate createdAt;

    public ProdToken2(String value, LocalDate createdAt){
        this.value=value;
        this.createdAt=createdAt;
    }


}
