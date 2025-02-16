#module_parameters () (SIZE := 1024);

Big_Int :: struct
{
    negative : bool;
    digits : [SIZE]u8; // stored as a decimal number
}

// TODO: I vaguely remember some mechanism to hook into the Basic print?
//       It'd be nice if print("%", my_big_int) hooked into the custom formatting
print :: (n: Big_Int)
{
    if n.negative print("-");
    printed_something := false;
    for n.digits if printed_something || it != 0
    {
        printed_something = true;
        print("%", it);
    }
    if !printed_something print("0");
    print("\n");
}

random_big_int :: (number_of_digits: s64) -> Big_Int
{
    result : Big_Int;

    while result.digits[SIZE-number_of_digits] == 0
    {
        result.digits[SIZE-number_of_digits] = cast(u8)(random_get() % 10);
    }

    for SIZE-number_of_digits+1..SIZE-1
    {
        result.digits[it] = cast(u8)(random_get() % 10);
    }

    return result;
}

big_int :: (n: s64) -> Big_Int
{
    result : Big_Int;
    result.negative = n < 0;
    
    value := ifx n < 0 then -n else n;
    index := SIZE - 1;
    while value
    {
        result.digits[index] = cast(u8, value % 10);
        value /= 10;
        index -= 1;
    }

    return result;
}

big_int :: (s: string) -> Big_Int, bool
{
    if !s.count return .{}, false;
    
    result : Big_Int;
    
    if s[0] == #char "-"
    {
        result.negative = true;
        advance(*s);
    }

    if s.count > SIZE return .{}, false;

    index := SIZE - s.count;

    while s
    {
        if s[0] < #char "0" || s[0] > #char "9" return .{}, false;
        result.digits[index] = s[0] - #char "0";
        advance(*s);
        index += 1;
    }

    return result, true;
}

operator >  :: inline (a: Big_Int, b: s64) -> bool { return a > big_int(b); }
operator <= :: inline (a: Big_Int, b: s64) -> bool { return a <= big_int(b); }
operator >= :: inline (a: Big_Int, b: s64) -> bool { return a >= big_int(b); }
operator <  :: inline (a: Big_Int, b: s64) -> bool { return a < big_int(b); }
operator >  :: inline (a: Big_Int, b: Big_Int) -> bool { return b < a; }
operator <= :: inline (a: Big_Int, b: Big_Int) -> bool { return !(a > b); }
operator >= :: inline (a: Big_Int, b: Big_Int) -> bool { return !(a < b); }
operator <  :: inline (a: Big_Int, b: Big_Int) -> bool
{
    if a.negative && !b.negative return true;
    if !a.negative && b.negative return false;

    for 0..SIZE-1
    {
        if a.digits[it] > b.digits[it] return a.negative;
        if b.digits[it] > a.digits[it] return !a.negative;
    }

    return false;
}

operator != :: inline (a: Big_Int, b: s64) -> bool { return a != big_int(b); }
operator == :: inline (a: Big_Int, b: s64) -> bool { return a == big_int(b); }
operator != :: inline (a: Big_Int, b: Big_Int) -> bool { return !(a == b); }
operator == :: inline (a: Big_Int, b: Big_Int) -> bool
{
    if a.negative != b.negative return false;

    for i: 0..a.digits.count-1
    {
        if a.digits[i] != b.digits[i] return false;
    }

    return true;
}

operator * :: inline (a: Big_Int, b: s64) -> Big_Int { return a * big_int(b); }
operator * :: inline (a: Big_Int, b: Big_Int) -> Big_Int
{
    result : Big_Int;
    result.negative = a.negative != b.negative;
    // @TODO
    return result;
}

operator % :: inline (a: Big_Int, b: s64) -> Big_Int { return a % big_int(b); }
operator % :: inline (a: Big_Int, b: Big_Int) -> Big_Int
{
    quotient, remainder := a / b;
    return remainder;
}

operator / :: inline (a: Big_Int, b: s64) -> Big_Int { return a / big_int(b); }
operator / :: inline (a: Big_Int, b: Big_Int) -> Big_Int, Big_Int
{
    // @TODO: what happens when trying to divide by -0?
    if b == 0 assert(false, "Attempt to divide by 0");

    quotient, remainder : Big_Int;
    quotient.negative = a.negative != b.negative;
    // @TODO
    return quotient, remainder;
}

operator - :: inline (a: Big_Int, b: s64) -> Big_Int { return a - big_int(b); }
operator - :: inline (a: Big_Int, b: Big_Int) -> Big_Int
{
    if a.negative != b.negative
    {
        lhs := ifx a.negative then b else a;
        rhs := ifx a.negative then a else b;
        rhs.negative = false;
        result := add_same_signed_numbers(lhs, rhs);
        result.negative = a.negative;
        return result;
    }

    lhs, rhs := a, b;
    lhs.negative = false;
    rhs.negative = false;
    if lhs < rhs then lhs, rhs = rhs, lhs;

    result : Big_Int;
    result.negative = a < b;

    borrow : u8 = 0;

    for #v2 < 0..SIZE-1
    {
        a_value := lhs.digits[it];
        b_value := rhs.digits[it];
        
        if borrow > 0
        {
            if a_value == 0
            {
                a_value = 9;
                borrow = 1;
            }
            else
            {
                a_value -= 1;
                borrow = 0;
            }
        }

        if a_value < b_value
        {
            a_value += 10;
            borrow = 1;
        }

        result.digits[it] = a_value - b_value;
    }

    return result;
}

operator + :: inline (a: Big_Int, b: s64) -> Big_Int { return a + big_int(b); }
operator + :: inline (a: Big_Int, b: Big_Int) -> Big_Int
{
    if a.negative == b.negative return add_same_signed_numbers(a, b);

    lhs := ifx a.negative then b else a;
    rhs := ifx a.negative then a else b;
    rhs.negative = false;
    return lhs - rhs;
}

#scope_file

// NOTE: this has to be a seperate procedure due to the circular dependency between binary+ and binary-
add_same_signed_numbers :: inline (a: Big_Int, b: Big_Int) -> Big_Int
{
    assert(a.negative == b.negative);

    result : Big_Int;
    result.negative = a.negative;

    carry : u8 = 0;
    
    for #v2 < 0..SIZE-1
    {
        next_digit := a.digits[it] + b.digits[it] + carry;
        carry = ifx next_digit > 9 then cast(u8, 1);
        next_digit %= 10;
        result.digits[it] = next_digit;
    }

    if carry assert(false, "Number exceeded maximum size");
    return result;
}

#import "Basic";
#import "Random";