#=
 * @ author: chenyubao <chenyu.bao@outlook.com>
 * @ date: 2026-08-28 14:38:59
 * @ license: MIT
 =#

export Rectangle
export Ring
export Circle

#*===== Rectangle =====*#

struct Rectangle{T <: Real} <: AbstractBasicGeometry{2}
    x1_::SVector{2, T}
    x2_::SVector{2, T}
end

@inline function Rectangle(x1, x2)
    @assert length(x1) == 2 && length(x2) == 2 "Only 2D rectangle is supported."
    @assert all(x1 .< x2) "Invalid rectangle coordinates."
    T = promote_type(eltype(x1), eltype(x2))
    return Rectangle{T}(SVector{2, T}(x1...), SVector{2, T}(x2...))
end

@inline function inside(g::Rectangle, x::StaticVector{2})
    return all(g.x1_ .<= x .<= g.x2_)
end

@inline function num(g::Rectangle, dr::Real)::Int
    return prod(round.(Int, (g.x2_ - g.x1_) ./ dr))
end

@inline function discrete!(g::Rectangle, dr::Real, points::AbstractMatrix)::Nothing
    T = eltype(points)
    n = num(g, dr)
    nx, ny = round.(Int, (g.x2_ - g.x1_) ./ dr)
    dx::T = (g.x2_[1] - g.x1_[1]) / nx
    dy::T = (g.x2_[2] - g.x1_[2]) / ny
    vol::T = dx * dy
    @assert size(points, 1) >= n "The points matrix must have enough rows to store the discrete pointss."
    @assert size(points, 2) >= 3 "The points matrix must have at least 3 columns to store the coordinates and volume."
    for idx = 1:n
        ix = mod1(idx, nx)
        iy = cld(idx, nx)
        x = g.x1_[1] + (ix - T(0.5f0)) * dx
        y = g.x1_[2] + (iy - T(0.5f0)) * dy
        points[idx, 1] = x
        points[idx, 2] = y
        points[idx, 3] = vol
    end
    return nothing
end

#*===== Ring =====*#

struct Ring{T <: Real} <: AbstractBasicGeometry{2}
    center_::SVector{2, T}
    r1_::T
    r2_::T
end

@inline function Ring(center, r1, r2)
    @assert length(center) == 2 "Only 2D ring is supported."
    @assert r1 < r2 "Invalid ring radii."
    T = promote_type(eltype(center), typeof(r1), typeof(r2))
    return Ring{T}(SVector{2, T}(center...), T(r1), T(r2))
end

@inline function inside(g::Ring, x::StaticVector{2})
    r = StaticArrays.norm(x - g.center_)
    return g.r1_ <= r <= g.r2_
end

@inline function num(g::Ring, dr::Real)::Int
    T = typeof(dr)
    radius_span = g.r2_ - g.r1_
    n_layers = round(Int, radius_span / dr)
    n::Int = 0
    for i = 1:n_layers
        r = g.r1_ + T(i - 0.5f0) * dr
        n += round(Int, 2 * pi * r / dr)
    end
    return n
end

@inline function discrete!(g::Ring, dr::Real, points::AbstractMatrix)::Nothing
    T = eltype(points)
    n = num(g, dr)
    @assert size(points, 1) >= n "The points matrix must have enough rows to store the discrete points."
    @assert size(points, 2) >= 3 "The points matrix must have at least 3 columns to store the coordinates and volume."
    radius_span = g.r2_ - g.r1_
    n_layers = round(Int, radius_span / dr)
    idx = 1
    for i = 1:n_layers
        r = g.r1_ + T(i - 0.5f0) * dr
        circumference = 2 * pi * r
        n_points = round(Int, circumference / dr)
        for j in 1:n_points
            theta = (j - 0.5f0) * 2 * pi / n_points
            x = g.center_[1] + r * cos(theta)
            y = g.center_[2] + r * sin(theta)
            points[idx, 1] = x
            points[idx, 2] = y
            points[idx, 3] = circumference / n_points * dr
            idx += 1
        end
    end
    return nothing
end

#*===== Circle =====*#

struct Circle{T <: Real} <: AbstractBasicGeometry{2}
    center_::SVector{2, T}
    radius_::T
end

@inline function Circle(center, radius)
    @assert length(center) == 2 "Only 2D circle is supported."
    @assert radius > 0 "Invalid circle radius."
    T = promote_type(eltype(center), typeof(radius))
    return Circle{T}(SVector{2, T}(center...), T(radius))
end

@inline function inside(g::Circle, x::StaticVector{2})
    r = StaticArrays.norm(x - g.center_)
    return r <= g.radius_
end

@inline function num(g::Circle, dr::Real)::Int
    T = typeof(dr)
    n_layers = round(Int, g.radius_ / dr)
    n::Int = 0
    for i = 1:n_layers
        r = T(i - 0.5f0) * dr
        n += round(Int, 2 * pi * r / dr)
    end
    return n
end

@inline function discrete!(g::Circle, dr::Real, points::AbstractMatrix)::Nothing
    T = eltype(points)
    n = num(g, dr)
    @assert size(points, 1) >= n "The points matrix must have enough rows to store the discrete points."
    @assert size(points, 2) >= 3 "The points matrix must have at least 3 columns to store the coordinates and volume."
    n_layers = round(Int, g.radius_ / dr)
    idx = 1
    for i = 1:n_layers
        r = T(i - 0.5f0) * dr
        circumference = 2 * pi * r
        n_points = round(Int, circumference / dr)
        for j in 1:n_points
            theta = (j - 0.5f0) * 2 * pi / n_points
            x = g.center_[1] + r * cos(theta)
            y = g.center_[2] + r * sin(theta)
            points[idx, 1] = x
            points[idx, 2] = y
            points[idx, 3] = circumference / n_points * dr
            idx += 1
        end
    end
    return nothing
end