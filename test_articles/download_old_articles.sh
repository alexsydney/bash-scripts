

get_file_size() {
  wc -c $1 | sed 's/.*\( [[:digit:]]\{1,18\} \).*/\1/'    
}

root_dir='../../article_test/articles'

while [[ $(ls -laR $root_dir | grep " 50 " | grep html | wc -l) -gt 0 ]]; do
    echo "There are `ls -laR $root_dir | grep ' 50 ' | grep html | wc -l` files left to go"

    for dir in `find $root_dir -type d`; do
        if [[ -e "$dir/old_path" ]]; then
            file=$dir/old_article.html
            if [[ -e $file && $(get_file_size $file) -gt 100  ]]; then
                # echo "File exists with size: $(get_file_size "$file")"
                continue
            else
                curl -w "
%{http_code} %{size_download} %{url_effective}
" --progress-bar -o "$file" "`cat $dir/old_path`"
                echo "Saved to $file"
            fi
        fi
    done
    echo Take a break
done


