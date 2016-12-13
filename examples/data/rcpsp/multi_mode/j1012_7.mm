************************************************************************
file with basedata            : mm12_.bas
initial value random generator: 1819287847
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  12
horizon                       :  74
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     10      0       12        7       12
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7  10
   3        3          1           8
   4        3          1           6
   5        3          1           9
   6        3          3           9  10  11
   7        3          1           8
   8        3          2           9  11
   9        3          1          12
  10        3          1          12
  11        3          1          12
  12        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       0   10    3    0
         2     3       0   10    0    3
         3     7       5    0    3    0
  3      1     3       2    0    0    2
         2     5       2    0    6    0
         3     6       0    6    5    0
  4      1     3       0    9    3    0
         2     7       7    0    3    0
         3    10       0    8    0    6
  5      1     3       5    0    6    0
         2     4       0    4    0    8
         3     7       0    2    0    8
  6      1     3       5    0    4    0
         2     3       0    3    8    0
         3     5       6    0    0   10
  7      1     1       7    0    0    5
         2     3       0    9   10    0
         3    10       0    3   10    0
  8      1     7      10    0    0    5
         2     8       0    4    0    5
         3    10       0    4    2    0
  9      1     2       0    5    9    0
         2     5       7    0    0    7
         3     6       7    0    0    4
 10      1     4       0    8    8    0
         2     7       0    8    6    0
         3     8       0    7    5    0
 11      1     1       0    9    0    6
         2     2       7    0    9    0
         3     5       0    7    0    6
 12      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   11   18   64   52
************************************************************************