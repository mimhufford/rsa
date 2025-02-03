main :: ()
{
    // TODO: make sure p and q are different
    p := get_random_prime_number();
    q := get_random_prime_number();
    n := p * q;
    l := lcm(p - 1, q - 1);
    e := cast(u64)3;
    d := calculate_d(e, l);

    print("p = %\n", p);
    print("q = %\n", q);
    print("l = %\n", l);
    print("e = %\n", e);
    print("d = %\n", d);
}

is_prime :: (n: u64) -> bool
{
    i : u64 = 2;
    while i <= n / 2
    {
        if n % i == 0 return false;
        i += 1;
    }

	return true;
}

get_random_prime_number :: () -> u64
{
    while true
    {
        // TODO: I didn't think random needed seeding, is Windows different to Linux?
        n := random_get() % 0xFFFF;
        if is_prime(n) return n;
    }

    return 0;
}

calculate_d :: (_e: u64, l: u64) -> u64
{
    e := _e;
    d := cast(u64)1;
	eprev : u64;
    dprev : u64;
    etemp : u64;
    dtemp : u64;

	eprev = l;
    dprev = l;

	while e != 1
	{
		etemp = e;
		dtemp = d;
		e = eprev - eprev / etemp * e;
		d = dprev - eprev / etemp * d;
		eprev = etemp;
		dprev = dtemp;
		while d < 0 d += l;
	}

	return d;
}

lcm :: (a: u64, b: u64) -> u64
{
    return a / gcd(a, b) * b;
}

gcd :: (a: u64, b: u64) -> u64
{
    if b return gcd(b, a % b);
    return a;
}

#scope_file

#import "Basic";
#import "Random";