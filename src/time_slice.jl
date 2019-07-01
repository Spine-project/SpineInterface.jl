#############################################################################
# Copyright (C) 2017 - 2018  Spine Project
#
# This file is part of Spine Model.
#
# Spine Model is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Spine Model is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
"""
    TimeSlice

A type for representing a slice of time.
"""
struct TimeSlice <: ObjectLike
    start::DateTime
    end_::DateTime
    duration::Period
    blocks::Tuple
    JuMP_name::String
    TimeSlice(x, y, blk, n) = x > y ? error("out of order") : new(x, y, Minute(y - x), blk, n)
end

"""
    TimeSlice(start::DateTime, end_::DateTime)

Construct a `TimeSlice` with bounds given by `start` and `end_`.
"""
TimeSlice(start::DateTime, end_::DateTime, blocks::Object...) = TimeSlice(start, end_, blocks, "$start...$end_")
TimeSlice(other::TimeSlice) = other

Base.show(io::IO, time_slice::TimeSlice) = print(io, time_slice.JuMP_name)

"""
    duration(t::TimeSlice)

The duration of time slice `t` in minutes.
"""
duration(t::TimeSlice) = t.duration.value

start(t::TimeSlice) = t.start
end_(t::TimeSlice) = t.end_

Base.isless(a::TimeSlice, b::TimeSlice) = tuple(a.start, a.end_) < tuple(b.start, b.end_)


"""
    before(a::TimeSlice, b::TimeSlice)

Determine whether the end point of `a` is exactly the start point of `b`.
"""
before(a::TimeSlice, b::TimeSlice) = b.start == a.end_


"""
    iscontained(b::TimeSlice, a::TimeSlice)

Determine whether `b` is contained in `a`.
"""
iscontained(b::TimeSlice, a::TimeSlice) = b.start >= a.start && b.end_ <= a.end_
iscontained(b::DateTime, a::TimeSlice) = a.start <= b <= a.end_

"""
    overlaps(a::TimeSlice, b::TimeSlice)

Determine whether `a` and `b` overlap.
"""
overlaps(a::TimeSlice, b::TimeSlice) = a.start <= b.start < a.end_ || b.start <= a.start < b.end_

"""
    overlap_duration(a::TimeSlice, b::TimeSlice)

The number of minutes where `a` and `b` overlap.
"""
function overlap_duration(a::TimeSlice, b::TimeSlice)
    overlaps(a, b) || return 0
    overlap_start = max(a.start, b.start)
    overlap_end = min(a.end_, b.end_)
    Minute(overlap_end - overlap_start).value
end

# Iterate single `TimeSlice` as collection. NOTE: This also enables `intersect` with a single `TimeSlice`
# I believe this is correct, since a single `TimeSlice` shouldn't be decomposed by an iterator
# This is also Julia's default behaviour for `Number` types -Manuel
Base.iterate(t::TimeSlice) = iterate((t,))
Base.iterate(t::TimeSlice, state::T) where T = iterate((t,), state)
Base.length(t::TimeSlice) = 1

function Base.intersect(s::Array{TimeSlice,1}, itrs...)
    sort!(s)
    for itr in itrs
        s = [s[i] for t in itr for i in searchsorted(s, t)]
    end
    unique_sorted(s)
end

Base.intersect(s::Array{TimeSlice,1}, ::Anything) = s

# Convenience subtraction operator
Base.:-(t::TimeSlice, p::Period) = TimeSlice(t.start - p, t.end_ - p)

"""
    t_lowest_resolution(iter)

An `Array` with the `TimeSlice`s from the given iterable that
are not contained in any other.
"""
function t_lowest_resolution(t_iter)
    isempty(t_iter) && return []
    t_coll = collect(t_iter)
    sort!(t_coll)
    result::Array{TimeSlice,1} = [t_coll[1]]
    for t in t_coll[2:end]
        if result[end] in t
            result[end] = t
        elseif !(t in result[end])
            push!(result, t)
        end
    end
    result
end


"""
    t_highest_resolution(iter)

An `Array` with the `TimeSlice`s from the given iterable that do not contain any other.
"""
function t_highest_resolution(t_iter)
    isempty(t_iter) && return []
    t_coll = collect(t_iter)
    sort!(t_coll)
    result::Array{TimeSlice,1} = [t_coll[1]]
    for t in t_coll[2:end]
        result[end] in t || push!(result, t)
    end
    result
end
