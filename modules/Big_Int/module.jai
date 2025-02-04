// TODO: I vaguely remember some mechanism to hook into the Basic print?
print :: (n: Big_Int)
{
    if n.negative print("-");
    for n.digits print("%", it);
    if !n.digits.count print("0");
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
    if a.negative && !b.negative return true;
    if !a.negative && b.negative return false;
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
    if a.negative != b.negative return false;
    if a.digits.count != b.digits.count return false;

    for i: 0..a.digits.count-1
    {
        if a.digits[i] != b.digits[i] return false;
    }

    return true;
}

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

    lhs := ifx a < b then b else a;
    rhs := ifx a < b then a else b;

    result : Big_Int;
    max_size := max(a.digits.count, b.digits.count);
    array_resize(*result.digits, max_size);

    a_index := lhs.digits.count - 1;
    b_index := rhs.digits.count - 1;
    r_index := max_size - 1;

    borrow : u8 = 0;
    while a_index >= 0 || b_index >= 0
    {
        defer a_index, b_index, r_index -= 1;

        a_value := ifx a_index >= 0 then lhs.digits[a_index];
        b_value := ifx b_index >= 0 then rhs.digits[b_index];
        a_value -= borrow;
        borrow = ifx a_value < b_value then cast(u8)1;
        a_value += ifx a_value < b_value then cast(u8)10;
        result.digits[r_index] = a_value - b_value;
    }

    result.negative = a < b;

    remove_any_leading_zeros(*result);
    return result;
}

operator + :: inline (a: Big_Int, b: Big_Int) -> Big_Int
{
    if a.negative == b.negative return add_same_signed_numbers(a, b);

    lhs := ifx a.negative then b else a;
    rhs := ifx a.negative then a else b;
    rhs.negative = false;
    return lhs - rhs;
}

#scope_file

remove_any_leading_zeros :: (n: *Big_Int)
{
    while n.digits.count && n.digits[0] == 0
    {
        array_ordered_remove_by_index(*n.digits, 0);
    }
}

// NOTE: this has to be a seperate procedure due to the circular dependency between binary+ and binary-
add_same_signed_numbers :: inline (a: Big_Int, b: Big_Int) -> Big_Int
{
    assert(a.negative == b.negative);

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

#import "Basic";