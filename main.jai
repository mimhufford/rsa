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
    print("a %% b = ");  print(a % b);
    print("=================\n\n");

    print("======= RSA keygen =======\n");
    p, q, n, e, d := generate_keys();
    print("p = ");   print(p);
    print("q = ");   print(q);
    print("=================\n");
    print("public  n = ");  print(n);
    print("public  e = ");  print(e);
    print("private d = ");  print(d);
    print("=================\n");

    report_memory_leaks();
}

#import "Big_Int";
#import "RSA";
#import "Basic"()(MEMORY_DEBUGGER=true);
#import "Random";