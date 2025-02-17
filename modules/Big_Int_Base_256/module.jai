#module_parameters () (SIZE := 1023);

Big_Int :: struct
{
    negative : bool;
    digits : [SIZE]u8; // base 256, e.g. 257 = [0, 0, ..., 0, 1, 1]
}

// TODO: It'd be nice if print("%", my_big_int) hooked into the custom formatting
print :: (n: Big_Int)
{
    has_any_digits := false;
    for n.digits if it != 0 { has_any_digits = true; break; }
    if !has_any_digits
    {
        print("0\n");
        return;
    }

    if n.negative print("-");

    mark := get_temporary_storage_mark();
    defer set_temporary_storage_mark(mark);
    
    // TODO: Pre-calculate the number of digits required and avoid resizing
    output : [..]u8;
    output.allocator = temp;
    
    while true
    {
        has_any_digits := false;
        for n.digits if it != 0 { has_any_digits = true; break; }
        if !has_any_digits break;

        remainder := 0;
        for * n.digits
        {
            value := remainder * 256 + it.*;
            it.* = cast(u8, value / 10);
            remainder = value % 10;
        }
        array_add(*output, cast(u8, remainder));
    }

    for < output print("%", it);
    print("\n");
}

// TODO: number_of_digits was for base 10, this doesn't make much sense now
random_big_int :: (number_of_digits: s64) -> Big_Int
{
    result : Big_Int;

    while result.digits[SIZE-number_of_digits] == 0
    {
        result.digits[SIZE-number_of_digits] = cast(u8, random_get() % 256);
    }

    for SIZE-number_of_digits+1..SIZE-1
    {
        result.digits[it] = cast(u8, random_get() % 256);
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
        result.digits[index] = cast(u8, value % 256);
        value /= 256;
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

    if !s.count return .{}, false;
    for s if it < #char "0" || it > #char "9" return .{}, false;

    mark := get_temporary_storage_mark();
    defer set_temporary_storage_mark(mark);

    digits : [..]u8;
    digits.allocator = temp;
    array_reserve(*digits, s.count);
    for s array_add(*digits, it - #char "0");

    index := SIZE - 1;
    
    while digits.count
    {
        remainder := 0;
        new_digits : [..]u8;
        new_digits.allocator = temp;
        
        for digits
        {
            current := remainder * 10 + it;
            quotient := current / 256;
            remainder = current % 256;

            if new_digits.count || quotient > 0
            {
                array_add(*new_digits, cast(u8, quotient));
            }
        }

        result.digits[index] = cast(u8, remainder);
        index -= 1;
        digits = new_digits;
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

    for i: 0..SIZE-1
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

    for #v2 < i: 0..SIZE-1
    {
        if a.digits[i] == 0 continue;

        for #v2 < j: 0..SIZE-1
        {
            if b.digits[j] == 0 continue;

            index := i + j - SIZE + 1;
            product := cast(u16, a.digits[i]) * cast(u16, b.digits[j]);
            sum := product + result.digits[index];
            result.digits[index]    = cast(u8, sum % 256);
            result.digits[index-1] += cast(u8, sum / 256);
        }
    }

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
    // @TODO: this procedure is very slow

    divisor := Big_Int.{ negative = false, digits = b.digits };

    if divisor == 0 assert(false, "Attempt to divide by 0");

    quotient, remainder : Big_Int;
    quotient.negative = a.negative != b.negative;

    for d, i: a.digits
    {
        memcpy(remainder.digits.data, remainder.digits.data + 1, SIZE - 1);
        remainder.digits[SIZE-1] = d;

        count : u8 = 0;
        while remainder >= divisor
        {
            remainder -= divisor;
            count += 1;
        }

        quotient.digits[i] = count;
    }

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

    borrow : u16 = 0;

    for #v2 < 0..SIZE-1
    {
        a_value := cast(u16, lhs.digits[it]);
        b_value := cast(u16, rhs.digits[it]);

        if borrow > 0
        {
            if a_value == 0
            {
                a_value = 255;
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
            a_value += 256;
            borrow = 1;
        }

        result.digits[it] = cast(u8, a_value - b_value);
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

    carry : u16 = 0;

    for #v2 < 0..SIZE-1
    {
        next_digit := cast(u16, a.digits[it]) + cast(u16, b.digits[it]) + carry;
        carry = ifx next_digit >= 256 then cast(u16, 1);
        next_digit %= 256;
        result.digits[it] = cast(u8, next_digit);
    }

    if carry assert(false, "Number exceeded maximum size");
    return result;
}

#import "Basic";
#import "Random";