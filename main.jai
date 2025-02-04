main :: ()
{
    a := big_int("15");
    b := big_int("12");

    print("======= Big_Int tests =======\n");
    print("a = ");        print(a);
    print("b = ");        print(b);
    print("a == b = ");   print("%\n", a == b);
    print("a != b = ");   print("%\n", a != b);
    print("a <  b = ");   print("%\n", a < b);
    print("a <= b = ");   print("%\n", a <= b);
    print("a >  b = ");   print("%\n", a > b);
    print("a >= b = ");   print("%\n", a >= b);
    print("a + b = ");    print(a + b);
    print("a - b = ");    print(a - b);
    print("a * b = ");    print(a * b);
    print("a / b = ");    print(a / b);
    print("a %% b = ");   print(a % b);
    print("=================\n\n");

    print("======= RSA keygen =======\n");
    p, q, n, e, d := generate_keys();
    print("p = ");   print(p);
    print("q = ");   print(q);
    print("=================\n");
    print("public n = ");   print(n);
    print("public e = ");   print(e);
    print("public d = ");   print(d);
    print("=================\n");
}

#import "Big_Int";
#import "RSA";
#import "Basic";