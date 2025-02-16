SIZE :: 1024; // @TODO: make a struct parameter with default value
Big_Int :: struct
{
    negative : bool;
    digits : [SIZE]u8; // stored as a decimal number
}

// TODO: I vaguely remember some mechanism to hook into the Basic print?
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

    for i: 0..a.digits.count-1
    {
        if a.digits[i] < b.digits[i] return true;
        if b.digits[i] < a.digits[i] return false;
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

#scope_file

#import "Basic";
#import "Random";