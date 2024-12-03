pragma circom 2.0.0;

template Factorization(n) {
    signal input address;
    signal input a;
    signal input b;

    a * b === n;
}

component main {public [address]} = Factorization(42);