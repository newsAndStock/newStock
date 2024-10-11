package com.ssafy.newstock.kis.domain;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class SocketItem {

    private int price;
    private int mount;
    private int type;

    public SocketItem(int price, int mount, int type) {
        this.price = price;
        this.mount = mount;
        this.type = type;
    }
}
