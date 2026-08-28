#=
 * @ author: chenyubao <chenyu.bao@outlook.com>
 * @ date: 2026-08-27 16:33:33
 * @ license: MIT
 =#

module BasicGeometry

export AbstractBasicGeometry
export dim
export inside, outside
export num, discrete!, discrete

using StaticArrays

abstract type AbstractBasicGeometry{N} end

@inline dim(::AbstractBasicGeometry{N}) where {N} = N
@inline inside(::AbstractBasicGeometry, x) = true
@inline outside(g::AbstractBasicGeometry, x) = !inside(g, x)
@inline num(::AbstractBasicGeometry, dr::Real)::Int = 1
@inline discrete!(::AbstractBasicGeometry, ::Real, ::AbstractMatrix)::Nothing = nothing
@inline function discrete(g::AbstractBasicGeometry, dr::Real)
    T = typeof(dr)
    points = zeros(T, num(g, dr), dim(g) + 1)
    discrete!(g, dr, points)
    return points
end

include("Basic2D.jl")
include("Basic3D.jl")

end # module BasicGeometry
