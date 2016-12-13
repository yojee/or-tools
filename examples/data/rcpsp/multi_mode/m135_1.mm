************************************************************************
file with basedata            : cm135_.bas
initial value random generator: 9912
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  97
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       48        8       48
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        1          3           6   7   8
   3        1          3           5   8  13
   4        1          1          12
   5        1          3           6  10  12
   6        1          3          15  16  17
   7        1          3           9  11  13
   8        1          2          11  15
   9        1          2          10  17
  10        1          1          14
  11        1          1          12
  12        1          2          14  17
  13        1          2          15  16
  14        1          1          16
  15        1          1          18
  16        1          1          18
  17        1          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1    10       0    8    6    4
  3      1     7       8    0    3    5
  4      1     5       0    6    4    5
  5      1     7       6    0    7    8
  6      1     4       7    0    6    5
  7      1     4       6    0    4    5
  8      1     6       5    0    4    8
  9      1     3       0    2    5    9
 10      1     5       0    2    6    2
 11      1    10       6    0    7    5
 12      1     7       1    0    2    5
 13      1     3       6    0    7    4
 14      1    10       0    3    2    5
 15      1     5       7    0    5    3
 16      1     5       5    0    6    8
 17      1     6       0    3    3    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   16   13   77   86
************************************************************************