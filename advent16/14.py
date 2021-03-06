"""
More MD5, more Python. Again, pipe in with `echo -n`.
"""

from hashlib import md5
from itertools import count, chain
from sys import stdin


def hash(plaintext):
    """Just hash it"""
    return md5(plaintext.encode()).hexdigest()


def search_hashes(salt, stretching=0):
    """Iterator to hash a salt with an increasing integer"""
    for i in count(0, 1):
        intermediate = hash(salt + str(i))
        for j in range(stretching):
            intermediate = hash(intermediate)
        yield (i, intermediate)


def triplet(string):
    """Return the first triplet in a string"""
    for i in range(len(string) - 2):
        if string[i] == string[i+1] == string[i+2]:
            return string[i]
    return None


def solve(salt, stretching=0):
    findings = {}
    otpks = []
    for i, cypher in search_hashes(salt, stretching=stretching):
        if len(otpks) >= 64 and i - max(otpks) > 1000:
            return sorted(list(set(otpks)))[63]

        findings[i] = []

        for j, chars in findings.items():
            if not chars or i - j > 1000:
                continue
            if ''.join([chars[0] for _ in range(5)]) in cypher:
                otpks.insert(0, j)

        tripl = triplet(cypher)
        if tripl:
            findings[i] += tripl


def main():
    salt = stdin.read()
    print(solve(salt))
    print(solve(salt, stretching=2016))


if __name__ == '__main__':
    main()
