main :: ()
{
    a := big_int("1999");
    b := big_int("1999");

    print("a = ");
    print(a);

    print("b = ");
    print(b);

    print("a == b = "); print("%\n", a == b);
    print("a != b = "); print("%\n", a != b);
    print("a <  b = "); print("%\n", a < b);
    print("a <= b = "); print("%\n", a <= b);
    print("a >  b = "); print("%\n", a > b);
    print("a >= b = "); print("%\n", a >= b);
    print("-a = "); print(-a);
    print("-b = "); print(-b);

    print("a + b = ");
    print(a + b);

    print("a - b = ");
    print(a - b);
}

// TODO: I vaguely remember some mechanism to hook into the Basic print?
print :: (n: Big_Int)
{
    if n.negative print("-");
    for n.digits print("%", it);
    print("\n");
}

Big_Int :: struct
{
    negative : bool;
    
    // NOTE: All operations guarantee there will be no leading zeros in the digits array.
    //       This makes comparisons a much simpler, as you can rely on the array lengths.
    digits : [..]u8;
}

big_int :: (s: string) -> Big_Int, bool
{
    if s.count == 0 return .{}, true;

    result : Big_Int;

    for c: s
    {
        if c == #char "-" && result.negative return .{}, false;
        if c == #char "-" { result.negative = true; continue; }
        if c < #char "0" || c > #char "9" return .{}, false;
        array_add(*result.digits, c - #char "0");
    }

    return result, true;
}

operator >  :: inline (a: Big_Int, b: Big_Int) -> bool { return b < a; }
operator <= :: inline (a: Big_Int, b: Big_Int) -> bool { return !(a > b); }
operator >= :: inline (a: Big_Int, b: Big_Int) -> bool { return !(a < b); }
operator <  :: inline (a: Big_Int, b: Big_Int) -> bool
{
    if a.digits.count < b.digits.count return true;
    if b.digits.count < a.digits.count return false;

    for i: 0..a.digits.count-1
    {
        if a.digits[i] < b.digits[i] return true;
        if b.digits[i] < a.digits[i] return false;
    }

    return false;
}

operator != :: inline (a: Big_Int, b: Big_Int) -> bool { return !(a == b); }
operator == :: inline (a: Big_Int, b: Big_Int) -> bool
{
    if a.digits.count != b.digits.count return false;

    for i: 0..a.digits.count-1
    {
        if a.digits[i] != b.digits[i] return false;
    }

    return true;
}

operator - :: inline (n: Big_Int) -> Big_Int
{
    result : Big_Int;
    result.negative = !n.negative;
    array_add(*result.digits, ..n.digits);
    return result;
}

operator - :: inline (a: Big_Int, b: Big_Int) -> Big_Int
{
    assert(!a.negative && !b.negative);

    result : Big_Int;
    max_size := max(a.digits.count, b.digits.count);
    array_resize(*result.digits, max_size);

    remove_any_leading_zeros(*result);
    return result;
}

operator + :: inline (a: Big_Int, b: Big_Int) -> Big_Int
{
    // TODO: using unary - makes a deep copy of the digits array which isn't actually needed here
    if a.negative != b.negative return ifx a.negative then b-(-a) else a-(-b);

    result : Big_Int;
    result.negative = a.negative;
    max_size := 1 + max(a.digits.count, b.digits.count);
    array_resize(*result.digits, max_size);

    a_index := a.digits.count - 1;
    b_index := b.digits.count - 1;
    r_index := max_size - 1;

    carry : u8 = 0;
    while a_index >= 0 || b_index >= 0
    {
        defer a_index, b_index, r_index -= 1;

        a_value := ifx a_index >= 0 then a.digits[a_index];
        b_value := ifx b_index >= 0 then b.digits[b_index];
        next_digit := a_value + b_value + carry;
        carry = ifx next_digit > 9 then cast(u8)1;
        next_digit %= 10;
        result.digits[r_index] = next_digit;
    }

    result.digits[0] = carry;
    remove_any_leading_zeros(*result);
    return result;
}

#scope_file

remove_any_leading_zeros :: (n: *Big_Int)
{
    while n.digits.count && n.digits[0] == 0
    {
        array_ordered_remove_by_index(*n.digits, 0);
    }
}

#import "Basic";