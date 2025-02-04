main :: ()
{
    a := big_int("15");
    b := big_int("12");

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
}

#import "Big_Int";
#import "Basic";