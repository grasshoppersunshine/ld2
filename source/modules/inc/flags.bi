type FlagsType
private:
    _flags as integer
public:
    declare function has (flag as integer) as integer
    declare function hasNot (flag as integer) as integer
    declare sub set (flag as integer)
    declare sub unset (flag as integer)
    declare sub toggle (flag as integer)
end type

#include once "../flags.bas"
