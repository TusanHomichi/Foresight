if [ -f /etc/readahead.packed ]; then
    exit 0
    fi
cd /tmp
yes | rm readahead.packed.new;
touch readahead.packed.new
for dir in $(ls / | grep -v home); do
echo $dir
find  /$dir -type f \( -fstype ext3 -o -fstype rootfs  \) >> \
    readahead.packed.new

done
sreadahead-pack readahead.packed.new
mv readahead.packed.new /etc/readahead.packed 
