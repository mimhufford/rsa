main :: ()
{
    a := big_int("10");
    b := big_int("9");

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
}

#import "Big_Int";
#import "Basic";