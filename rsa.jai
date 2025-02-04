main :: ()
{
    // TODO: I didn't think random needed seeding, is Windows different to Linux?
    random_seed(cast,force(u64)to_milliseconds(current_time_monotonic()));

    p, q := get_prime_pair();
    n := p * q;
    e := 65537;
    d := calculate_d(e, (p-1)*(q-1));

    print("p = %\n", p);
    print("q = %\n", q);
    print("public  n = %\n", n);
    print("public  e = %\n", e);
    print("private d = %\n", d);
}

#scope_file

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
        // TODO: currently the 0x0FFF_FFFF limits the resulting p*q value to be representable by s64 
        n := cast(s64)(random_get() % 0x0FFF_FFFF);
        if is_prime(n) return n;
    }

    return 0;
}

calculate_d :: (e: s64, r: s64) -> s64
{
    m, a, y, x := r, e, 0, 1;

    while a > 1
    {
        q, t := a / m, m;
        m, a, t = a % m, t, y;
        y, x = x - q * y, t;
    }

    if x < 0 x += r;

    return x;
}

#import "Math";
#import "Basic";
#import "Random";