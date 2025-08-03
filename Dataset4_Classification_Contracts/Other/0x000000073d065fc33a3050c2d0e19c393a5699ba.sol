// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
library FixedPointMathLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error ExpOverflow();

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error FactorialOverflow();

    /// @dev The operation failed, due to an overflow.
    error RPowOverflow();

    /// @dev The mantissa is too big to fit.
    error MantissaOverflow();

    /// @dev The operation failed, due to an multiplication overflow.
    error MulWadFailed();

    /// @dev The operation failed, due to an multiplication overflow.
    error SMulWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error DivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error SDivWadFailed();

    /// @dev The operation failed, either due to a multiplication overflow, or a division by a zero.
    error MulDivFailed();

    /// @dev The division failed, as the denominator is zero.
    error DivFailed();

    /// @dev The full precision multiply-divide operation failed, either due
    /// to the result being larger than 256 bits, or a division by a zero.
    error FullMulDivFailed();

    /// @dev The output is undefined, as the input is less-than-or-equal to zero.
    error LnWadUndefined();

    /// @dev The input outside the acceptable domain.
    error OutOfDomain();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The scalar of ETH and most ERC20s.
    uint256 internal constant WAD = 1e18;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              SIMPLIFIED FIXED POINT OPERATIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function mulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function sMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, y)
            // Equivalent to `require((x == 0 || z / x == y) && !(x == -1 && y == type(int256).min))`.
            if iszero(gt(or(iszero(x), eq(sdiv(z, x), y)), lt(not(x), eq(y, shl(255, 1))))) {
                mstore(0x00, 0xedcd4dd4) // `SMulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(z, WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawMulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded down, but without overflow checks.
    function rawSMulWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up.
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b) // `MulWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up, but without overflow checks.
    function rawMulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function divWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function sDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(x, WAD)
            // Equivalent to `require(y != 0 && ((x * WAD) / WAD == x))`.
            if iszero(and(iszero(iszero(y)), eq(sdiv(z, WAD), x))) {
                mstore(0x00, 0x5c43740d) // `SDivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawDivWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down, but without overflow and divide by zero checks.
    function rawSDivWad(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up.
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d) // `DivWadFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up, but without overflow and divide by zero checks.
    function rawDivWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `x` to the power of `y`.
    /// because `x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)`.
    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Using `ln(x)` means `x` must be greater than 0.
        return expWad((lnWad(x) * y) / int256(WAD));
    }

    /// @dev Returns `exp(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is less than 0.5 we return zero.
            // This happens when `x <= (log(1e-18) * 1e18) ~ -4.15e19`.
            if (x <= -41446531673892822313) return r;

            /// @solidity memory-safe-assembly
            assembly {
                // When the result is greater than `(2**255 - 1) / 1e18` we can not represent it as
                // an int. This happens when `x >= floor(log((2**255 - 1) / 1e18) * 1e18) ≈ 135`.
                if iszero(slt(x, 135305999368893231589)) {
                    mstore(0x00, 0xa37bfec9) // `ExpOverflow()`.
                    revert(0x1c, 0x04)
                }
            }

            // `x` is now in the range `(-42, 136) * 1e18`. Convert to `(-42, 136) * 2**96`
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5 ** 18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // `k` is in the range `[-61, 195]`.

            // Evaluate using a (6, 7)-term rational approximation.
            // `p` is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already `2**96` too large.
                r := sdiv(p, q)
            }

            // r should be in the range `(0.09, 0.25) * 2**96`.

            // We now need to multiply r by:
            // - The scale factor `s ≈ 6.031367120`.
            // - The `2**k` factor from the range reduction.
            // - The `1e18 / 2**96` factor for base conversion.
            // We do this all at once, with an intermediate result in `2**213`
            // basis, so the final right shift is always by a positive amount.
            r = int256(
                (uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k)
            );
        }
    }

    /// @dev Returns `ln(x)`, denominated in `WAD`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    function lnWad(int256 x) internal pure returns (int256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // We want to convert `x` from `10**18` fixed point to `2**96` fixed point.
            // We do this by multiplying by `2**96 / 10**18`. But since
            // `ln(x * C) = ln(x) + ln(C)`, we can simply do nothing here
            // and add `ln(2**96 / 10**18)` at the end.

            // Compute `k = log2(x) - 96`, `r = 159 - k = 255 - log2(x) = 255 ^ log2(x)`.
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // We place the check here for more optimal stack operations.
            if iszero(sgt(x, 0)) {
                mstore(0x00, 0x1615e638) // `LnWadUndefined()`.
                revert(0x1c, 0x04)
            }
            // forgefmt: disable-next-item
            r := xor(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff))

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            x := shr(159, shl(r, x))

            // Evaluate using a (8, 8)-term rational approximation.
            // `p` is made monic, we will multiply by a scale factor later.
            // forgefmt: disable-next-item
            let p := sub( // This heavily nested expression is to avoid stack-too-deep for via-ir.
                sar(96, mul(add(43456485725739037958740375743393,
                sar(96, mul(add(24828157081833163892658089445524,
                sar(96, mul(add(3273285459638523848632254066296,
                    x), x))), x))), x)), 11111509109440967052023855526967)
            p := sub(sar(96, mul(p, x)), 45023709667254063763336534515857)
            p := sub(sar(96, mul(p, x)), 14706773417378608786704636184526)
            p := sub(mul(p, x), shl(96, 795164235651350426258249787498))
            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.

            // `q` is monic by convention.
            let q := add(5573035233440673466300451813936, x)
            q := add(71694874799317883764090561454958, sar(96, mul(x, q)))
            q := add(283447036172924575727196451306956, sar(96, mul(x, q)))
            q := add(401686690394027663651624208769553, sar(96, mul(x, q)))
            q := add(204048457590392012362485061816622, sar(96, mul(x, q)))
            q := add(31853899698501571402653359427138, sar(96, mul(x, q)))
            q := add(909429971244387300277376558375, sar(96, mul(x, q)))

            // `p / q` is in the range `(0, 0.125) * 2**96`.

            // Finalization, we need to:
            // - Multiply by the scale factor `s = 5.549…`.
            // - Add `ln(2**96 / 10**18)`.
            // - Add `k * ln(2)`.
            // - Multiply by `10**18 / 2**96 = 5**18 >> 78`.

            // The q polynomial is known not to have zeros in the domain.
            // No scaling required because p is already `2**96` too large.
            p := sdiv(p, q)
            // Multiply by the scaling factor: `s * 5**18 * 2**96`, base is now `5**18 * 2**192`.
            p := mul(1677202110996718588342820967067443963516166, p)
            // Add `ln(2) * k * 5**18 * 2**192`.
            // forgefmt: disable-next-item
            p := add(mul(16597577552685614221487285958193947469193820559219878177908093499208371, sub(159, r)), p)
            // Add `ln(2**96 / 10**18) * 5**18 * 2**192`.
            p := add(600920179829731861736702779321621459595472258049074101567377883020018308, p)
            // Base conversion: mul `2**18 / 2**192`.
            r := sar(174, p)
        }
    }

    /// @dev Returns `W_0(x)`, denominated in `WAD`.
    /// See: https://en.wikipedia.org/wiki/Lambert_W_function
    /// a.k.a. Product log function. This is an approximation of the principal branch.
    function lambertW0Wad(int256 x) internal pure returns (int256 w) {
        // forgefmt: disable-next-item
        unchecked {
            if ((w = x) <= -367879441171442322) revert OutOfDomain(); // `x` less than `-1/e`.
            int256 wad = int256(WAD);
            int256 p = x;
            uint256 c; // Whether we need to avoid catastrophic cancellation.
            uint256 i = 4; // Number of iterations.
            if (w <= 0x1ffffffffffff) {
                if (-0x4000000000000 <= w) {
                    i = 1; // Inputs near zero only take one step to converge.
                } else if (w <= -0x3ffffffffffffff) {
                    i = 32; // Inputs near `-1/e` take very long to converge.
                }
            } else if (w >> 63 == 0) {
                /// @solidity memory-safe-assembly
                assembly {
                    // Inline log2 for more performance, since the range is small.
                    let v := shr(49, w)
                    let l := shl(3, lt(0xff, v))
                    l := add(or(l, byte(and(0x1f, shr(shr(l, v), 0x8421084210842108cc6318c6db6d54be)),
                        0x0706060506020504060203020504030106050205030304010505030400000000)), 49)
                    w := sdiv(shl(l, 7), byte(sub(l, 31), 0x0303030303030303040506080c13))
                    c := gt(l, 60)
                    i := add(2, add(gt(l, 53), c))
                }
            } else {
                int256 ll = lnWad(w = lnWad(w));
                /// @solidity memory-safe-assembly
                assembly {
                    // `w = ln(x) - ln(ln(x)) + b * ln(ln(x)) / ln(x)`.
                    w := add(sdiv(mul(ll, 1023715080943847266), w), sub(w, ll))
                    i := add(3, iszero(shr(68, x)))
                    c := iszero(shr(143, x))
                }
                if (c == 0) {
                    do { // If `x` is big, use Newton's so that intermediate values won't overflow.
                        int256 e = expWad(w);
                        /// @solidity memory-safe-assembly
                        assembly {
                            let t := mul(w, div(e, wad))
                            w := sub(w, sdiv(sub(t, x), div(add(e, t), wad)))
                        }
                        if (p <= w) break;
                        p = w;
                    } while (--i != 0);
                    /// @solidity memory-safe-assembly
                    assembly {
                        w := sub(w, sgt(w, 2))
                    }
                    return w;
                }
            }
            do { // Otherwise, use Halley's for faster convergence.
                int256 e = expWad(w);
                /// @solidity memory-safe-assembly
                assembly {
                    let t := add(w, wad)
                    let s := sub(mul(w, e), mul(x, wad))
                    w := sub(w, sdiv(mul(s, wad), sub(mul(e, t), sdiv(mul(add(t, wad), s), add(t, t)))))
                }
                if (p <= w) break;
                p = w;
            } while (--i != c);
            /// @solidity memory-safe-assembly
            assembly {
                w := sub(w, sgt(w, 2))
            }
            // For certain ranges of `x`, we'll use the quadratic-rate recursive formula of
            // R. Iacono and J.P. Boyd for the last iteration, to avoid catastrophic cancellation.
            if (c != 0) {
                int256 t = w | 1;
                /// @solidity memory-safe-assembly
                assembly {
                    x := sdiv(mul(x, wad), t)
                }
                x = (t * (wad + lnWad(x)));
                /// @solidity memory-safe-assembly
                assembly {
                    w := sdiv(x, add(wad, t))
                }
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  GENERAL NUMBER UTILITIES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Calculates `floor(x * y / d)` with full precision.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/21/muldiv
    function fullMulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                // 512-bit multiply `[p1 p0] = x * y`.
                // Compute the product mod `2**256` and mod `2**256 - 1`
                // then use the Chinese Remainder Theorem to reconstruct
                // the 512 bit result. The result is stored in two 256
                // variables such that `product = p1 * 2**256 + p0`.

                // Least significant 256 bits of the product.
                result := mul(x, y) // Temporarily use `result` as `p0` to save gas.
                let mm := mulmod(x, y, not(0))
                // Most significant 256 bits of the product.
                let p1 := sub(mm, add(result, lt(mm, result)))

                // Handle non-overflow cases, 256 by 256 division.
                if iszero(p1) {
                    if iszero(d) {
                        mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                        revert(0x1c, 0x04)
                    }
                    result := div(result, d)
                    break
                }

                // Make sure the result is less than `2**256`. Also prevents `d == 0`.
                if iszero(gt(d, p1)) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }

                /*------------------- 512 by 256 division --------------------*/

                // Make division exact by subtracting the remainder from `[p1 p0]`.
                // Compute remainder using mulmod.
                let r := mulmod(x, y, d)
                // `t` is the least significant bit of `d`.
                // Always greater or equal to 1.
                let t := and(d, sub(0, d))
                // Divide `d` by `t`, which is a power of two.
                d := div(d, t)
                // Invert `d mod 2**256`
                // Now that `d` is an odd number, it has an inverse
                // modulo `2**256` such that `d * inv = 1 mod 2**256`.
                // Compute the inverse by starting with a seed that is correct
                // correct for four bits. That is, `d * inv = 1 mod 2**4`.
                let inv := xor(2, mul(3, d))
                // Now use Newton-Raphson iteration to improve the precision.
                // Thanks to Hensel's lifting lemma, this also works in modular
                // arithmetic, doubling the correct bits in each step.
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**8
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**16
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**32
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**64
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**128
                result :=
                    mul(
                        // Divide [p1 p0] by the factors of two.
                        // Shift in bits from `p1` into `p0`. For this we need
                        // to flip `t` such that it is `2**256 / t`.
                        or(
                            mul(sub(p1, gt(r, result)), add(div(sub(0, t), t), 1)),
                            div(sub(result, r), t)
                        ),
                        // inverse mod 2**256
                        mul(inv, sub(2, mul(d, inv)))
                    )
                break
            }
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision, rounded up.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Uniswap-v3-core under MIT license:
    /// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol
    function fullMulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        result = fullMulDiv(x, y, d);
        /// @solidity memory-safe-assembly
        assembly {
            if mulmod(x, y, d) {
                result := add(result, 1)
                if iszero(result) {
                    mstore(0x00, 0xae47f702) // `FullMulDivFailed()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @dev Returns `floor(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), d)
        }
    }

    /// @dev Returns `ceil(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                mstore(0x00, 0xad251c27) // `MulDivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), d))), div(mul(x, y), d))
        }
    }

    /// @dev Returns `ceil(x / d)`.
    /// Reverts if `d` is zero.
    function divUp(uint256 x, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(d) {
                mstore(0x00, 0x65244e4e) // `DivFailed()`.
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(x, d))), div(x, d))
        }
    }

    /// @dev Returns `max(0, x - y)`.
    function zeroFloorSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }

    /// @dev Exponentiate `x` to `y` by squaring, denominated in base `b`.
    /// Reverts if the computation overflows.
    function rpow(uint256 x, uint256 y, uint256 b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(b, iszero(y)) // `0 ** 0 = 1`. Otherwise, `0 ** n = 0`.
            if x {
                z := xor(b, mul(xor(b, x), and(y, 1))) // `z = isEven(y) ? scale : x`
                let half := shr(1, b) // Divide `b` by 2.
                // Divide `y` by 2 every iteration.
                for { y := shr(1, y) } y { y := shr(1, y) } {
                    let xx := mul(x, x) // Store x squared.
                    let xxRound := add(xx, half) // Round to the nearest number.
                    // Revert if `xx + half` overflowed, or if `x ** 2` overflows.
                    if or(lt(xxRound, xx), shr(128, x)) {
                        mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                        revert(0x1c, 0x04)
                    }
                    x := div(xxRound, b) // Set `x` to scaled `xxRound`.
                    // If `y` is odd:
                    if and(y, 1) {
                        let zx := mul(z, x) // Compute `z * x`.
                        let zxRound := add(zx, half) // Round to the nearest number.
                        // If `z * x` overflowed or `zx + half` overflowed:
                        if or(xor(div(zx, x), z), lt(zxRound, zx)) {
                            // Revert if `x` is non-zero.
                            if iszero(iszero(x)) {
                                mstore(0x00, 0x49f7642b) // `RPowOverflow()`.
                                revert(0x1c, 0x04)
                            }
                        }
                        z := div(zxRound, b) // Return properly scaled `zxRound`.
                    }
                }
            }
        }
    }

    /// @dev Returns the square root of `x`.
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // `floor(sqrt(2**15)) = 181`. `sqrt(2**15) - 181 = 2.84`.
            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // Let `y = x / 2**r`. We check `y >= 2**(k + 8)`
            // but shift right by `k` bits to ensure that if `x >= 256`, then `y >= 256`.
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffffff, shr(r, x))))
            z := shl(shr(1, r), z)

            // Goal was to get `z*z*y` within a small factor of `x`. More iterations could
            // get y in a tighter range. Currently, we will have y in `[256, 256*(2**16))`.
            // We ensured `y >= 256` so that the relative difference between `y` and `y+1` is small.
            // That's not possible if `x < 256` but we can just verify those cases exhaustively.

            // Now, `z*z*y <= x < z*z*(y+1)`, and `y <= 2**(16+8)`, and either `y >= 256`, or `x < 256`.
            // Correctness can be checked exhaustively for `x < 256`, so we assume `y >= 256`.
            // Then `z*sqrt(y)` is within `sqrt(257)/sqrt(256)` of `sqrt(x)`, or about 20bps.

            // For `s` in the range `[1/256, 256]`, the estimate `f(s) = (181/1024) * (s+1)`
            // is in the range `(1/2.84 * sqrt(s), 2.84 * sqrt(s))`,
            // with largest error when `s = 1` and when `s = 256` or `1/256`.

            // Since `y` is in `[256, 256*(2**16))`, let `a = y/65536`, so that `a` is in `[1/256, 256)`.
            // Then we can estimate `sqrt(y)` using
            // `sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2**18`.

            // There is no overflow risk here since `y < 2**136` after the first branch above.
            z := shr(18, mul(z, add(shr(r, x), 65536))) // A `mul()` is saved from starting `z` at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If `x+1` is a perfect square, the Babylonian method cycles between
            // `floor(sqrt(x))` and `ceil(sqrt(x))`. This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            z := sub(z, lt(div(x, z), z))
        }
    }

    /// @dev Returns the cube root of `x`.
    /// Credit to bout3fiddy and pcaversaccio under AGPLv3 license:
    /// https://github.com/pcaversaccio/snekmate/blob/main/src/utils/Math.vy
    function cbrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))

            z := div(shl(div(r, 3), shl(lt(0xf, shr(r, x)), 0xf)), xor(7, mod(r, 3)))

            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)

            z := sub(z, lt(div(x, mul(z, z)), z))
        }
    }

    /// @dev Returns the square root of `x`, denominated in `WAD`.
    function sqrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            z = 10 ** 9;
            if (x <= type(uint256).max / 10 ** 36 - 1) {
                x *= 10 ** 18;
                z = 1;
            }
            z *= sqrt(x);
        }
    }

    /// @dev Returns the cube root of `x`, denominated in `WAD`.
    function cbrtWad(uint256 x) internal pure returns (uint256 z) {
        unchecked {
            z = 10 ** 12;
            if (x <= (type(uint256).max / 10 ** 36) * 10 ** 18 - 1) {
                if (x >= type(uint256).max / 10 ** 36) {
                    x *= 10 ** 18;
                    z = 10 ** 6;
                } else {
                    x *= 10 ** 36;
                    z = 1;
                }
            }
            z *= cbrt(x);
        }
    }

    /// @dev Returns the factorial of `x`.
    function factorial(uint256 x) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(lt(x, 58)) {
                mstore(0x00, 0xaba0f2a2) // `FactorialOverflow()`.
                revert(0x1c, 0x04)
            }
            for { result := 1 } x { x := sub(x, 1) } { result := mul(result, x) }
        }
    }

    /// @dev Returns the log2 of `x`.
    /// Equivalent to computing the index of the most significant bit (MSB) of `x`.
    /// Returns 0 if `x` is zero.
    function log2(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
        }
    }

    /// @dev Returns the log2 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log2Up(uint256 x) internal pure returns (uint256 r) {
        r = log2(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(r, 1), x))
        }
    }

    /// @dev Returns the log10 of `x`.
    /// Returns 0 if `x` is zero.
    function log10(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(lt(x, 100000000000000000000000000000000000000)) {
                x := div(x, 100000000000000000000000000000000000000)
                r := 38
            }
            if iszero(lt(x, 100000000000000000000)) {
                x := div(x, 100000000000000000000)
                r := add(r, 20)
            }
            if iszero(lt(x, 10000000000)) {
                x := div(x, 10000000000)
                r := add(r, 10)
            }
            if iszero(lt(x, 100000)) {
                x := div(x, 100000)
                r := add(r, 5)
            }
            r := add(r, add(gt(x, 9), add(gt(x, 99), add(gt(x, 999), gt(x, 9999)))))
        }
    }

    /// @dev Returns the log10 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log10Up(uint256 x) internal pure returns (uint256 r) {
        r = log10(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(exp(10, r), x))
        }
    }

    /// @dev Returns the log256 of `x`.
    /// Returns 0 if `x` is zero.
    function log256(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(shr(3, r), lt(0xff, shr(r, x)))
        }
    }

    /// @dev Returns the log256 of `x`, rounded up.
    /// Returns 0 if `x` is zero.
    function log256Up(uint256 x) internal pure returns (uint256 r) {
        r = log256(x);
        /// @solidity memory-safe-assembly
        assembly {
            r := add(r, lt(shl(shl(3, r), 1), x))
        }
    }

    /// @dev Returns the scientific notation format `mantissa * 10 ** exponent` of `x`.
    /// Useful for compressing prices (e.g. using 25 bit mantissa and 7 bit exponent).
    function sci(uint256 x) internal pure returns (uint256 mantissa, uint256 exponent) {
        /// @solidity memory-safe-assembly
        assembly {
            mantissa := x
            if mantissa {
                if iszero(mod(mantissa, 1000000000000000000000000000000000)) {
                    mantissa := div(mantissa, 1000000000000000000000000000000000)
                    exponent := 33
                }
                if iszero(mod(mantissa, 10000000000000000000)) {
                    mantissa := div(mantissa, 10000000000000000000)
                    exponent := add(exponent, 19)
                }
                if iszero(mod(mantissa, 1000000000000)) {
                    mantissa := div(mantissa, 1000000000000)
                    exponent := add(exponent, 12)
                }
                if iszero(mod(mantissa, 1000000)) {
                    mantissa := div(mantissa, 1000000)
                    exponent := add(exponent, 6)
                }
                if iszero(mod(mantissa, 10000)) {
                    mantissa := div(mantissa, 10000)
                    exponent := add(exponent, 4)
                }
                if iszero(mod(mantissa, 100)) {
                    mantissa := div(mantissa, 100)
                    exponent := add(exponent, 2)
                }
                if iszero(mod(mantissa, 10)) {
                    mantissa := div(mantissa, 10)
                    exponent := add(exponent, 1)
                }
            }
        }
    }

    /// @dev Convenience function for packing `x` into a smaller number using `sci`.
    /// The `mantissa` will be in bits [7..255] (the upper 249 bits).
    /// The `exponent` will be in bits [0..6] (the lower 7 bits).
    /// Use `SafeCastLib` to safely ensure that the `packed` number is small
    /// enough to fit in the desired unsigned integer type:
    /// ```
    ///     uint32 packed = SafeCastLib.toUint32(FixedPointMathLib.packSci(777 ether));
    /// ```
    function packSci(uint256 x) internal pure returns (uint256 packed) {
        (x, packed) = sci(x); // Reuse for `mantissa` and `exponent`.
        /// @solidity memory-safe-assembly
        assembly {
            if shr(249, x) {
                mstore(0x00, 0xce30380c) // `MantissaOverflow()`.
                revert(0x1c, 0x04)
            }
            packed := or(shl(7, x), packed)
        }
    }

    /// @dev Convenience function for unpacking a packed number from `packSci`.
    function unpackSci(uint256 packed) internal pure returns (uint256 unpacked) {
        unchecked {
            unpacked = (packed >> 7) * 10 ** (packed & 0x7f);
        }
    }

    /// @dev Returns the average of `x` and `y`.
    function avg(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = (x & y) + ((x ^ y) >> 1);
        }
    }

    /// @dev Returns the average of `x` and `y`.
    function avg(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = (x >> 1) + (y >> 1) + (((x & 1) + (y & 1)) >> 1);
        }
    }

    /// @dev Returns the absolute value of `x`.
    function abs(int256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(sub(0, shr(255, x)), add(sub(0, shr(255, x)), x))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(mul(xor(sub(y, x), sub(x, y)), sgt(x, y)), sub(y, x))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), lt(y, x)))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), slt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), sgt(y, x)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(uint256 x, uint256 minValue, uint256 maxValue)
        internal
        pure
        returns (uint256 z)
    {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), gt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), lt(maxValue, z)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(int256 x, int256 minValue, int256 maxValue) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, minValue), sgt(minValue, x)))
            z := xor(z, mul(xor(z, maxValue), slt(maxValue, z)))
        }
    }

    /// @dev Returns greatest common divisor of `x` and `y`.
    function gcd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            for { z := x } y {} {
                let t := y
                y := mod(z, y)
                z := t
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RAW NUMBER OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawDiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(x, y)
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawSDiv(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mod(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawSMod(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := smod(x, y)
        }
    }

    /// @dev Returns `(x + y) % d`, return 0 if `d` if zero.
    function rawAddMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := addmod(x, y, d)
        }
    }

    /// @dev Returns `(x * y) % d`, return 0 if `d` if zero.
    function rawMulMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mulmod(x, y, d)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Reentrancy guard mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unauthorized reentrant call.
    error Reentrancy();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to: `uint72(bytes9(keccak256("_REENTRANCY_GUARD_SLOT")))`.
    /// 9 bytes is large enough to avoid collisions with lower slots,
    /// but not too large to result in excessive bytecode bloat.
    uint256 private constant _REENTRANCY_GUARD_SLOT = 0x929eee149b4bd21268;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      REENTRANCY GUARD                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Guards a function from reentrancy.
    modifier nonReentrant() virtual {
        /// @solidity memory-safe-assembly
        assembly {
            if eq(sload(_REENTRANCY_GUARD_SLOT), address()) {
                mstore(0x00, 0xab143c06) // `Reentrancy()`.
                revert(0x1c, 0x04)
            }
            sstore(_REENTRANCY_GUARD_SLOT, address())
        }
        _;
        /// @solidity memory-safe-assembly
        assembly {
            sstore(_REENTRANCY_GUARD_SLOT, codesize())
        }
    }

    /// @dev Guards a view function from read-only reentrancy.
    modifier nonReadReentrant() virtual {
        /// @solidity memory-safe-assembly
        assembly {
            if eq(sload(_REENTRANCY_GUARD_SLOT), address()) {
                mstore(0x00, 0xab143c06) // `Reentrancy()`.
                revert(0x1c, 0x04)
            }
        }
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
/// - For ERC20s, this implementation won't check that a token has code,
///   responsibility is delegated to the caller.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for
    /// the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x34, 0) // Store 0 for the `amount`.
                mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                mstore(0x34, amount) // Store back the original `amount`.
                // Retry the approval, reverting upon failure.
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul(
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;
/*
▄▄▄█████▓ ██░ ██ ▓█████     ██░ ██ ▓█████  ██▀███  ▓█████▄ 
▓  ██▒ ▓▒▓██░ ██▒▓█   ▀    ▓██░ ██▒▓█   ▀ ▓██ ▒ ██▒▒██▀ ██▌
▒ ▓██░ ▒░▒██▀▀██░▒███      ▒██▀▀██░▒███   ▓██ ░▄█ ▒░██   █▌
░ ▓██▓ ░ ░▓█ ░██ ▒▓█  ▄    ░▓█ ░██ ▒▓█  ▄ ▒██▀▀█▄  ░▓█▄   ▌
  ▒██▒ ░ ░▓█▒░██▓░▒████▒   ░▓█▒░██▓░▒████▒░██▓ ▒██▒░▒████▓ 
  ▒ ░░    ▒ ░░▒░▒░░ ▒░ ░    ▒ ░░▒░▒░░ ▒░ ░░ ▒▓ ░▒▓░ ▒▒▓  ▒ 
    ░     ▒ ░▒░ ░ ░ ░  ░    ▒ ░▒░ ░ ░ ░  ░  ░▒ ░ ▒░ ░ ▒  ▒ 
  ░       ░  ░░ ░   ░       ░  ░░ ░   ░     ░░   ░  ░ ░  ░ 
          ░  ░  ░   ░  ░    ░  ░  ░   ░  ░   ░        ░    
                                                    ░      
              .,;>>%%%%%>>;,.
           .>%%%%%%%%%%%%%%%%%%%%>,.
         .>%%%%%%%%%%%%%%%%%%>>,%%%%%%;,.
       .>>>>%%%%%%%%%%%%%>>,%%%%%%%%%%%%,>>%%,.
     .>>%>>>>%%%%%%%%%>>,%%%%%%%%%%%%%%%%%,>>%%%%%,.
   .>>%%%%%>>%%%%>>,%%>>%%%%%%%%%%%%%%%%%%%%,>>%%%%%%%,
  .>>%%%%%%%%%%>>,%%%%%%>>%%%%%%%%%%%%%%%%%%,>>%%%%%%%%%%.
  .>>%%%%%%%%%%>>,>>>>%%%%%%%%%%'..`%%%%%%%%,;>>%%%%%%%%%>%%.
.>>%%%>>>%%%%%>,%%%%%%%%%%%%%%.%%%,`%%%%%%,;>>%%%%%%%%>>>%%%%.
>>%%>%>>>%>%%%>,%%%%%>>%%%%%%%%%%%%%`%%%%%%,>%%%%%%%>>>>%%%%%%%.
>>%>>>%%>>>%%%%>,%>>>%%%%%%%%%%%%%%%%`%%%%%%%%%%%%%%%%%%%%%%%%%%.
>>%%%%%%%%%%%%%%,>%%%%%%%%%%%%%%%%%%%'%%%,>>%%%%%%%%%%%%%%%%%%%%%.
>>%%%%%%%%%%%%%%%,>%%%>>>%%%%%%%%%%%%%%%,>>%%%%%%%%>>>>%%%%%%%%%%%.
>>%%%%%%%%;%;%;%%;,%>>>>%%%%%%%%%%%%%%%,>>>%%%%%%>>;";>>%%%%%%%%%%%%.
`>%%%%%%%%%;%;;;%;%,>%%%%%%%%%>>%%%%%%%%,>>>%%%%%%%%%%%%%%%%%%%%%%%%%%.
 >>%%%%%%%%%,;;;;;%%>,%%%%%%%%>>>>%%%%%%%%,>>%%%%%%%%%%%%%%%%%%%%%%%%%%%.
 `>>%%%%%%%%%,%;;;;%%%>,%%%%%%%%>>>>%%%%%%%%,>%%%%%%'%%%%%%%%%%%%%%%%%%%>>.
  `>>%%%%%%%%%%>,;;%%%%%>>,%%%%%%%%>>%%%%%%';;;>%%%%%,`%%%%%%%%%%%%%%%>>%%>.
   >>>%%%%%%%%%%>> %%%%%%%%>>,%%%%>>>%%%%%';;;;;;>>,%%%,`%     `;>%%%%%%>>%%
   `>>%%%%%%%%%%>> %%%%%%%%%>>>>>>>>;;;;'.;;;;;>>%%'  `%%'          ;>%%%%%>
    >>%%%%%%%%%>>; %%%%%%%%>>;;;;;;''    ;;;;;>>%%%                   ;>%%%%
    `>>%%%%%%%>>>, %%%%%%%%%>>;;'        ;;;;>>%%%'                    ;>%%%
     >>%%%%%%>>>':.%%%%%%%%%%>>;        .;;;>>%%%%                    ;>%%%'
     `>>%%%%%>>> ::`%%%%%%%%%%>>;.      ;;;>>%%%%'                   ;>%%%'
      `>>%%%%>>> `:::`%%%%%%%%%%>;.     ;;>>%%%%%                   ;>%%'
       `>>%%%%>>, `::::`%%%%%%%%%%>,   .;>>%%%%%'                   ;>%'
        `>>%%%%>>, `:::::`%%%%%%%%%>>. ;;>%%%%%%                    ;>%,
         `>>%%%%>>, :::::::`>>>%%%%>>> ;;>%%%%%'                     ;>%,
          `>>%%%%>>,::::::,>>>>>>>>>>' ;;>%%%%%                       ;%%,
            >>%%%%>>,:::,%%>>>>>>>>'   ;>%%%%%.                        ;%%
             >>%%%%>>``%%%%%>>>>>'     `>%%%%%%.
             >>%%%%>> `@@a%%%%%%'     .%%%%%%%%%.
             `a@@a%@'    `%a@@'       `a@@a%a@@a
 */

/// Libraries
import {Owned} from "solmate/auth/Owned.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {ReentrancyGuard} from "solady/src/utils/ReentrancyGuard.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

/// Project Interfaces
import {GaugeController} from "src/interfaces/GaugeController.sol";

/// @title  Platform
/// @author Stake DAO
/// Changelog:
/// - Batch close bounties.
/// - Add custom fees per manager.
/// - OnlyManager can close bounties.
contract Platform is Owned, ReentrancyGuard {
    using FixedPointMathLib for uint256;

    ////////////////////////////////////////////////////////////////
    /// --- EMERGENCY SHUTDOWN
    ///////////////////////////////////////////////////////////////

    /// @notice Emergency shutdown flag
    bool public isKilled;

    ////////////////////////////////////////////////////////////////
    /// --- STRUCTS
    ///////////////////////////////////////////////////////////////

    /// @notice Bounty struct requirements.
    struct Bounty {
        // Address of the target gauge.
        address gauge;
        // Manager.
        address manager;
        // Address of the ERC20 used for rewards.
        address rewardToken;
        // Number of periods.
        uint8 numberOfPeriods;
        // Timestamp where the bounty become unclaimable.
        uint256 endTimestamp;
        // Max Price per vote.
        uint256 maxRewardPerVote;
        // Total Reward Added.
        uint256 totalRewardAmount;
        // Blacklisted addresses.
        address[] blacklist;
    }

    struct Upgrade {
        // Number of periods after increase.
        uint8 numberOfPeriods;
        // Total reward amount after increase.
        uint256 totalRewardAmount;
        // New max reward per vote after increase.
        uint256 maxRewardPerVote;
        // New end timestamp after increase.
        uint256 endTimestamp;
    }

    /// @notice Period struct.
    struct Period {
        // Period id.
        // Eg: 0 is the first period, 1 is the second period, etc.
        uint8 id;
        // Timestamp of the period start.
        uint256 timestamp;
        // Reward amount distributed during the period.
        uint256 rewardPerPeriod;
    }

    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS & IMMUTABLES
    ///////////////////////////////////////////////////////////////

    /// @notice Minimum duration a Bounty.
    uint8 public constant MINIMUM_PERIOD = 2;

    /// @notice Week in seconds.
    uint256 private constant _WEEK = 1 weeks;

    /// @notice Base unit for fixed point compute.
    uint256 private constant _BASE_UNIT = 1e18;

    /// @notice Default fee.
    uint256 internal constant _DEFAULT_FEE = 2e16; // 2%

    /// @notice Gauge Controller.
    GaugeController public immutable gaugeController;

    ////////////////////////////////////////////////////////////////
    /// --- STORAGE VARS
    ///////////////////////////////////////////////////////////////

    /// @notice Fee.
    uint256 public fee;

    /// @notice Bounty ID Counter.
    uint256 public nextID;

    /// @notice Fee collector.
    address public feeCollector;

    /// @notice Custom fees per manager.
    mapping(address => uint256) public fees;

    /// @notice ID => Bounty.
    mapping(uint256 => Bounty) public bounties;

    /// @notice Recipient per address.
    mapping(address => address) public recipient;

    /// @notice Fee accrued per rewardToken.
    mapping(address => uint256) public feeAccrued;

    /// @notice BountyId => isUpgradeable. If true, the bounty can be upgraded.
    mapping(uint256 => bool) public isUpgradeable;

    /// @notice ID => Period running.
    mapping(uint256 => Period) public activePeriod;

    /// @notice ID => Amount Claimed per Bounty.
    mapping(uint256 => uint256) public amountClaimed;

    /// @notice ID => Amount of reward per vote distributed.
    mapping(uint256 => uint256) public rewardPerVote;

    /// @notice ID => Bounty In Queue to be upgraded.
    mapping(uint256 => Upgrade) public upgradeBountyQueue;

    /// @notice Blacklisted addresses per bounty that aren't counted for rewards arithmetics.
    mapping(uint256 => mapping(address => bool)) public isBlacklisted;

    /// @notice Last time a user claimed
    mapping(address => mapping(uint256 => uint256)) public lastUserClaim;

    ////////////////////////////////////////////////////////////////
    /// --- MODIFIERS
    ///////////////////////////////////////////////////////////////

    modifier notKilled() {
        if (isKilled) revert KILLED();
        _;
    }

    modifier onlyManager(uint256 _id) {
        if (msg.sender != bounties[_id].manager) revert AUTH_MANAGER_ONLY();
        _;
    }

    ////////////////////////////////////////////////////////////////
    /// --- EVENTS
    ///////////////////////////////////////////////////////////////

    /// @notice Emitted when a new bounty is created.
    /// @param id Bounty ID.
    /// @param gauge Gauge address.
    /// @param manager Manager address.
    /// @param rewardToken Reward token address.
    /// @param numberOfPeriods Number of periods.
    /// @param maxRewardPerVote Max reward per vote.
    /// @param rewardPerPeriod Reward per period.
    /// @param totalRewardAmount Total reward amount.
    /// @param isUpgradeable If true, the bounty can be upgraded.
    event BountyCreated(
        uint256 indexed id,
        address indexed gauge,
        address manager,
        address rewardToken,
        uint8 numberOfPeriods,
        uint256 maxRewardPerVote,
        uint256 rewardPerPeriod,
        uint256 totalRewardAmount,
        bool isUpgradeable
    );

    /// @notice Emitted when a bounty is closed.
    /// @param id Bounty ID.
    /// @param remainingReward Remaining reward.
    event BountyClosed(uint256 id, uint256 remainingReward);

    /// @notice Emitted when a bounty period is rolled over.
    /// @param id Bounty ID.
    /// @param periodId Period ID.
    /// @param timestamp Period timestamp.
    /// @param rewardPerPeriod Reward per period.
    event PeriodRolledOver(uint256 id, uint256 periodId, uint256 timestamp, uint256 rewardPerPeriod);

    /// @notice Emitted on claim.
    /// @param user User address.
    /// @param rewardToken Reward token address.
    /// @param bountyId Bounty ID.
    /// @param amount Amount claimed.
    /// @param protocolFees Protocol fees.
    /// @param period Period timestamp.
    event Claimed(
        address indexed user,
        address rewardToken,
        uint256 indexed bountyId,
        uint256 amount,
        uint256 protocolFees,
        uint256 period
    );

    /// @notice Emitted when a bounty is queued to upgrade.
    /// @param id Bounty ID.
    /// @param numberOfPeriods Number of periods.
    /// @param totalRewardAmount Total reward amount.
    /// @param maxRewardPerVote Max reward per vote.
    event BountyDurationIncreaseQueued(
        uint256 id, uint8 numberOfPeriods, uint256 totalRewardAmount, uint256 maxRewardPerVote
    );

    /// @notice Emitted when a bounty is upgraded.
    /// @param id Bounty ID.
    /// @param numberOfPeriods Number of periods.
    /// @param totalRewardAmount Total reward amount.
    /// @param maxRewardPerVote Max reward per vote.
    event BountyDurationIncrease(
        uint256 id, uint8 numberOfPeriods, uint256 totalRewardAmount, uint256 maxRewardPerVote
    );

    /// @notice Emitted when a bounty manager is updated.
    /// @param id Bounty ID.
    /// @param manager Manager address.
    event ManagerUpdated(uint256 id, address indexed manager);

    /// @notice Emitted when a recipient is set for an address.
    /// @param sender Sender address.
    /// @param recipient Recipient address.
    event RecipientSet(address indexed sender, address indexed recipient);

    /// @notice Emitted when fee is updated.
    /// @param fee Fee.
    event FeeUpdated(uint256 fee);

    /// @notice Emitted when fee collector is updated.
    /// @param feeCollector Fee collector.
    event FeeCollectorUpdated(address feeCollector);

    /// @notice Emitted when fees are collected.
    /// @param rewardToken Reward token address.
    /// @param amount Amount collected.
    event FeesCollected(address indexed rewardToken, uint256 amount);

    ////////////////////////////////////////////////////////////////
    /// --- ERRORS
    ///////////////////////////////////////////////////////////////

    error KILLED();
    error WRONG_INPUT();
    error ZERO_ADDRESS();
    error INVALID_TOKEN();
    error ALREADY_CLOSED();
    error NO_PERIODS_LEFT();
    error NOT_UPGRADEABLE();
    error AUTH_MANAGER_ONLY();
    error INVALID_NUMBER_OF_PERIODS();

    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ///////////////////////////////////////////////////////////////

    /// @notice Create Bounty platform.
    /// @param _gaugeController Address of the gauge controller.
    constructor(address _gaugeController, address _feeCollector, address _owner) Owned(_owner) {
        fee = _DEFAULT_FEE;
        feeCollector = _feeCollector;
        gaugeController = GaugeController(_gaugeController);
    }

    function name() external pure returns (string memory) {
        return "StakeDAO CRV Votemarket";
    }

    ////////////////////////////////////////////////////////////////
    /// --- BOUNTY CREATION LOGIC
    ///////////////////////////////////////////////////////////////

    /// @notice Create a new bounty.
    /// @param gauge Address of the target gauge.
    /// @param rewardToken Address of the ERC20 used or rewards.
    /// @param numberOfPeriods Number of periods.
    /// @param maxRewardPerVote Target Bias for the Gauge.
    /// @param totalRewardAmount Total Reward Added.
    /// @param blacklist Array of addresses to blacklist.
    /// @return newBountyId of the bounty created.
    function createBounty(
        address gauge,
        address manager,
        address rewardToken,
        uint8 numberOfPeriods,
        uint256 maxRewardPerVote,
        uint256 totalRewardAmount,
        address[] calldata blacklist,
        bool upgradeable
    ) external nonReentrant notKilled returns (uint256 newBountyId) {
        // Revert if the gauge is not registered.
        gaugeController.gauge_types(gauge);

        if (numberOfPeriods < MINIMUM_PERIOD) revert INVALID_NUMBER_OF_PERIODS();
        if (totalRewardAmount == 0 || maxRewardPerVote == 0) revert WRONG_INPUT();
        if (rewardToken == address(0) || manager == address(0)) revert ZERO_ADDRESS();

        uint256 size;
        assembly {
            size := extcodesize(rewardToken)
        }
        if (size == 0) revert INVALID_TOKEN();

        // Transfer the rewards to the contracts.
        SafeTransferLib.safeTransferFrom(rewardToken, msg.sender, address(this), totalRewardAmount);

        unchecked {
            // Get the ID for that new Bounty and increment the nextID counter.
            newBountyId = nextID;

            ++nextID;
        }

        uint256 rewardPerPeriod = totalRewardAmount.mulDiv(1, numberOfPeriods);
        uint256 currentPeriod = getCurrentPeriod();

        bounties[newBountyId] = Bounty({
            gauge: gauge,
            manager: manager,
            rewardToken: rewardToken,
            numberOfPeriods: numberOfPeriods,
            endTimestamp: currentPeriod + ((numberOfPeriods + 1) * _WEEK),
            maxRewardPerVote: maxRewardPerVote,
            totalRewardAmount: totalRewardAmount,
            blacklist: blacklist
        });

        emit BountyCreated(
            newBountyId,
            gauge,
            manager,
            rewardToken,
            numberOfPeriods,
            maxRewardPerVote,
            rewardPerPeriod,
            totalRewardAmount,
            upgradeable
        );

        // Set Upgradeable status.
        isUpgradeable[newBountyId] = upgradeable;
        // Starting from next period.
        activePeriod[newBountyId] = Period(0, currentPeriod + _WEEK, rewardPerPeriod);

        // Add the addresses to the blacklist.
        uint256 length = blacklist.length;
        for (uint256 i = 0; i < length;) {
            isBlacklisted[newBountyId][blacklist[i]] = true;
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Claim rewards for a given bounty.
    /// @param bountyId ID of the bounty.
    /// @return Amount of rewards claimed.
    function claim(uint256 bountyId) external returns (uint256) {
        return _claim(msg.sender, msg.sender, bountyId);
    }

    /// @notice Claim rewards for a given bounty.
    /// @param bountyId ID of the bounty.
    /// @return Amount of rewards claimed.
    function claim(uint256 bountyId, address _recipient) external returns (uint256) {
        return _claim(msg.sender, _recipient, bountyId);
    }

    /// @notice Claim rewards for a given bounty.
    /// @param user User to claim for.
    /// @param bountyId ID of the bounty.
    /// @return Amount of rewards claimed.
    function claimFor(address user, uint256 bountyId) external returns (uint256) {
        address _recipient = recipient[user];
        return _claim(user, _recipient != address(0) ? _recipient : user, bountyId);
    }

    /// @notice Claim all rewards for multiple bounties.
    /// @param ids Array of bounty IDs to claim.
    function claimAll(uint256[] calldata ids) external {
        uint256 length = ids.length;

        for (uint256 i = 0; i < length;) {
            uint256 id = ids[i];

            _claim(msg.sender, msg.sender, id);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Claim all rewards for multiple bounties to a given recipient.
    /// @param ids Array of bounty IDs to claim.
    /// @param _recipient Address to send the rewards to.
    function claimAll(uint256[] calldata ids, address _recipient) external {
        uint256 length = ids.length;

        for (uint256 i = 0; i < length;) {
            uint256 id = ids[i];
            _claim(msg.sender, _recipient, id);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Claim all rewards for multiple bounties on behalf of a user.
    /// @param ids Array of bounty IDs to claim.
    /// @param _user Address to claim the rewards for.
    function claimAllFor(address _user, uint256[] calldata ids) external {
        address _recipient = recipient[_user];
        if (_recipient == address(0)) _recipient = _user;

        uint256 length = ids.length;
        for (uint256 i = 0; i < length;) {
            uint256 id = ids[i];
            _claim(_user, _recipient, id);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Update Bounty for a given id.
    /// @param bountyId ID of the bounty.
    function updateBountyPeriod(uint256 bountyId) external {
        _updateBountyPeriod(bountyId);
    }

    /// @notice Update multiple bounties for given ids.
    /// @param ids Array of Bounty IDs.
    function updateBountyPeriods(uint256[] calldata ids) external {
        uint256 length = ids.length;
        for (uint256 i = 0; i < length;) {
            _updateBountyPeriod(ids[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Set a recipient address for calling user.
    /// @param _recipient Address of the recipient.
    /// @dev Recipient are used when calling claimFor functions. Regular claim functions will use msg.sender as recipient,
    ///  or recipient parameter provided if called by msg.sender.
    function setRecipient(address _recipient) external {
        recipient[msg.sender] = _recipient;

        emit RecipientSet(msg.sender, _recipient);
    }

    ////////////////////////////////////////////////////////////////
    /// --- INTERNAL LOGIC
    ///////////////////////////////////////////////////////////////

    /// @notice Claim rewards for a given bounty.
    /// @param _user Address of the user.
    /// @param _recipient Address of the recipient.
    /// @param _bountyId ID of the bounty.
    /// @return amount of rewards claimed.
    function _claim(address _user, address _recipient, uint256 _bountyId)
        internal
        nonReentrant
        notKilled
        returns (uint256 amount)
    {
        if (isBlacklisted[_bountyId][_user]) return 0;
        // Update if needed the current period.
        uint256 currentPeriod = _updateBountyPeriod(_bountyId);

        Bounty storage bounty = bounties[_bountyId];

        // Get the last_vote timestamp.
        uint256 lastVote = gaugeController.last_user_vote(_user, bounty.gauge);

        GaugeController.VotedSlope memory userSlope = gaugeController.vote_user_slopes(_user, bounty.gauge);

        if (
            userSlope.slope == 0 || lastUserClaim[_user][_bountyId] >= currentPeriod || currentPeriod >= userSlope.end
                || currentPeriod <= lastVote || currentPeriod >= bounty.endTimestamp || currentPeriod != getCurrentPeriod()
                || amountClaimed[_bountyId] == bounty.totalRewardAmount
        ) return 0;

        // Update User last claim period.
        lastUserClaim[_user][_bountyId] = currentPeriod;

        // Voting Power = userSlope * dt
        // with dt = lock_end - period.
        uint256 _bias = _getAddrBias(userSlope.slope, userSlope.end, currentPeriod);
        // Compute the reward amount based on
        // Reward / Total Votes.
        amount = _bias.mulWad(rewardPerVote[_bountyId]);
        // Compute the reward amount based on
        // the max price to pay.
        uint256 _amountWithMaxPrice = _bias.mulWad(bounty.maxRewardPerVote);
        // Distribute the _min between the amount based on votes, and price.
        amount = FixedPointMathLib.min(amount, _amountWithMaxPrice);

        // Update the amount claimed.
        uint256 _amountClaimed = amountClaimed[_bountyId];

        if (amount + _amountClaimed > bounty.totalRewardAmount) {
            amount = bounty.totalRewardAmount - _amountClaimed;
        }

        amountClaimed[_bountyId] += amount;

        uint256 feeAmount;

        if (fee != 0) {
            uint256 _customFee = fees[bounty.manager];
            _customFee = _customFee == 0 ? fee : _customFee;

            feeAmount = amount.mulWad(_customFee);
            amount -= feeAmount;
            feeAccrued[bounty.rewardToken] += feeAmount;
        }

        // Transfer to user.
        SafeTransferLib.safeTransfer(bounty.rewardToken, _recipient, amount);

        emit Claimed(_user, bounty.rewardToken, _bountyId, amount, feeAmount, currentPeriod);
    }

    /// @notice Update the current period for a given bounty.
    /// @param bountyId Bounty ID.
    /// @return current/updated period.
    function _updateBountyPeriod(uint256 bountyId) internal returns (uint256) {
        Period storage _activePeriod = activePeriod[bountyId];

        uint256 currentPeriod = getCurrentPeriod();

        if (_activePeriod.id == 0 && currentPeriod == _activePeriod.timestamp && rewardPerVote[bountyId] == 0) {
            // Check if there is an upgrade in queue and update the bounty.
            _checkForUpgrade(bountyId);
            // Initialize reward per vote.
            // Only for the first period, and if not already initialized.
            _updateRewardPerToken(bountyId, currentPeriod);
        }

        // Increase Period
        if (block.timestamp >= _activePeriod.timestamp + _WEEK) {
            // Checkpoint gauge to have up to date gauge weight.
            gaugeController.checkpoint_gauge(bounties[bountyId].gauge);

            // Check if there is an upgrade in queue and update the bounty.
            _checkForUpgrade(bountyId);

            // Roll to next period.
            _rollOverToNextPeriod(bountyId, currentPeriod);

            return currentPeriod;
        }

        return _activePeriod.timestamp;
    }

    /// @notice Checks for an upgrade and update the bounty.
    function _checkForUpgrade(uint256 bountyId) internal {
        Upgrade storage upgradedBounty = upgradeBountyQueue[bountyId];

        // Check if there is an upgrade in queue.
        if (upgradedBounty.totalRewardAmount != 0) {
            // Save new values.
            bounties[bountyId].endTimestamp = upgradedBounty.endTimestamp;
            bounties[bountyId].numberOfPeriods = upgradedBounty.numberOfPeriods;
            bounties[bountyId].maxRewardPerVote = upgradedBounty.maxRewardPerVote;
            bounties[bountyId].totalRewardAmount = upgradedBounty.totalRewardAmount;

            if (activePeriod[bountyId].id == 0) {
                activePeriod[bountyId].rewardPerPeriod =
                    upgradedBounty.totalRewardAmount.mulDiv(1, upgradedBounty.numberOfPeriods);
            }

            emit BountyDurationIncrease(
                bountyId,
                upgradedBounty.numberOfPeriods,
                upgradedBounty.totalRewardAmount,
                upgradedBounty.maxRewardPerVote
            );

            // Reset the next values.
            delete upgradeBountyQueue[bountyId];
        }
    }

    /// @notice Roll over to next period.
    /// @param bountyId Bounty ID.
    /// @param currentPeriod Next period timestamp.
    function _rollOverToNextPeriod(uint256 bountyId, uint256 currentPeriod) internal {
        uint8 index = getActivePeriodPerBounty(bountyId);

        Bounty storage bounty = bounties[bountyId];

        uint256 periodsLeft = getPeriodsLeft(bountyId);
        uint256 rewardPerPeriod;

        rewardPerPeriod = bounty.totalRewardAmount - amountClaimed[bountyId];

        if (bounty.endTimestamp > currentPeriod + _WEEK && periodsLeft > 1) {
            rewardPerPeriod = rewardPerPeriod.mulDiv(1, periodsLeft);
        }

        // Get adjusted slope without blacklisted addresses.
        uint256 gaugeBias = _getAdjustedBias(bounty.gauge, bounty.blacklist, currentPeriod);

        rewardPerVote[bountyId] = rewardPerPeriod.mulDiv(_BASE_UNIT, gaugeBias);
        activePeriod[bountyId] = Period(index, currentPeriod, rewardPerPeriod);

        emit PeriodRolledOver(bountyId, index, currentPeriod, rewardPerPeriod);
    }

    /// @notice Update the amount of reward per token for a given bounty.
    /// @dev This function is only called once per Bounty.
    function _updateRewardPerToken(uint256 bountyId, uint256 currentPeriod) internal {
        Bounty storage bounty = bounties[bountyId];
        // Checkpoint gauge to have up to date gauge weight.
        gaugeController.checkpoint_gauge(bounty.gauge);

        uint256 gaugeBias = _getAdjustedBias(bounty.gauge, bounty.blacklist, currentPeriod);

        if (gaugeBias != 0) {
            rewardPerVote[bountyId] = activePeriod[bountyId].rewardPerPeriod.mulDiv(_BASE_UNIT, gaugeBias);
        }
    }

    ////////////////////////////////////////////////////////////////
    /// ---  VIEWS
    ///////////////////////////////////////////////////////////////

    /// @notice Get an estimate of the reward amount for a given user.
    /// @param user Address of the user.
    /// @param bountyId ID of the bounty.
    /// @return amount of rewards.
    /// Mainly used for UI.
    function claimable(address user, uint256 bountyId) external view returns (uint256 amount) {
        if (isBlacklisted[bountyId][user]) return 0;

        Bounty memory bounty = bounties[bountyId];
        // If there is an upgrade in progress but period hasn't been rolled over yet.
        Upgrade storage upgradedBounty = upgradeBountyQueue[bountyId];

        // Update if needed the current period.
        uint256 currentPeriod = getCurrentPeriod();
        // End timestamp of the bounty.
        uint256 endTimestamp = FixedPointMathLib.max(bounty.endTimestamp, upgradedBounty.endTimestamp);
        // Get the last_vote timestamp.
        uint256 lastVote = gaugeController.last_user_vote(user, bounty.gauge);

        GaugeController.VotedSlope memory userSlope = gaugeController.vote_user_slopes(user, bounty.gauge);

        if (
            userSlope.slope == 0 || lastUserClaim[user][bountyId] >= currentPeriod || currentPeriod >= userSlope.end
                || currentPeriod <= lastVote || currentPeriod >= endTimestamp
                || currentPeriod < getActivePeriod(bountyId).timestamp
                || amountClaimed[bountyId] >= bounty.totalRewardAmount
        ) return 0;

        uint256 _rewardPerVote = rewardPerVote[bountyId];

        // If period updated.
        if (_rewardPerVote == 0 || (_rewardPerVote > 0 && getActivePeriod(bountyId).timestamp != currentPeriod)) {
            uint256 _rewardPerPeriod;

            if (upgradedBounty.numberOfPeriods != 0) {
                // Update max reward per vote.
                bounty.maxRewardPerVote = upgradedBounty.maxRewardPerVote;
                bounty.totalRewardAmount = upgradedBounty.totalRewardAmount;
            }

            uint256 periodsLeft = endTimestamp > currentPeriod ? (endTimestamp - currentPeriod) / _WEEK : 0;
            _rewardPerPeriod = bounty.totalRewardAmount - amountClaimed[bountyId];

            if (endTimestamp > currentPeriod + _WEEK && periodsLeft > 1) {
                _rewardPerPeriod = _rewardPerPeriod.mulDiv(1, periodsLeft);
            }

            // Get Adjusted Slope without blacklisted addresses weight.
            uint256 gaugeBias = _getAdjustedBias(bounty.gauge, bounty.blacklist, currentPeriod);
            _rewardPerVote = _rewardPerPeriod.mulDiv(_BASE_UNIT, gaugeBias);
        }
        // Get user voting power.
        uint256 _bias = _getAddrBias(userSlope.slope, userSlope.end, currentPeriod);

        // Estimation of the amount of rewards.
        amount = _bias.mulWad(_rewardPerVote);
        // Compute the reward amount based on
        // the max price to pay.
        uint256 _amountWithMaxPrice = _bias.mulWad(bounty.maxRewardPerVote);
        // Distribute the _min between the amount based on votes, and price.
        amount = FixedPointMathLib.min(amount, _amountWithMaxPrice);

        uint256 _amountClaimed = amountClaimed[bountyId];
        // Update the amount claimed.
        if (amount + _amountClaimed > bounty.totalRewardAmount) {
            amount = bounty.totalRewardAmount - _amountClaimed;
        }
        // Substract fees.
        if (fee != 0) {
            uint256 _customFee = fees[bounty.manager];
            _customFee = _customFee == 0 ? fee : _customFee;
            amount = amount.mulWad(_BASE_UNIT - _customFee);
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- INTERNAL VIEWS
    ///////////////////////////////////////////////////////////////

    /// @notice Get adjusted slope from Gauge Controller for a given gauge address.
    /// Remove the weight of blacklisted addresses.
    /// @param gauge Address of the gauge.
    /// @param _addressesBlacklisted Array of blacklisted addresses.
    /// @param period   Timestamp to check vote weight.
    function _getAdjustedBias(address gauge, address[] memory _addressesBlacklisted, uint256 period)
        internal
        view
        returns (uint256 gaugeBias)
    {
        // Cache the user slope.
        GaugeController.VotedSlope memory userSlope;
        // Bias
        uint256 _bias;
        // Last Vote
        uint256 _lastVote;
        // Cache the length of the array.
        uint256 length = _addressesBlacklisted.length;
        // Cache blacklist.
        // Get the gauge slope.
        gaugeBias = gaugeController.points_weight(gauge, period).bias;

        for (uint256 i = 0; i < length;) {
            // Get the user slope.
            userSlope = gaugeController.vote_user_slopes(_addressesBlacklisted[i], gauge);
            _lastVote = gaugeController.last_user_vote(_addressesBlacklisted[i], gauge);
            if (period > _lastVote) {
                _bias = _getAddrBias(userSlope.slope, userSlope.end, period);
                gaugeBias -= _bias;
            }
            // Increment i.
            unchecked {
                ++i;
            }
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- MANAGEMENT LOGIC
    ///////////////////////////////////////////////////////////////

    /// @notice Increase Bounty duration.
    /// @param _bountyId ID of the bounty.
    /// @param _additionnalPeriods Number of periods to add.
    /// @param _increasedAmount Total reward amount to add.
    /// @param _newMaxPricePerVote Total reward amount to add.
    function increaseBountyDuration(
        uint256 _bountyId,
        uint8 _additionnalPeriods,
        uint256 _increasedAmount,
        uint256 _newMaxPricePerVote
    ) external {
        _increaseBountyDuration(_bountyId, _additionnalPeriods, _increasedAmount, _newMaxPricePerVote);
    }

    function _increaseBountyDuration(
        uint256 _bountyId,
        uint8 _additionnalPeriods,
        uint256 _increasedAmount,
        uint256 _newMaxPricePerVote
    ) internal nonReentrant notKilled onlyManager(_bountyId) {
        if (!isUpgradeable[_bountyId]) revert NOT_UPGRADEABLE();
        if (getPeriodsLeft(_bountyId) < 1) revert NO_PERIODS_LEFT();

        Bounty storage bounty = bounties[_bountyId];
        Upgrade memory upgradedBounty = upgradeBountyQueue[_bountyId];

        if (_increasedAmount > 0) {
            SafeTransferLib.safeTransferFrom(bounty.rewardToken, msg.sender, address(this), _increasedAmount);
        }

        uint256 updatedMaxRewardPerVote = bounty.maxRewardPerVote;
        if (_newMaxPricePerVote > 0) {
            updatedMaxRewardPerVote = _newMaxPricePerVote;
        }

        if (upgradedBounty.totalRewardAmount != 0) {
            upgradedBounty = Upgrade({
                numberOfPeriods: upgradedBounty.numberOfPeriods + _additionnalPeriods,
                totalRewardAmount: upgradedBounty.totalRewardAmount + _increasedAmount,
                maxRewardPerVote: updatedMaxRewardPerVote,
                endTimestamp: upgradedBounty.endTimestamp + (_additionnalPeriods * _WEEK)
            });
        } else {
            upgradedBounty = Upgrade({
                numberOfPeriods: bounty.numberOfPeriods + _additionnalPeriods,
                totalRewardAmount: bounty.totalRewardAmount + _increasedAmount,
                maxRewardPerVote: updatedMaxRewardPerVote,
                endTimestamp: bounty.endTimestamp + (_additionnalPeriods * _WEEK)
            });
        }

        upgradeBountyQueue[_bountyId] = upgradedBounty;

        emit BountyDurationIncreaseQueued(
            _bountyId, upgradedBounty.numberOfPeriods, upgradedBounty.totalRewardAmount, _newMaxPricePerVote
        );
    }

    /// @notice Close Bounty if there is remaining.
    /// @param bountyId ID of the bounty to close.
    function closeBounty(uint256 bountyId) external {
        _closeBounty(bountyId);
    }

    function closeBounties(uint256[] calldata bountyIds) external {
        uint256 length = bountyIds.length;

        for (uint256 i = 0; i < length;) {
            _closeBounty(bountyIds[i]);

            unchecked {
                ++i;
            }
        }
    }

    function _closeBounty(uint256 bountyId) internal nonReentrant onlyManager(bountyId) {
        // Check if the currentPeriod is the last one.
        // If not, we can increase the duration.
        Bounty storage bounty = bounties[bountyId];

        // Check if there is an upgrade in queue and update the bounty.
        _checkForUpgrade(bountyId);

        if (getCurrentPeriod() >= bounty.endTimestamp || isKilled) {
            uint256 leftOver;
            Upgrade memory upgradedBounty = upgradeBountyQueue[bountyId];

            if (upgradedBounty.totalRewardAmount != 0) {
                leftOver = upgradedBounty.totalRewardAmount - amountClaimed[bountyId];
                delete upgradeBountyQueue[bountyId];
            } else {
                leftOver = bounties[bountyId].totalRewardAmount - amountClaimed[bountyId];
            }

            // Transfer the left over to the owner.
            SafeTransferLib.safeTransfer(bounty.rewardToken, bounty.manager, leftOver);
            delete bounties[bountyId].manager;

            emit BountyClosed(bountyId, leftOver);
        }
    }

    /// @notice Update Bounty Manager.
    /// @param bountyId ID of the bounty.
    /// @param newManager Address of the new manager.
    function updateManager(uint256 bountyId, address newManager) external onlyManager(bountyId) {
        if (newManager == address(0)) revert ZERO_ADDRESS();

        emit ManagerUpdated(bountyId, bounties[bountyId].manager = newManager);
    }

    ////////////////////////////////////////////////////////////////
    /// --- ONLY OWNER FUNCTIONS
    ///////////////////////////////////////////////////////////////

    /// @notice Claim fees.
    /// @param rewardTokens Array of reward tokens.
    function claimFees(address[] calldata rewardTokens) external nonReentrant {
        uint256 _feeAccrued;
        uint256 length = rewardTokens.length;

        for (uint256 i = 0; i < length;) {
            address rewardToken = rewardTokens[i];

            _feeAccrued = feeAccrued[rewardToken];
            delete feeAccrued[rewardToken];

            emit FeesCollected(rewardToken, _feeAccrued);

            SafeTransferLib.safeTransfer(rewardToken, feeCollector, _feeAccrued);

            unchecked {
                i++;
            }
        }
    }

    /// @notice Set the platform fee.
    /// @param _platformFee Platform fee.
    function setPlatformFee(uint256 _platformFee) external onlyOwner {
        if (_platformFee > 1e18) revert WRONG_INPUT();

        fee = _platformFee;

        emit FeeUpdated(_platformFee);
    }

    /// @notice Set the fee collector.
    /// @param _feeCollector Address of the fee collector.
    function setFeeCollector(address _feeCollector) external onlyOwner {
        feeCollector = _feeCollector;

        emit FeeCollectorUpdated(_feeCollector);
    }

    /// @notice Set a custom fee for a given manager.
    /// @param _manager Address of the manager.
    /// @param _fee Fee.
    function setCustomFee(address _manager, uint256 _fee) external onlyOwner {
        if (_fee > 1e18) revert WRONG_INPUT();

        fees[_manager] = _fee;
    }

    /// @notice Set the recipient for a given address.
    /// @param _for Address to set the recipient for.
    /// @param _recipient Address of the recipient.
    function setRecipientFor(address _for, address _recipient) external onlyOwner {
        recipient[_for] = _recipient;

        emit RecipientSet(_for, _recipient);
    }

    function kill() external onlyOwner {
        isKilled = true;
    }

    ////////////////////////////////////////////////////////////////
    /// --- UTILS FUNCTIONS
    ///////////////////////////////////////////////////////////////

    /// @notice Returns the number of periods left for a given bounty.
    /// @param bountyId ID of the bounty.
    function getPeriodsLeft(uint256 bountyId) public view returns (uint256 periodsLeft) {
        Bounty storage bounty = bounties[bountyId];

        uint256 currentPeriod = getCurrentPeriod();
        periodsLeft = bounty.endTimestamp > currentPeriod ? (bounty.endTimestamp - currentPeriod) / _WEEK : 0;
    }

    /// @notice Return the bounty object for a given ID.
    /// @param bountyId ID of the bounty.
    function getBounty(uint256 bountyId) external view returns (Bounty memory) {
        return bounties[bountyId];
    }

    /// @notice Return the bounty in queue for a given ID.
    /// @dev Can return an empty bounty if there is no upgrade.
    /// @param bountyId ID of the bounty.
    function getUpgradedBountyQueued(uint256 bountyId) external view returns (Upgrade memory) {
        return upgradeBountyQueue[bountyId];
    }

    /// @notice Return the blacklisted addresses of a bounty for a given ID.
    /// @param bountyId ID of the bounty.
    function getBlacklistedAddressesPerBounty(uint256 bountyId) external view returns (address[] memory) {
        return bounties[bountyId].blacklist;
    }

    /// @notice Return the active period running of bounty given an ID.
    /// @param bountyId ID of the bounty.
    function getActivePeriod(uint256 bountyId) public view returns (Period memory) {
        return activePeriod[bountyId];
    }

    /// @notice Return the expected current period id.
    /// @param bountyId ID of the bounty.
    function getActivePeriodPerBounty(uint256 bountyId) public view returns (uint8) {
        Bounty storage bounty = bounties[bountyId];

        uint256 currentPeriod = getCurrentPeriod();
        uint256 periodsLeft = bounty.endTimestamp > currentPeriod ? (bounty.endTimestamp - currentPeriod) / _WEEK : 0;
        // If periodsLeft is superior, then the bounty didn't start yet.
        return uint8(periodsLeft > bounty.numberOfPeriods ? 0 : bounty.numberOfPeriods - periodsLeft);
    }

    /// @notice Return the current period based on Gauge Controller rounding.
    function getCurrentPeriod() public view returns (uint256) {
        return (block.timestamp / _WEEK) * _WEEK;
    }

    /// @notice Return the bias of a given address based on its lock end date and the current period.
    /// @param userSlope User slope.
    /// @param endLockTime Lock end date of the address.
    /// @param currentPeriod Current period.
    function _getAddrBias(uint256 userSlope, uint256 endLockTime, uint256 currentPeriod)
        internal
        pure
        returns (uint256)
    {
        if (currentPeriod >= endLockTime) return 0;
        return userSlope * (endLockTime - currentPeriod);
    }

    function getVersion() external pure returns (string memory) {
        return "2.3.0";
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface GaugeController {
    struct VotedSlope {
        uint256 slope;
        uint256 power;
        uint256 end;
    }

    struct Point {
        uint256 bias;
        uint256 slope;
    }

    function vote_user_slopes(address, address) external view returns (VotedSlope memory);

    function add_gauge(address, int128) external;

    function WEIGHT_VOTE_DELAY() external view returns (uint256);

    function last_user_vote(address, address) external view returns (uint256);

    function points_weight(address, uint256) external view returns (Point memory);

    function checkpoint_gauge(address) external;

    //solhint-disable-next-line
    function gauge_types(address addr) external view returns (int128);

    //solhint-disable-next-line
    function gauge_relative_weight_write(address addr, uint256 timestamp) external returns (uint256);

    //solhint-disable-next-line
    function gauge_relative_weight(address addr) external view returns (uint256);

    //solhint-disable-next-line
    function gauge_relative_weight(address addr, uint256 timestamp) external view returns (uint256);

    //solhint-disable-next-line
    function get_total_weight() external view returns (uint256);

    //solhint-disable-next-line
    function get_gauge_weight(address addr) external view returns (uint256);

    ///@notice Allocate voting power for changing pool weights.
    function vote_for_gauge_weights(address, uint256) external;

    function add_type(string memory, uint256) external;

    function admin() external view returns (address);
}