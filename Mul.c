#include <stdio.h>
#include <intrin.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

unsigned long long          A = -1, a = -1, B[2];
static void                 mul(unsigned long long multiplicand, unsigned long long multiplier, unsigned long long * res)
{
    unsigned long long  A, a, B, b;

    // multiplicand x multiplierl

    A                   = multiplicand & 0xffffffff;
    a                   = multiplier & 0xffffffff;
    res[1]              = A * a;
    B                   = res[1] >> 32;
    A                   = multiplicand >> 32;
    A                   *= a;
    A                   += B;
    res[0]              = A >> 32;
    res[1]              &= 0xffffffff;
    A                   <<= 32;
    res[1]              += A;

    // multiplicand x multiplierh

    A                   = multiplicand & 0xffffffff;
    a                   = multiplier >> 32;
    A                   *= a;
    B                   = res[1] >> 32;
    b                   = A & 0xffffffff;
    B                   += b;
    b                   = B >> 32;
    res[0]              += b;
    B                   <<= 32;
    res[1]              &= 0xffffffff;
    res[1]              += B;
    A                   >>= 32;
    res[0]              += A;
    A                   = multiplicand >> 32;
    A                   *= a;
    res[0]              += A;
}
static void                 muls(unsigned long long multiplicand, unsigned long long multiplier, unsigned long long* res)
{
    unsigned long long  sign = 0, sign1 = 0, res1[2], res2[2], res3[2], carry[2], A, a, B;

    mul(multiplicand, multiplier, res);

    if                  ((long long)multiplicand < 0) sign = -1;

    mul(sign, multiplier, res1);

    if                  ((long long)multiplier < 0) sign1 = -1;
    
    mul(multiplicand, sign1, res2);
    mul(sign, sign1, res3);

    A                   = res[0] & 0xffffffff;
    a                   = res1[1] & 0xffffffff;
    A                   += a;
    a                   = res2[1] & 0xffffffff;
    A                   += a;
    a                   = A >> 32;
    B                   = res[0] >> 32;
    a                   += B;
    res[0]              = A;
    res[0]              &= 0xffffffff;
    A                   = res1[1] >> 32;
    A                   += a;
    a                   = res2[1] >> 32;
    A                   += a;
    carry[1]            = A >> 32;
    A                   <<= 32;
    res[0]              += A;
    A                   = res1[0] & 0xffffffff;
    carry[1]            += A;
    A                   = res2[0] & 0xffffffff;
    carry[1]            += A;
    A                   = res3[1] & 0xffffffff;
    carry[1]            += A;
    A                   = carry[1] >> 32;
    carry[1]            &= 0xffffffff;
    a                   = res1[0] >> 32;
    A                   += a;
    a                   = res2[0] >> 32;
    A                   += a;
    a                   = res3[1] >> 32;
    A                   += a;
    carry[0]            = A >> 32;
    carry[0]            += res3[0];
    A                   <<= 32;
    carry[1]            += A;
}
static void                 pad_with_zeros(char * dest, unsigned long long target_length)
{
    unsigned long long  current_length = strlen(dest), padding = target_length - current_length;

    if                  (padding > 0)
    {
        memmove_s(dest + padding, target_length, dest, current_length + 1);
        memset(dest, '0', padding);
    }
}
static void                 add(char * src, char * dest, unsigned long long size)
{
    char        carry = 0, sum;
    long long   A, a = strlen(src) - 1;

    if          (strlen(dest) < size) pad_with_zeros(dest, size);

    A           = strlen(dest) - 1;

    while       (A >= 0 || a >= 0 || carry)
    {
        sum     = carry;
        if      (a >= 0) sum += src[a--] - '0';
        if      (A >= 0) sum += dest[A] - '0';

        carry   = sum / 10;
        if      (A >= 0) dest[A--] = (sum % 10) + '0';
    }
}
static void                 sub(char * src, unsigned long long sizesrc, char * dest, unsigned long long sizedest)
{
    char        neg = 0, borrow = 0, digitA, digitB, * swap, * temp, * temp1, B = 0;
    long long   a = strlen(src) - 1;

    if          (strlen(src) > strlen(dest)) pad_with_zeros(dest, strlen(src));

    long long   A = strlen(dest) - 1;

    swap        = (char *)malloc(sizesrc), temp = (char *)malloc(sizesrc), temp1 = (char *)malloc(sizedest);

    if          (!swap || !temp || !temp1) exit(1);

    strcpy_s(temp, sizesrc, src);
    strcpy_s(temp1, sizedest, dest);

    if          (strcmp(src, dest) > 0)
    {
        neg = 1;

        strcpy_s(swap, sizesrc, temp);
        strcpy_s(temp, sizesrc, temp1);
        strcpy_s(temp1, sizedest, swap);
    }

    while       (A >= 0 || a >= 0)
    {
        digitA      = (A >= 0) ? temp1[A] - '0' : 0, digitB = (a >= 0) ? temp[a] - '0' : 0, digitA -= borrow;

        if          (digitA < digitB) digitA += 10, borrow = 1;
        else        borrow = 0;

        temp1[A]    = (digitA - digitB) + '0';

        A--;
        a--;
    }

    while       (temp1[B] == '0') B++;

    if          (neg) temp1[B - 1] = '-';

    strcpy_s(dest, sizedest, temp1);

    free(swap);
    free(temp);
    free(temp1);
}
static void                 cvti2s(unsigned long long high, unsigned long long low, char* num, unsigned long long size, char sign)
{
    char    A, a = 0;
    char    hex[21] = "18446744073709551616";
    char    hex1[22] = "295147905179352825856";
    char    hex2[23] = "4722366482869645213696";
    char    hex3[24] = "75557863725914323419136";
    char    hex4[26] = "1208925819614629174706176";
    char    hex5[27] = "19342813113834066795298816";
    char    hex6[28] = "309485009821345068724781056";
    char    hex7[29] = "4951760157141521099596496896";
    char    hex8[30] = "79228162514264337593543950336";
    char    hex9[32] = "1267650600228229401496703205376";
    char    hex10[33] = "20282409603651670423947251286016";
    char    hex11[34] = "324518553658426726783156020576256";
    char    hex12[35] = "5192296858534827628530496329220096";
    char    hex13[36] = "83076749736557242056487941267521536";
    char    hex14[38] = "1329227995784915872903807060280344576";
    char    hex15[39] = "21267647932558653966460912964485513216";
    char    hex16[41] = "0340282366920938463463374607431768211456";

    sprintf_s(num, size, "00000000000000000000%020llu", low);

    for     (A = (char)(high & 0xf); A > 0; A--) add(hex, num, strlen(num));
    for     (A = (char)((high & 0xff) >> 4); A > 0; A--) add(hex1, num, strlen(num));
    for     (A = (char)((high & 0xfff) >> 8); A > 0; A--) add(hex2, num, strlen(num));
    for     (A = (char)((high & 0xffff) >> 12); A > 0; A--) add(hex3, num, strlen(num));
    for     (A = (char)((high & 0xfffff) >> 16); A > 0; A--) add(hex4, num, strlen(num));
    for     (A = (char)((high & 0xffffff) >> 20); A > 0; A--) add(hex5, num, strlen(num));
    for     (A = (char)((high & 0xfffffff) >> 24); A > 0; A--) add(hex6, num, strlen(num));
    for     (A = (char)((high & 0xffffffff) >> 28); A > 0; A--) add(hex7, num, strlen(num));
    for     (A = (char)((high & 0xfffffffff) >> 32); A > 0; A--) add(hex8, num, strlen(num));
    for     (A = (char)((high & 0xffffffffff) >> 36); A > 0; A--) add(hex9, num, strlen(num));
    for     (A = (char)((high & 0xfffffffffff) >> 40); A > 0; A--) add(hex10, num, strlen(num));
    for     (A = (char)((high & 0xffffffffffff) >> 44); A > 0; A--) add(hex11, num, strlen(num));
    for     (A = (char)((high & 0xfffffffffffff) >> 48); A > 0; A--) add(hex12, num, strlen(num));
    for     (A = (char)((high & 0xffffffffffffff) >> 52); A > 0; A--) add(hex13, num, strlen(num));
    for     (A = (char)((high & 0xfffffffffffffff) >> 56); A > 0; A--) add(hex14, num, strlen(num));
    for     (A = (char)((high & -1) >> 60); A > 0; A--) add(hex15, num, strlen(num));

    if      (sign && (long long)high < 0) sub(hex16, sizeof(hex16), num, size);

    while   (num[a] == '0') a++;

    if      (!num[a]) strcpy_s(num, size, "0");
    else    memmove_s(num, size, num + a, strlen(num) - a + 1);
}
static void                 cvti2s1(char * num, unsigned long long size, char sign, char byte, ...)
{
    char                A, a, b = 0, * hex, * temp1;
    unsigned long long  B, * temp;
    va_list             arg;
    va_start(arg, byte);

    temp                = malloc((unsigned long long)byte * 8);

    if                  (!temp) exit(1);

    for                 (A = 0; A < byte - 1; A++) temp[A] = va_arg(arg, unsigned long long);

    sprintf_s(num, size, "%020llu", temp[A - 1]);

    pad_with_zeros(num, size - 1);

    hex                 = (char *)malloc(21);

    if                  (!hex) exit(1);

    hex                 = "18446744073709551616";

    if                  (size > 21)
    {
        temp1 = realloc(hex, size);

        if  (!temp1) exit(1);
    }
    
    pad_with_zeros(hex, size - 1);

    if                  (byte > 1)
    {
        B       = 0xf, A   -= 2;

        while   (A >= 0)
        {
            while (temp[A])
            {
                for (a = (char)((temp[A] & B) >> b); a > 0; a--) add(hex, num, strlen(num));
                for (a = 4; a > 0; a--) add(hex, hex, strlen(hex));

                B = (B << 4) + 0xf, b += 4;
            }

            A--;
        }
    }

    free(temp);
    free(hex);
}
static unsigned long long   divf(unsigned long long dividend, unsigned long long divisor, char sign)
{
    unsigned long long  temp = dividend;
    dividend            = 0;

    if                  (!divisor) exit(1);
    if                  (sign && (long long)temp < 0 && (long long)divisor > 0) while ((long long)temp < 0)
    {
        temp    += divisor, dividend--;

        if      ((long long)temp > 0) dividend++;
    }
    else if             (sign && (long long)temp > 0 && (long long)divisor < 0) while ((long long)temp > 0)
    {
        temp    += divisor, dividend--;

        if      ((long long)temp < 0) dividend++;
    }
    else if             (sign && (long long)temp < 0 && (long long)divisor < 0) while (temp <= divisor) temp -= divisor, dividend++;
    else                while (temp >= divisor) temp -= divisor, dividend++;

    return              dividend;
}
static unsigned long long   modf(unsigned long long dividend, unsigned long long divisor, char sign, char floor)
{
    if      (!divisor) exit(1);
    if      (sign && (long long)dividend < 0 && (long long)divisor > 0)
    {
        while   ((long long)dividend < 0) dividend += divisor;
        if      (!floor && (long long)dividend > 0) dividend -= divisor;
    }
    else if (sign && (long long)dividend > 0 && (long long)divisor < 0)
    {
        while   ((long long)dividend > 0) dividend += divisor;
        if      (!floor && (long long)dividend < 0) dividend -= divisor;
    }
    else if (sign && (long long)dividend < 0 && (long long)divisor < 0) while ((long long)dividend <= (long long)divisor) dividend -= divisor;
    else    while (dividend >= divisor) dividend -= divisor;

    return  dividend;
}
static unsigned long long   div1(unsigned long long dividend, unsigned long long divisor)
{
    char                A = 0, B = 0;
    unsigned long long  a = 0xf, temp = dividend, temp1 = divisor;
    if                  (!divisor) exit(1);
    
    while               (!(dividend < a)) A += 4, a = (a << 4) + 0xf;

    a                   = 0xf;

    while               (!(divisor < a)) B += 4, a = (a << 4) + 0xf;
    
    if                  (A >= B) A -= B;
    else                A = 0;

    dividend            = 0, temp1 <<= A;

    while               (temp >= divisor)
    {
        while   (temp >= temp1) temp -= temp1, dividend++;

        temp1   >>= B, dividend <<= 4;
    }

    return              dividend;
}

int                         main()
{
    muls(A, a, B);

    printf("%llu x %llu = %016llX%016llX\n", A, a, B[0], B[1]);

    A   = -1;
    a   = 0xf;
    a   = (a << 4) + 0xf;
    printf("%llu\n", a);

	return  0;
}
