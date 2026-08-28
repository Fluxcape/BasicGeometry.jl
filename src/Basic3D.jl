#=
 * @ author: chenyubao <chenyu.bao@outlook.com>
 * @ date: 2026-08-28 15:10:30
 * @ license: MIT
 =#

export Cuboid

#*==== Cuboid ====*#

struct Cuboid{T <: Real} <: AbstractBasicGeometry{3}
    x1_::SVector{3, T}
    x2_::SVector{3, T}
end

@inline function Cuboid(x1, x2)
    @assert length(x1) == 3 && length(x2) == 3 "Only 3D cuboid is supported."
    @assert all(x1 .< x2) "Invalid cuboid coordinates."
    T = promote_type(eltype(x1), eltype(x2))
    return Cuboid{T}(SVector{3, T}(x1...), SVector{3, T}(x2...))
end

@inline function inside(g::Cuboid, x::StaticVector{3})::Bool
    return all(g.x1_ .<= x .<= g.x2_)
end

@inline function num(g::Cuboid, dr::Real)::Int
    return prod(round.(Int, (g.x2_ - g.x1_) ./ dr))
end

@inline function discrete!(g::Cuboid, dr::Real, points::AbstractMatrix)::Nothing
    T = eltype(points)
    n = num(g, dr)
    nx, ny, nz = round.(Int, (g.x2_ - g.x1_) ./ dr)
    dx::T = (g.x2_[1] - g.x1_[1]) / nx
    dy::T = (g.x2_[2] - g.x1_[2]) / ny
    dz::T = (g.x2_[3] - g.x1_[3]) / nz
    vol::T = dx * dy * dz
    @assert size(points, 1) >= n "The points matrix must have enough rows to store the discrete pointss."
    @assert size(points, 2) >= 4 "The points matrix must have at least 4 columns to store the coordinates and volume."
    for idx = 1:n
        ix = mod1(idx, nx)
        iz = cld(idx, nx * ny)
        l = idx - (iz - 1) * nx * ny - ix
        iy = cld(l, nx) + 1
        x = g.x1_[1] + (ix - T(0.5f0)) * dx
        y = g.x1_[2] + (iy - T(0.5f0)) * dy
        z = g.x1_[3] + (iz - T(0.5f0)) * dz
        points[idx, 1] = x
        points[idx, 2] = y
        points[idx, 3] = z
        points[idx, 4] = vol
    end
    return nothing
end
