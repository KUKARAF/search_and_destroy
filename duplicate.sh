
srm(){
	if [ -f "$1" ] ; then
	    rm -f "$1"
fi
}

generate_hash_files(){
	srm $1/.cached.md5 
	srm $1/.cached_just_hash.md5
	find ./$1/ -type f ! -name '.*.md5' -exec md5sum {} --tag \; > $1/.cached.md5
	awk 'NF>1{print $NF}' $1/.cached.md5 > $1/.cached_just_hash_t.md5
	sort -o $1/.cached_just_hash.md5 $1/.cached_just_hash_t.md5
	srm $1/.cached_just_hash_t.md5 
}

rescam_library() {
	sort_count=$(find sort -type f | wc -l)
	done_count=$(find done -type f | wc -l)
	generate_hash_files sort &
	sort_pid=$!
	generate_hash_files done &
	done_pid=$!

	sleep 3

	while kill -0 $done_pid 2> /dev/null || {kill -0 $sort_pid 2> /dev/null}; do
		sort_status=$(wc -l "sort/.cached.md5" | sed -e "s/ .*//g")
		done_status=$(wc -l "done/.cached.md5" | sed -e "s/ .*//g")
		printf "\rSort files: $sort_status / $sort_count             Done files: $done_status / $done_count"
		#sleep 1 
	done


	srm .duplicates.md5 
	srm .files_to_delete.txt
	comm -12 "done/.cached_just_hash.md5" "sort/.cached_just_hash.md5" > .duplicates.md5 
	grep -Ff .duplicates.md5 "sort/.cached.md5" | sed -e "s/MD5 (././g"| sed -e "s/) = .*//g" |sed -e "s/ /\\\\ /g" |  sed -e "s/(/\\\\(/g" | sed -e "s/)/\\\\)/g">> .files_to_delete.txt
}

show_sort(){
	local in;
	read in;
	f=$(grep $in sort/.cached.md5 | sed -e "s/MD5 (././g"| sed -e "s/) = .*//g")
	echo $f
}

show_done(){
	local in;
	read in;
	f=$(grep $in "done/.cached.md5" | sed -e "s/MD5 (././g"| sed -e "s/) = .*//g")
	echo $f
}

check_if_correct(){
	echo displaying file under sort
	show_sort $1
	echo displaying file under done
	show_done $1
}

delete_duplicates_sort(){
	xargs rm < .files_to_delete.txt
	find sort/ -empty -type d -delete
}


