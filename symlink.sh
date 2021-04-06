for f in "$@"
do
	ln -s "$f" "$f".symlink
done