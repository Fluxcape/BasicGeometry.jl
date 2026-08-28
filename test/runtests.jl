#=
 * @ author: chenyubao <chenyu.bao@outlook.com>
 * @ date: 2026-08-28 15:15:27
 * @ license: MIT
 =#

using Test
using BasicGeometry
using StaticArrays

@testset "BasicGeometry" begin
    @testset "2D" begin
        @testset "Rectangle" begin
            geo = Rectangle((0.0f0, 0.0), (1.0, 1.0))
            @test inside(geo, SVector(0.5, 0.5)) == true
            @test inside(geo, SVector(-0.1, 0.5)) == false
            @test dim(geo) == 2
            dr = 0.2
            @test num(geo, dr) == 25
            points = discrete(geo, dr)
            @test size(points) == (25, 3)
        end
        @testset "Ring" begin
            geo = Ring((0.0f0, 0.0), 1.0, 2.0)
            @test inside(geo, SVector(1.5, 0.0)) == true
            @test inside(geo, SVector(0.5, 0.0)) == false
            @test dim(geo) == 2
            dr = 0.5
            n = round(Int, 1.25 * 2 * pi / dr) + round(Int, 1.75 * 2 * pi / dr)
            @test num(geo, dr) == n
            points = discrete(geo, dr)
            @test size(points) == (n, 3)
        end
        @testset "Circle" begin
            geo = Circle((0.0f0, 0.0), 1.0)
            @test inside(geo, SVector(0.5, 0.0)) == true
            @test inside(geo, SVector(1.5, 0.0)) == false
            @test dim(geo) == 2
            dr = 0.5
            n = 12
            @test num(geo, dr) == n
            points = discrete(geo, dr)
            @test size(points) == (n, 3)
        end
    end
    @testset "3D" begin
        @testset "Cuboid" begin
            geo = Cuboid((0.0f0, 0.0, 0.0), (2.0, 3.0, 4.0))
            @test inside(geo, SVector(0.5, 0.5, 0.5)) == true
            @test inside(geo, SVector(-0.1, 0.5, 0.5)) == false
            @test dim(geo) == 3
            dr = 0.5
            @test num(geo, dr) == 8 * 24
            points = discrete(geo, dr)
            @test size(points) == (8 * 24, 4)
        end
    end
end