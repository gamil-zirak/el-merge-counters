cython merge_counters.pyx --embed
gcc -I/usr/include/python3.9 -lpython3.9 -o merge_counters merge_counters.c
rm merge_counters.c
