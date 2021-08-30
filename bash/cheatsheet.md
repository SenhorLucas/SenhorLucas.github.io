# Bash cheatsheet

Quick reference guide to avoid googling things over and over again.

## Expansions

## Tests

Type | [ | [[ | Description
--- | --- | --- | ---
String comparison | `\> \< = !=` | `> <  = (or ==) !=` | `[ a \< b ]` or `[[ a < b ]]`
Integer comparison | `-gt -ge -lt -le -eq -ne` | same | `[ 5 -lt 10 ]` or `[[ 5 -lt 10]]`
Conditionals | `-a -o` | `&& \|\|` | `-a -o` are deprecated. `[[ -n $file && -f $file ]]`
Grouping | ``\( ... \)``| ( ... ) | ``[[ $file = img\* && ( $file = \*.png || $file = \*.jpg) ]]``
Pattern matching | not available |  `= ==` | `[ $name = a\*de\* ]]`


## Arrays

### Creation
`arr=()` | Create a empty array
`arr=(1 2 3)` | Create and populate an array
`arr=( $(echo \*) ) | Create array based on command output
`local -a arr` | Declare `arr` as a local array

### Retrieving data
`${arr[0]}` | first element
`"${arr[@]}"` | all elements, separate words
`"${arr[\*]}"` | all elements in a single word, separated by first character in IFS
`${!arr[@]}` | all indexes
`${#arr[@]}` | array size

### Slicing
`"${arr[@]:0:2}"` | 2 elements from index 0
`"${arr[@]:2}"` | All elements from index 2

### Setting data
`arr[1]=2` | Modify element at index
`arr+=(4 5 6)` | Append

### Removing elements
`unset -v "arr[1]" | Results in indexes 0 2 3 4 ... and assing NULL to element

### Perfect insert / remove
Consider the deletion index i=2
`arr=( "${arr[@]:0:$i" "new" "${arr[@]:$i}` ) | add element to array
`arr=( "${arr[@]:0:$(($i-1))" "${arr[@]:$i}` ) | add element to array


### Pass array by reference and value to functions





