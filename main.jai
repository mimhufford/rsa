main :: ()
{
    random_seed(cast,force(u64)to_milliseconds(current_time_monotonic()));

    a := random_big_int(2);
    b := random_big_int(2);
    a.negative = xx (random_get() & 1);
    b.negative = xx (random_get() & 1);

    print("======= Big_Int tests =======\n");
    print("a = ");        print(a);
    print("b = ");        print(b);
    print("a < b = ");    print("%\n", a < b);
    print("a == b = ");   print("%\n", a == b);
    print("a + b = ");    print(a + b);
    print("a - b = ");    print(a - b);
    print("a * b = ");    print(a * b);
    print("a / b = ");    print(a / b);
    print("=================\n");

    report_memory_leaks();
}

#import "Big_Int_Fixed";
#import "RSA";
#import "Basic"()(MEMORY_DEBUGGER=true);
#import "Random";