

get_file_size() {
  wc -c $1 | sed 's/.*\( [[:digit:]]\{1,18\} \).*/\1/'    
}

root_dir='../../article_test/articles'
for dir in `find $root_dir -type d`; do
    if [[ -e "$dir/new_path" ]]; then
        file=$dir/new_article.html
        if [[ -e $file && $(get_file_size $file) -gt 100  ]]; then
            # echo "File exists with size: $(get_file_size "$file")"
            continue
        else
            curl -w "
%{http_code} %{size_download} %{url_effective}
" --progress-bar -o "$file" "http://temppa.ucsf.edu/`cat $dir/new_path`"
            echo "Saved to $file"
        fi
    fi
done



