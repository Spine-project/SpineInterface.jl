module SpineInterface

using PyCall
using JSON
using Dates
using Suppressor
using Statistics

include("types.jl")
include("time_slice.jl")
include("time_pattern.jl")
include("parameter_value_types.jl")
include("parse_value.jl")
include("using_spinedb.jl")
include("write_results.jl")
include("helpers.jl")
include("util.jl")

export Anything
export ObjectClass
export RelationshipClass
export Parameter
export ObjectLike
export Object
export TimeSlice
export using_spinedb
export notusing_spinedb
export write_results
export parse_value
export NoValue
export ScalarValue
export ArrayValue
export DictValue
export TimePatternValue
export TimeSeriesValue
export duration
export start
export before
export overlaps
export t_lowest_resolution
export t_highest_resolution
export time_stamps
export indices
export anything
export unique_sorted
export iso8601zoneless

const db_api = PyNULL()
const required_spinedb_api_version = "0.0.22"

function __init__()
    copy!(db_api, pyimport("spinedb_api"))
    current_version = db_api.__version__
    current_version_split = parse.(Int, split(current_version, "."))
    required_version_split = parse.(Int, split(required_spinedb_api_version, "."))
    any(current_version_split .< required_version_split) && error(
"""
SpineInterface couldn't find the required version of `spinedb_api` and needs to be rebuilt:
- Run `import Pkg; Pkg.build("SpineInterface")` to rebuild SpineInterface.
"""
    )
end

end # module