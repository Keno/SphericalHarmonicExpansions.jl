@testset "macro for generating fast functions" begin
	ε = 100*eps(Float64)
	t1,t2,t3 = randn(3)

	f(x1,x2,x3) = 3*x3^2 + 2*x2*x1
	@polyvar x y z
	polynomial = 3*z^2 + 2*y*x
	g = @fastfunc polynomial
	@test isapprox(f(t1,t2,t3),g(t1,t2,t3),atol=ɛ)

	# Test inside function scope
	function useInsideFunction1()
		polynomial = 3*z^2 + 2*y*x
		g = @fastfunc polynomial
		
		t1,t2,t3 = randn(3)
		@test isapprox(f(t1,t2,t3),Base.invokelatest(g, t1,t2,t3),atol=ɛ)
		return Base.invokelatest(g, t1,t2,t3)
	end
	useInsideFunction1()

	h = fastfunc(polynomial)
	@test isapprox(f(t1,t2,t3),h(t1,t2,t3),atol=ɛ)

	# Test inside function scope
	function useInsideFunction2()
		polynomial = 3*z^2 + 2*y*x
		g = fastfunc(polynomial)
		
		t1,t2,t3 = randn(3)
		@test isapprox(f(t1,t2,t3),Base.invokelatest(g, t1,t2,t3),atol=ɛ)
		return Base.invokelatest(g, t1,t2,t3)
	end
	useInsideFunction2()
end
