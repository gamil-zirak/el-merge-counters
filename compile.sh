

#if command -v pyenv &>/dev/null
#then
#	pyprefix=`pyenv prefix`
#else
#	echo "Not using pyenv for Python headers and libraries. Will try to find those matching system Python."
#	usepyenv=false
#	whichpython=`which python`
#	pyprefix=`dirname $whichpython`
#fi
#echo pyprefix $pyprefix

#if ! command -v python &>/dev/null
#then
#	echo "Python not found."
#	exit 1
#fi

#pyversion=`echo -e "import sys\nprint(str(sys.version_info.major)+'.'+str(sys.version_info.minor))"|python`
#echo pyversion $pyversion


if ! command -v cython &>/dev/null ; then
	echo "cython not found"
	exit 1
fi


pyinclude=`python3-config --includes`
if [ $? -ne 0 ] ; then
	if ! command -v pkg-config &>/dev/null ; then
		echo "pkg-config not found"
		exit 1
	fi
	pyinclude=`pkg-config --cflags python2`
	if [ "$pyinclude" == "" ] ; then
		echo "Python headers not found"
		exit 1
	else
		pyver=2
		patch -o merge_counters.pyx merge_counters.py compile_py2.patch
	fi
else
	pyver=3
	patch -o merge_counters.pyx merge_counters.py compile_py3.patch
fi

echo "Python major version: $pyver"

if [ "$pyver" == "3" ] ; then
	pylibs=`python3-config --ldflags --embed`
	if [ $? -ne 0 ] ; then
		pylibs=`python3-config --ldflags`
		if [ $? -ne 0 ] ; then
			echo "Error finding python library."
			exit 1
		fi
	fi
elif [ "$pyver" == "2" ] ; then
	pylibs=`pkg-config --libs python2`
fi

#echo "Python header: $pyinclude"
#echo "Python library: $pylibs"

cython merge_counters.pyx --embed
gcc $pyinclude -o merge_counters merge_counters.c $pylibs
rm merge_counters.pyx
rm merge_counters.c
