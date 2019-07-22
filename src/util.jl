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
A type to handle missing db items.
"""
struct MissingItemHandler
    name::Symbol
    value::Any
    handled::Ref{Bool}
    MissingItemHandler(name, value) = new(name, value, false)
end


"""
    (f::MissingItemHandler)(args...; kwargs...)

If `f.name` is defined in `SpineInterface`, call it and return the result;
oterwise just return `f.value` and issue a warning.
"""
function (f::MissingItemHandler)(args...; kwargs...)
    try
        getfield(SpineInterface, f.name)(args...; kwargs...)
    catch e
        !(e isa UndefVarError) && rethrow()
        if !f.handled[]
            @warn "SpineInterface.$(f.name) is not defined"
            f.handled[] = true
        end
        f.value
    end
end

"""
    indices(p::Parameter; value_filter=x->x!=nothing, kwargs...)

A set of indices corresponding to `p`, optionally filtered by `kwargs`.
"""
function indices(p::Parameter; skip_values=(), kwargs...)
    skip_values = (skip_values..., nothing)
    d = p.class_values
    new_kwargs = Dict()
    for (obj_cls, obj) in kwargs
        if obj != anything
            push!(new_kwargs, obj_cls => Object.(obj))
        end
    end
    result = []
    for (key, value) in d
        iargs = Dict(i => new_kwargs[k] for (i, k) in enumerate(key) if k in keys(new_kwargs))
        append!(
            result,
            NamedTuple{key}(ind) for (ind, val) in value
            if all(ind[i] in v for (i, v) in iargs) && !(val() in skip_values)
        )
    end
    result
end

function indices(f::MissingItemHandler; kwargs...)
    try
        indices(getfield(SpineInterface, f.name); kwargs...)
    catch e
        !(e isa UndefVarError) && rethrow()
        if !f.handled[]
            @warn "SpineInterface.$(f.name) is not defined"
            f.handled[] = true
        end
        ()
    end
end

"""
    to_database(x)

A JSON representation of `x` to go in a Spine database.
"""
to_database(x::Union{DateTime_,DurationLike,TimePattern,TimeSeries}) = PyObject(x).to_database()
