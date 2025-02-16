generate_keys :: () -> Big_Int, Big_Int, Big_Int, Big_Int, Big_Int
{
    p, q := get_prime_pair();
    n := p * q;
    e := big_int(65537);
    d := calculate_d(e, (p - 1) * (q - 1));
    return p, q, n, e, d;
}

#scope_file

is_prime :: (n: Big_Int) -> bool
{
    if n.digits[n.digits.count-1] == 0 return false;
    if n.digits[n.digits.count-1] == 2 return false;
    if n.digits[n.digits.count-1] == 4 return false;
    if n.digits[n.digits.count-1] == 5 return false;
    if n.digits[n.digits.count-1] == 6 return false;
    if n.digits[n.digits.count-1] == 8 return false;

    limit := n / 2;
    i := big_int(3);
    while i <= limit
    {
        if n % i == 0 return false;
        i = i + 2;
    }
	return true;
}

get_prime_pair :: () -> Big_Int, Big_Int
{
    // TODO: the difference between the two primes has to not be too small
    // TODO: don't generate prime numbers that are too small
    p := get_random_prime_number();
    q := get_random_prime_number();
    while p == q  q = get_random_prime_number();
    return p, q;
}

get_random_prime_number :: () -> Big_Int
{
    while true
    {
        candidate := random_big_int(2); // TODO: Currently limiting to 2 digits
        if !is_prime(candidate) continue;
        return candidate;
    }

    return big_int(0);
}

calculate_d :: (e: Big_Int, r: Big_Int) -> Big_Int
{
    m, a, y, x := r, e, big_int(0), big_int(1);

    while a > 1
    {
        q, t := a / m, m;
        m, a, t = a % m, t, y;
        y, x = x - q * y, t;
    }

    if x < 0
    {
        x = x + r;
    } 

    return x;
}

#import "Big_Int";
#import "Basic";
#import "Random";