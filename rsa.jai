main :: ()
{
    // TODO: I didn't think random needed seeding, is Windows different to Linux?
    random_seed(cast,force(u64)to_milliseconds(current_time_monotonic()));

    p := get_random_prime_number();
    q := get_random_prime_number();
    while p == q  q = get_random_prime_number();
    n := p * q;
    l := lcm(p - 1, q - 1);

    e := calculate_e(l);
    d := calculate_d(e, l);

    print("p = %\n", p);
    print("q = %\n", q);
    print("n = %\n", n);
    print("l = %\n", l);
    print("e = %\n", e);
    print("d = %\n", d);
}

#scope_file

// TODO: Most people just use a constant for this? (65537)
calculate_e :: (l: s64) -> s64
{
    while true
    {
        e := 3 + cast(s64)(random_get() % 0xFFFF) % (l - 3);
        if gcd(e, l) == 1 return e;
    }

    return 0;
}

is_prime :: (n: s64) -> bool
{
    sqrt_n := cast(s64)ceil(sqrt(cast(float)n));
    for i: 2..sqrt_n if n % i == 0 return false;
	return true;
}

get_random_prime_number :: () -> s64
{
    while true
    {
        n := cast(s64)(random_get() % 0xFFFF);
        if is_prime(n) return n;
    }

    return 0;
}

// TODO: use the extended euclid method
calculate_d :: (e: s64, l: s64) -> s64
{
    for d: 1..1000000 if d * e == 1 % l return d;
    return 0;
}

lcm :: (a: s64, b: s64) -> s64
{
    return a / gcd(a, b) * b;
}

gcd :: (a: s64, b: s64) -> s64
{
    if b return gcd(b, a % b);
    return a;
}

#import "Math";
#import "Basic";
#import "Random";