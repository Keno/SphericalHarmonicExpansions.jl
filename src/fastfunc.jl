"""
@fastfunc functionname polynomial

Generates a function for fast numerical evaluation. The number of input
arguments of the generated function will match the number of variables in the
input polynomial.

Note that the polynomial is transformed using `@fastmath`, which calls 
functions that may violate strict IEEE semantics.

If you only plan a few evaluations of polynomial use the standard method (see
e.g. TypedPolynomials for details). Only for a large number of evaluations the
one can break even with the function generated by this method due to the just 
in time compilation overhead.

# Examples
```
julia> using SphericalHarmonics

julia> @polyvar x y z
(x, y, z)

julia> p = 15.0*x*y^2+7.5*x*z^13
7.5xz¹³ + 15.0xy²

julia> foo = @fastfunc p

julia> foo(1.0,2.0,3.0)
1.19574825e7
```

# Non-global scope

Usage from within local scope requires special care to avoid issue #4. So
instead of `foo(1.0,2.0,3.0)` we need `Base.invokelatest(foo, 1.0,2.0,3.0)`.

```
julia> using SphericalHarmonics

julia> @polyvar x y z
(x, y, z)

julia> function useInsideFunctionScope()
           p = 15.0*x*y^2+7.5*x*z^13
           foo = @fastfunc p
           Base.invokelatest(foo, 1.0,2.0,3.0)
       end
useInsideFunctionScope (generic function with 1 method)

julia> useInsideFunctionScope()
1.19574825e7
```
"""
macro fastfunc(polynomial)
	return quote
		local polystr = string($(esc(polynomial)))
		local vars = string(tuple(variables($(esc(polynomial)))...))
        # create expression for function definition
		eval(Meta.parse(vars*" -> @fastmath "*polystr))
	end
end

"""
fastfunc(polynomial::Polynomial)

Generates a function for fast numerical evaluation. The number of input
arguments of the generated function will match the number of variables in the
input polynomial.

Note that the polynomial is transformed using `@fastmath`, which calls 
functions that may violate strict IEEE semantics.

If you only plan a few evaluations of polynomial use the standard method (see
e.g. TypedPolynomials for details). Only for a large number of evaluations the
one can break even with the function generated by this method due to the just 
in time compilation overhead.

# Examples

```
julia> using SphericalHarmonics

julia> @polyvar x y z
(x, y, z)

julia> p = 15.0*x*y^2+7.5*x*z^13
7.5xz¹³ + 15.0xy²

julia> foo = fastfunc(p)

julia> foo(1.0,2.0,3.0)
1.19574825e7
```
"""
function fastfunc(polynomial)
    expr = Meta.parse(string(variables(polynomial))*" -> "*string(polynomial))
    # use fastmath
    expr = Base.FastMath.make_fastmath(expr)
    return mk_function(expr)
end