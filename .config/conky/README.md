# Conky config notes

## CPU cores

from /proc/cpuinfo:
performance cores:
offset  coreid  apicid
0        0       0
1        0       1
2        4       8
3        4       9
4        8      16
5        8      17
6       12      24
7       12      25
8       16      32
9       16      33
10      20      40
11      20      41
efficiency cores
offset  coreid  apicid
12      24      48
13      25      50
14      26      52
15      27      54
16      28      56
17      29      58
18      30      60
19      31      62

## Sensors

Meanwhile, `/sys/devlices/platform/coretemp.0/hwmon/hwmon5/*_label` reads:

    for i in $(ls -1 temp*_label | cut -c 5- | cut -d'_' -f1 | sort -n); do
      tempSensor=$(cat temp"$i"_label)
      tempVal=$(cat temp"$i"_input)
      printf "%-2s %-13s %-5s\n" $i "$tempSensor" $tempVal
    done

File |              |
no.  | Label        | Input
-----|--------------|-------
1    | Package id 0 | 57000
2    | Core 0       | 54000
3    | Core 4       | 56000
4    | Core 8       | 56000
5    | Core 12      | 58000
6    | Core 16      | 57000
7    | Core 20      | 55000
8    | Core 24      | 55000
9    | Core 25      | 55000
10   | Core 26      | 55000
11   | Core 27      | 55000
12   | Core 28      | 57000
13   | Core 29      | 56000
14   | Core 30      | 56000
15   | Core 31      | 55000

## Cross-reference

Hence:

from /proc/cpuinfo:
performance cores:
coreid | apicid | Sensor
-------|--------|--------
 all   |        | 1
       |        |
 0     |  0     | 2
 0     |  1     | "
       |        |
 4     |  8     | 3
 4     |  9     | "
       |        |
 8     | 16     | 4
 8     | 17     | "
       |        |
12     | 24     | 5
12     | 25     | "
       |        |
16     | 32     | 6
16     | 33     | "
       |        |
20     | 40     | 7
20     | 41     | "

efficiency cores
coreid | apicid | sensor | actual
-------|--------|--------|-------
24     | 48     |  8     | 8
25     | 50     |  9     | 8
26     | 52     | 10     | 8
27     | 54     | 11     | 8
28     | 56     | 12     | 12
29     | 58     | 13     | 12
30     | 60     | 14     | 12
31     | 62     | 15     | 12

But! Sensors (8,9,10,11) and (12,13,14,15) always give the same temperature,
and seem to be shared between four efficiency cores each. Hence the final 'actual'
sensor column above, which is used in the conky config.

# Test it

Test it by binding busy tasks to a particular CPU, and seeing the corresponding
temperature measurement rise:

    taskset -c 1 busy &

Where -c specifies which cpus to confine the 'busy' process to. (not using -c, giving
a mask instead, behaves in some way I don't understand, ie '32' equates to several
CPUs. Is it in hex? In octal?)

