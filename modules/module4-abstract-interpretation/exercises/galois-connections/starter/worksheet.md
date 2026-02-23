# Galois Connection Worksheet

## Part 1: Alpha and Gamma for the Sign Domain

Fill in the blanks:

1. alpha({1, 2, 3}) = _______
2. alpha({-5, -1}) = _______
3. alpha({-1, 0, 1}) = _______
4. alpha({}) = _______
5. alpha({0}) = _______

6. gamma(Pos) = _______
7. gamma(Zero) = _______
8. gamma(Bot) = _______
9. gamma(Top) = _______

## Part 2: Adjunction Property

The adjunction property states: alpha(c) <= a  iff  c is a subset of gamma(a)

Verify for each pair (c, a):

| c | a | alpha(c) <= a? | c subset of gamma(a)? | Adjunction holds? |
|---|---|----------------|----------------------|-------------------|
| {1, 2} | Pos | _______ | _______ | _______ |
| {1, 2} | Neg | _______ | _______ | _______ |
| {-1, 0} | Top | _______ | _______ | _______ |
| {} | Bot | _______ | _______ | _______ |
| {0} | Pos | _______ | _______ | _______ |

## Part 3: Monotonicity

alpha is monotone: if S1 is a subset of S2, then alpha(S1) <= alpha(S2).

Verify:
- S1 = {1, 2}, S2 = {1, 2, -3}: alpha(S1) = _______, alpha(S2) = _______
  Is alpha(S1) <= alpha(S2)? _______

- S1 = {}, S2 = {5}: alpha(S1) = _______, alpha(S2) = _______
  Is alpha(S1) <= alpha(S2)? _______

## Part 4: Soundness Argument

Explain in 2-3 sentences why the sign Galois connection guarantees sound analysis:

_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
