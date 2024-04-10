
for i in "$@";
do
    dart run vector_graphics_compiler -i $i -o $i.vec;
done
