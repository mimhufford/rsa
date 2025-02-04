main :: ()
{
    // TODO: I didn't think random needed seeding, is Windows different to Linux?
    random_seed(cast,force(u64)to_milliseconds(current_time_monotonic()));

    p, q := get_prime_pair();
    n := p * q;
    r := (p - 1) * (q - 1);
    e := 65537;
    d := calculate_d(e, r);

    print("p = %\n", p);
    print("q = %\n", q);
    print("n = %\n", n);
    print("r = %\n", r);
    print("e = %\n", e);
    print("d = %\n", d);
}

#scope_file

extended_euclidean_algorithm :: (a: s64, b: s64) -> s64
{
    old_r, r := a, b;
    old_s, s := 1, 0;
    old_t, t := 0, 1;
    
    while r != 0
    {
        quotient := old_r / r;
        old_r, r = r, old_r - quotient * r;
        old_s, s = s, old_s - quotient * s;
        old_t, t = t, old_t - quotient * t;
    }
    
    return old_r;
}

is_prime :: (n: s64) -> bool
{
    sqrt_n := cast(s64)ceil(sqrt(cast(float)n));
    for i: 2..sqrt_n if n % i == 0 return false;
	return true;
}

get_prime_pair :: () -> s64, s64
{
    p := get_random_prime_number();
    q := get_random_prime_number();
    while p == q  q = get_random_prime_number();
    return p, q;
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

calculate_d :: (e: s64, r: s64) -> s64
{
    return (extended_euclidean_algorithm(e, r) + r) % r;
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