#! /bin/sh -

make clean
make 

if [ ! -x dcc ] 
then 
    echo "Error: please make first"
    exit 1
fi

total=0
pass=0
tmp=${TMP:-"/tmp"}/check.tmp

for file in `ls samples-checkpoint/*.out` 
do 
    $((total+=1))
    base=`echo $file | sed 's;\(.*\)\.out;\1;'`
    ext=''
    if [ -r $base.frag ]
      then ext='frag'
    elif [ -r $base.decaf ]
      then ext='decaf'
    else 
      echo "Error: $base not found"
      exit 1
    fi
 
    ./dcc < $base.$ext 2> $tmp 
        
    printf "Checking %-27s: " $file
    if ! diff -B $tmp $file >> error.log
    then 
        echo $base.$ext >> error.log
        echo "FAIL <--"
    else
        $((pass+=1))
        echo "PASS"
    fi
done

echo $total "PASS" $pass
rm $tmp 


