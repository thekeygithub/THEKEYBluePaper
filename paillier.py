import random


def l_function(x, n):
    return (x-1)/n


def gcd_stein(za, zb):
    if za < zb:
        za, zb = zb, za
    if zb == 0:
        return za
    if za % 2 == 0 and zb % 2 == 0:
        return 2 * gcd_stein(za / 2, zb / 2)
    else:
        if za % 2 == 0:
            return gcd_stein(za / 2, zb)
        if zb % 2 == 0:
            return gcd_stein(za, zb / 2)
    return gcd_stein(zb, za - zb)


def gcd_extend_euclid(za, zb):
    # 扩展欧几里得算法
    # 求za * zx + zb * zy = gcd(za, zb)中的 gcd、zx、zy
    if zb == 0:
        return za, 1, 0
    else:
        ans, zx, zy = gcd_extend_euclid(zb, za % zb)
        zx, zy = zy, zx - za // zb * zy
        return ans, zx, zy


def lcm(za, zb):
    gcd = gcd_stein(za, zb)
    return int(za * zb // gcd)


def mmi(za, zn):
    # 求 za * zx % zn = 1中的zx
    gcd, x1, y1 = gcd_extend_euclid(za, zn)
    if gcd != 1:
        return -1
    else:
        if x1 < 0:
            x1 = zn + x1
        return x1


def paillier_encryption(m, g, n, maxloop=10):
    for i in range(0, maxloop, 1):
        r = random.randint(2, n)
        if gcd_stein(n, r) == 1:
            break
    c = ((g ** m % n**2) * (r ** n % n**2)) % n**2
    return c


def paillier_decryption(c, s, g, n):
    temp1 = l_function((c**s) % n**2, n)
    temp2 = l_function((g**s) % n**2, n)
    mu = mmi(temp2, n)
    m = temp1 * mu % n
    return m


def paillier_main():
    m1 = 33
    m2 = 20
    print("m1={0}, m2={1}".format(m1, m2))
    p = 751
    q = 911
    n = p*q
    print("n={}".format(n))
    g = n + 1
    s = lcm(p-1, q-1)
    print("g={0}, s={1}".format(g, s))
    c1 = paillier_encryption(m1, g, n)
    c2 = paillier_encryption(m2, g, n)
    print("c1={0}, c2={1}".format(c1, c2))
    c_plus = c1 * c2 % n**2
    c2_inv = mmi(c2, n**2)
    c_minus = c1 * c2_inv % n**2
    c_multiply = c1 ** m2 % n**2
    print("c_plus={0}, c_minus={1}, c_multiply={2}".format(c_plus, c_minus, c_multiply))
    dc1 = paillier_decryption(c1, s, g, n)
    dc2 = paillier_decryption(c2, s, g, n)
    dc_plus = paillier_decryption(c_plus, s, g, n)
    dc_minus = paillier_decryption(c_minus, s, g, n)
    dc_multiply = paillier_decryption(c_multiply, s, g, n)
    print("dc1={0}, dc2={1}".format(dc1, dc2))
    print("dc_plus={0}, dc_minus={1}, dc_multiply={2}".format(dc_plus, dc_minus, dc_multiply))


if __name__ == "__main__":
    paillier_main()
